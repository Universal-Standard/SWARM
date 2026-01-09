# AWS Deployment Guide

Deploy PROJECT-SWARM to Amazon Web Services using S3 + CloudFront for the frontend and Lambda or EC2 for the backend.

## Overview

AWS deployment provides comprehensive cloud infrastructure with:
- ✅ S3 + CloudFront for static frontend hosting
- ✅ Lambda for serverless backend (or EC2 for full-stack)
- ✅ RDS for managed PostgreSQL database
- ✅ Route 53 for DNS management
- ✅ Certificate Manager for SSL/TLS
- ✅ CloudWatch for monitoring and logging
- ✅ Extensive AWS service integration
- ✅ Global CDN with edge locations

## Prerequisites

- **AWS Account**: [Create AWS account](https://aws.amazon.com/free/)
- **AWS CLI**: [Install AWS CLI](https://aws.amazon.com/cli/)
- **Node.js 22+**: Required for building the application
- **Git**: For deployment

## Cost Estimate

**Frontend (S3 + CloudFront)**:
- S3: ~$1-5/month (storage + requests)
- CloudFront: ~$1-10/month (data transfer, Free tier: 1TB/month for 12 months)

**Backend Options**:
- Lambda: ~$0-5/month (1M free requests/month)
- EC2 t3.micro: ~$8/month (Free tier: 750 hours/month for 12 months)

**Database (RDS PostgreSQL)**:
- db.t4g.micro: ~$15/month (Free tier: 750 hours/month for 12 months)

**Total estimated cost**: $0-10/month (with free tier), $20-40/month (after free tier)

## Quick Start

### 1. Install AWS CLI
```bash
# macOS
brew install awscli

# Windows
msiexec.exe /i https://awscli.amazonaws.com/AWSCLIV2.msi

# Linux
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

### 2. Configure AWS CLI
```bash
aws configure
# AWS Access Key ID: your-access-key
# AWS Secret Access Key: your-secret-key
# Default region: us-east-1
# Default output format: json
```

### 3. Build the Application
```bash
git clone https://github.com/Universal-Standard/SWARM.git
cd SWARM
git checkout aws-main
npm install
npm run build
```

### 4. Deploy Frontend to S3
```bash
# Create S3 bucket
aws s3 mb s3://swarm-app-frontend

# Enable static website hosting
aws s3 website s3://swarm-app-frontend \
  --index-document index.html \
  --error-document 404.html

# Upload build files
aws s3 sync dist/public s3://swarm-app-frontend --delete

# Make bucket publicly readable
aws s3api put-bucket-policy \
  --bucket swarm-app-frontend \
  --policy file://s3-bucket-policy.json
```

## Detailed Setup

### Frontend Deployment (S3 + CloudFront)

#### 1. Create S3 Bucket
```bash
# Create bucket (use globally unique name)
BUCKET_NAME="swarm-app-$(date +%s)"
aws s3 mb s3://$BUCKET_NAME --region us-east-1

# Enable static website hosting
aws s3 website s3://$BUCKET_NAME \
  --index-document index.html \
  --error-document 404.html
```

#### 2. Configure Bucket Policy
Create `s3-bucket-policy.json`:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::BUCKET_NAME/*"
    }
  ]
}
```

Replace `BUCKET_NAME` with your bucket name, then apply:
```bash
aws s3api put-bucket-policy \
  --bucket $BUCKET_NAME \
  --policy file://s3-bucket-policy.json
```

#### 3. Set Up CloudFront Distribution
```bash
# Create CloudFront distribution
aws cloudfront create-distribution \
  --origin-domain-name $BUCKET_NAME.s3-website-us-east-1.amazonaws.com \
  --default-root-object index.html
```

Or create `cloudfront-config.json`:
```json
{
  "CallerReference": "swarm-app-$(date +%s)",
  "Origins": {
    "Quantity": 1,
    "Items": [
      {
        "Id": "S3-swarm-app",
        "DomainName": "BUCKET_NAME.s3.amazonaws.com",
        "S3OriginConfig": {
          "OriginAccessIdentity": ""
        }
      }
    ]
  },
  "DefaultCacheBehavior": {
    "TargetOriginId": "S3-swarm-app",
    "ViewerProtocolPolicy": "redirect-to-https",
    "AllowedMethods": {
      "Quantity": 2,
      "Items": ["GET", "HEAD"]
    },
    "ForwardedValues": {
      "QueryString": false,
      "Cookies": {"Forward": "none"}
    }
  },
  "Comment": "SWARM Frontend Distribution",
  "Enabled": true
}
```

#### 4. Deploy to S3
```bash
npm run build
aws s3 sync dist/public s3://$BUCKET_NAME --delete

# Invalidate CloudFront cache
DISTRIBUTION_ID=$(aws cloudfront list-distributions --query "DistributionList.Items[?Comment=='SWARM Frontend Distribution'].Id" --output text)
aws cloudfront create-invalidation \
  --distribution-id $DISTRIBUTION_ID \
  --paths "/*"
```

### Backend Deployment

#### Option 1: AWS Lambda (Serverless)

##### 1. Install Serverless Framework
```bash
npm install -g serverless
```

##### 2. Create Serverless Configuration
Create `serverless.yml`:
```yaml
service: swarm-backend

provider:
  name: aws
  runtime: nodejs20.x
  region: us-east-1
  environment:
    DATABASE_URL: ${env:DATABASE_URL}
    OPENAI_API_KEY: ${env:OPENAI_API_KEY}
    ANTHROPIC_API_KEY: ${env:ANTHROPIC_API_KEY}
    GOOGLE_GENAI_API_KEY: ${env:GOOGLE_GENAI_API_KEY}
    SESSION_SECRET: ${env:SESSION_SECRET}
    NODE_ENV: production

functions:
  api:
    handler: dist/index.handler
    events:
      - http:
          path: /{proxy+}
          method: ANY
          cors: true

plugins:
  - serverless-offline

package:
  patterns:
    - '!node_modules/**'
    - 'dist/**'
```

##### 3. Modify Server for Lambda
Create `server/lambda.ts`:
```typescript
import serverless from 'serverless-http';
import express from 'express';
import { registerRoutes } from './routes';

const app = express();
registerRoutes(app);

export const handler = serverless(app);
```

##### 4. Deploy Lambda
```bash
npm install serverless-http
npm run build
serverless deploy
```

#### Option 2: AWS EC2 (Traditional Hosting)

##### 1. Launch EC2 Instance
```bash
# Create EC2 instance
aws ec2 run-instances \
  --image-id ami-0c55b159cbfafe1f0 \
  --instance-type t3.micro \
  --key-name your-key-pair \
  --security-groups swarm-sg \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=swarm-backend}]'
```

##### 2. Configure Security Group
```bash
# Create security group
aws ec2 create-security-group \
  --group-name swarm-sg \
  --description "SWARM Backend Security Group"

# Allow SSH
aws ec2 authorize-security-group-ingress \
  --group-name swarm-sg \
  --protocol tcp \
  --port 22 \
  --cidr 0.0.0.0/0

# Allow HTTP
aws ec2 authorize-security-group-ingress \
  --group-name swarm-sg \
  --protocol tcp \
  --port 80 \
  --cidr 0.0.0.0/0

# Allow HTTPS
aws ec2 authorize-security-group-ingress \
  --group-name swarm-sg \
  --protocol tcp \
  --port 443 \
  --cidr 0.0.0.0/0
```

##### 3. Connect and Deploy
```bash
# Connect to instance
ssh -i your-key-pair.pem ec2-user@your-instance-ip

# Install Node.js
curl -fsSL https://rpm.nodesource.com/setup_20.x | sudo bash -
sudo yum install -y nodejs git

# Clone and setup
git clone https://github.com/Universal-Standard/SWARM.git
cd SWARM
git checkout aws-main
npm install
npm run build

# Install PM2
sudo npm install -g pm2

# Start application
pm2 start dist/index.js --name swarm-backend
pm2 startup
pm2 save
```

##### 4. Configure Nginx Reverse Proxy
```bash
# Install Nginx
sudo amazon-linux-extras install nginx1

# Configure Nginx
sudo nano /etc/nginx/conf.d/swarm.conf
```

Add configuration:
```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

```bash
# Start Nginx
sudo systemctl start nginx
sudo systemctl enable nginx
```

### Database Setup (RDS PostgreSQL)

#### 1. Create RDS Instance
```bash
aws rds create-db-instance \
  --db-instance-identifier swarm-db \
  --db-instance-class db.t4g.micro \
  --engine postgres \
  --engine-version 16.1 \
  --master-username swarmadmin \
  --master-user-password YourSecurePassword123! \
  --allocated-storage 20 \
  --vpc-security-group-ids sg-xxxxx \
  --db-name swarmdb \
  --backup-retention-period 7 \
  --publicly-accessible
```

#### 2. Configure Security Group
```bash
# Allow PostgreSQL connections
aws ec2 authorize-security-group-ingress \
  --group-id sg-xxxxx \
  --protocol tcp \
  --port 5432 \
  --source-group sg-xxxxx
```

#### 3. Get Connection String
```bash
aws rds describe-db-instances \
  --db-instance-identifier swarm-db \
  --query 'DBInstances[0].Endpoint.Address' \
  --output text

# Connection string format:
# postgresql://swarmadmin:YourSecurePassword123!@endpoint-address:5432/swarmdb
```

### Custom Domain Setup (Route 53)

#### 1. Create Hosted Zone
```bash
aws route53 create-hosted-zone \
  --name yourdomain.com \
  --caller-reference $(date +%s)
```

#### 2. Request SSL Certificate
```bash
aws acm request-certificate \
  --domain-name yourdomain.com \
  --validation-method DNS \
  --subject-alternative-names "*.yourdomain.com"
```

#### 3. Configure DNS Records
```bash
# Get CloudFront distribution domain
CLOUDFRONT_DOMAIN=$(aws cloudfront get-distribution --id $DISTRIBUTION_ID --query 'Distribution.DomainName' --output text)

# Create A record
aws route53 change-resource-record-sets \
  --hosted-zone-id YOUR_ZONE_ID \
  --change-batch file://dns-record.json
```

Create `dns-record.json`:
```json
{
  "Changes": [
    {
      "Action": "CREATE",
      "ResourceRecordSet": {
        "Name": "yourdomain.com",
        "Type": "A",
        "AliasTarget": {
          "HostedZoneId": "Z2FDTNDATAQYW2",
          "DNSName": "CLOUDFRONT_DOMAIN",
          "EvaluateTargetHealth": false
        }
      }
    }
  ]
}
```

## CI/CD with GitHub Actions

Create `.github/workflows/deploy-aws.yml`:
```yaml
name: Deploy to AWS

on:
  push:
    branches:
      - aws-main
      - aws-staging

jobs:
  deploy-frontend:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '22'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Build
        run: npm run build
      
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1
      
      - name: Deploy to S3
        run: |
          aws s3 sync dist/public s3://${{ secrets.S3_BUCKET }} --delete
      
      - name: Invalidate CloudFront
        run: |
          aws cloudfront create-invalidation \
            --distribution-id ${{ secrets.CLOUDFRONT_DISTRIBUTION_ID }} \
            --paths "/*"

  deploy-backend:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '22'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Build
        run: npm run build
      
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1
      
      - name: Deploy Lambda
        run: |
          npm install -g serverless
          serverless deploy
```

## Environment Variables

### Lambda Environment Variables
```bash
# Set Lambda environment variables
aws lambda update-function-configuration \
  --function-name swarm-backend-api \
  --environment Variables="{
    DATABASE_URL=postgresql://...,
    OPENAI_API_KEY=sk-...,
    ANTHROPIC_API_KEY=sk-ant-...,
    GOOGLE_GENAI_API_KEY=...,
    SESSION_SECRET=your-secret,
    NODE_ENV=production
  }"
```

### EC2 Environment Variables
```bash
# Create .env file on EC2
cat > /home/ec2-user/SWARM/.env << EOF
DATABASE_URL=postgresql://...
OPENAI_API_KEY=sk-...
ANTHROPIC_API_KEY=sk-ant-...
GOOGLE_GENAI_API_KEY=...
SESSION_SECRET=your-secret
NODE_ENV=production
EOF
```

## Monitoring (CloudWatch)

### Enable CloudWatch Logs
```bash
# For Lambda (automatic)
# Logs are automatically sent to CloudWatch

# For EC2, install CloudWatch agent
wget https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
sudo rpm -U ./amazon-cloudwatch-agent.rpm
```

### View Logs
```bash
# Lambda logs
aws logs tail /aws/lambda/swarm-backend-api --follow

# EC2 logs
aws logs tail /aws/ec2/swarm-backend --follow
```

## Scaling

### Auto Scaling for EC2
```bash
# Create launch template
aws ec2 create-launch-template \
  --launch-template-name swarm-template \
  --version-description "SWARM backend v1" \
  --launch-template-data file://launch-template.json

# Create Auto Scaling group
aws autoscaling create-auto-scaling-group \
  --auto-scaling-group-name swarm-asg \
  --launch-template LaunchTemplateName=swarm-template \
  --min-size 1 \
  --max-size 5 \
  --desired-capacity 2 \
  --vpc-zone-identifier "subnet-xxx,subnet-yyy"
```

### Lambda Scaling
Lambda automatically scales (no configuration needed).

## Troubleshooting

### S3 Deployment Issues
```bash
# Check bucket policy
aws s3api get-bucket-policy --bucket $BUCKET_NAME

# List bucket contents
aws s3 ls s3://$BUCKET_NAME --recursive
```

### Lambda Issues
```bash
# View Lambda logs
aws logs tail /aws/lambda/swarm-backend-api --follow

# Test Lambda function
aws lambda invoke \
  --function-name swarm-backend-api \
  --payload '{"path": "/api/health"}' \
  response.json
```

### EC2 Connection Issues
```bash
# Check instance status
aws ec2 describe-instance-status --instance-ids i-xxxxx

# Check security groups
aws ec2 describe-security-groups --group-ids sg-xxxxx
```

## Cleanup

```bash
# Delete S3 bucket
aws s3 rb s3://$BUCKET_NAME --force

# Delete CloudFront distribution
aws cloudfront delete-distribution --id $DISTRIBUTION_ID

# Delete Lambda function
serverless remove

# Terminate EC2 instance
aws ec2 terminate-instances --instance-ids i-xxxxx

# Delete RDS instance
aws rds delete-db-instance \
  --db-instance-identifier swarm-db \
  --skip-final-snapshot
```

## Resources

- [AWS Documentation](https://docs.aws.amazon.com/)
- [S3 Static Website Hosting](https://docs.aws.amazon.com/AmazonS3/latest/userguide/WebsiteHosting.html)
- [CloudFront Documentation](https://docs.aws.amazon.com/cloudfront/)
- [Lambda Documentation](https://docs.aws.amazon.com/lambda/)
- [RDS Documentation](https://docs.aws.amazon.com/rds/)

## Support

- AWS Support: [aws.amazon.com/support](https://aws.amazon.com/support)
- Repository Issues: [GitHub Issues](https://github.com/Universal-Standard/SWARM/issues)

---

**Next Steps**:
- Configure environment variables
- Set up custom domain
- Enable CloudWatch monitoring
- Configure auto-scaling
