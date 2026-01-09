# AWS Platform - MAIN Environment

## Quick Start
Production deployment on AWS S3 + CloudFront + Lambda.

**Platform:** AWS (S3 + CloudFront + Lambda)  
**Environment:** Production  
**Architecture:** Highly scalable serverless

## Deployment

### Prerequisites
```bash
# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Configure credentials
aws configure
```

### Deploy Frontend (S3 + CloudFront)
```bash
# Create S3 bucket
aws s3 mb s3://swarm-app-frontend

# Enable static hosting
aws s3 website s3://swarm-app-frontend \
  --index-document index.html \
  --error-document 404.html

# Deploy
aws s3 sync client/dist s3://swarm-app-frontend

# Create CloudFront distribution
aws cloudfront create-distribution \
  --origin-domain-name swarm-app-frontend.s3.amazonaws.com
```

### Deploy Backend (Lambda)
```bash
# Using AWS SAM
sam build
sam deploy --guided
```

## Platform Features
- **Frontend:** S3 + CloudFront (global CDN)
- **Backend:** Lambda + API Gateway (serverless)
- **Database:** RDS PostgreSQL (recommended)
- **Caching:** ElastiCache (optional)
- **Monitoring:** CloudWatch

## Configuration Files
- `samconfig.toml`: AWS SAM configuration
- `template.yaml`: CloudFormation template
- `.github/workflows/deploy-aws.yml`: CI/CD

## Environment Variables
```bash
AWS_ACCESS_KEY_ID=<access-key>
AWS_SECRET_ACCESS_KEY=<secret-key>
AWS_REGION=us-east-1
DATABASE_URL=<rds-connection-string>
```

## Infrastructure Components
- **S3 Bucket:** Static file hosting
- **CloudFront:** Global CDN distribution
- **Lambda Functions:** Backend API logic
- **API Gateway:** RESTful API endpoints
- **RDS:** PostgreSQL database
- **CloudWatch:** Logging and monitoring

## Scalability
- Auto-scaling Lambda functions
- CloudFront edge locations worldwide
- RDS read replicas for high traffic
- ElastiCache for reduced database load

**Branch:** `aws-main` | **Platform:** `AWS` | **Environment:** `PRODUCTION`