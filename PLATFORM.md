# CLOUDFLARE Platform - STAGING Environment

**Platform:** Cloudflare Pages + Workers  
**Environment:** Staging (Pre-Production)  
**Purpose:** Production-like edge deployment validation

## Deployment
```bash
wrangler pages deploy client/dist --branch staging
wrangler deploy --env staging
```

## Configuration
- Production-identical Workers setup
- Full edge network deployment
- Production D1 structure (test data)
- Complete monitoring and analytics

## Validation Requirements
- Global latency testing
- Edge cache validation
- Worker CPU limits testing
- DDoS protection verification

**Branch:** `cloudflare-staging` | **Platform:** `CLOUDFLARE` | **Environment:** `STAGING`