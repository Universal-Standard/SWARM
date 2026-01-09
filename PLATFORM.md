# CLOUDFLARE Platform - MAIN Environment

## Quick Start
Production deployment on Cloudflare Pages + Workers.

**Platform:** Cloudflare Pages + Workers  
**Environment:** Production  
**Edge Computing:** Global CDN with <50ms response times

## Deployment

### Prerequisites
```bash
npm install -g wrangler
wrangler login
```

### Deploy
```bash
# Frontend (Pages)
wrangler pages deploy client/dist

# Backend (Workers)
wrangler deploy
```

## Platform Features
- **Edge Functions:** Cloudflare Workers at 300+ locations
- **Database:** D1 (SQLite at edge) or external
- **CDN:** Automatic global distribution
- **DDoS Protection:** Built-in enterprise-grade
- **Analytics:** Real-time edge analytics

## Configuration Files
- `wrangler.toml`: Workers configuration
- `.github/workflows/deploy-cloudflare.yml`: CI/CD

## Environment Variables
```bash
CF_ACCOUNT_ID=<cloudflare-account-id>
CF_API_TOKEN=<cloudflare-api-token>
DATABASE_URL=<database-connection>
```

## Performance
- Global edge deployment
- Sub-50ms response times worldwide
- Unlimited bandwidth (paid plans)
- Automatic SSL/TLS

**Branch:** `cloudflare-main` | **Platform:** `CLOUDFLARE` | **Environment:** `PRODUCTION`