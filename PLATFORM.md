# AWS Platform - STAGING Environment

**Platform:** AWS (S3 + CloudFront + Lambda)  
**Environment:** Staging (Pre-Production)  
**Purpose:** Production-ready AWS deployment validation

## Deployment
```bash
sam deploy --stack-name swarm-staging --parameter-overrides Environment=staging
```

## Configuration
- Production-identical infrastructure
- Full CloudWatch monitoring and alarms
- Production-tier RDS instance
- CloudFront with production settings
- Complete AWS WAF rules

## Validation Requirements
- Load testing with Artillery/K6
- Security audit with AWS Security Hub
- Cost optimization review
- Disaster recovery drill
- RDS backup and restore testing

## Pre-Production Checklist
- [ ] CloudWatch alarms configured
- [ ] RDS automated backups enabled
- [ ] Lambda reserved concurrency set
- [ ] CloudFront cache behavior optimized
- [ ] IAM roles and policies audited

**Branch:** `aws-staging` | **Platform:** `AWS` | **Environment:** `STAGING`