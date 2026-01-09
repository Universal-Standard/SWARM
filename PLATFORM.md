# AWS Platform - FEATURES Environment

**Platform:** AWS (S3 + CloudFront + Lambda)  
**Environment:** Feature Integration  
**Purpose:** Test AWS service integrations

## Deployment
```bash
sam deploy --stack-name swarm-features --parameter-overrides Environment=features
```

## Testing Focus
- Lambda layer compatibility
- API Gateway stage testing
- S3 event triggers
- SQS/SNS messaging
- DynamoDB integration

**Branch:** `aws-features` | **Platform:** `AWS` | **Environment:** `FEATURES`