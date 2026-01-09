# AWS Platform - DEVELOPMENT Environment

**Platform:** AWS (S3 + CloudFront + Lambda)  
**Environment:** Development/Testing  
**Purpose:** AWS infrastructure development and testing

## Deployment
```bash
# Deploy to development stack
sam build
sam deploy --stack-name swarm-dev --parameter-overrides Environment=development
```

## Configuration
- Development Lambda functions
- Test RDS instance (small tier)
- CloudWatch verbose logging
- X-Ray tracing enabled

## Testing Focus
- Lambda function testing
- API Gateway configuration
- RDS query optimization
- CloudWatch metrics validation

**Branch:** `aws-development` | **Platform:** `AWS` | **Environment:** `DEVELOPMENT`