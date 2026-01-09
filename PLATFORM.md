# GITHUB Platform - MAIN Environment

## Quick Start

This branch is optimized for deployment on **GitHub Pages** in the **production** environment.

### Platform: GITHUB PAGES

**Deployment Type:** GitHub Pages (Static Site)  
**Backend:** GitHub Actions + Serverless Functions  
**Database:** External managed service (Neon/Supabase recommended)

---

## Deployment Steps

### 1. Configure GitHub Pages

Navigate to: **Settings → Pages** in your repository

- **Source:** Deploy from a branch
- **Branch:** `github-main`
- **Folder:** `/` (root) or `/docs` based on build output

### 2. Configure Repository Secrets

Navigate to: **Settings → Secrets and variables → Actions**

Add the following secrets:

```
DATABASE_URL=<your-database-connection-string>
```

Additional secrets as needed:
- `API_KEYS`: For third-party API integrations
- `ENCRYPTION_KEY`: For secure data handling

### 3. Trigger Deployment

Push to `github-main` branch triggers automatic deployment via GitHub Actions:

```bash
git checkout github-main
git merge development  # After thorough testing
git push origin github-main
```

### 4. Verify Deployment

Check deployment status:
- **Actions tab** in GitHub repository
- **Deployments** section in repository sidebar
- Live URL: `https://universal-standard.github.io/SWARM/`

---

## Configuration Files

### Primary Workflow
- `.github/workflows/deploy-github-pages.yml`: Main deployment workflow

### Frontend Configuration
- `client/404.html`: Custom 404 error page
- `client/index.html`: Application entry point
- `package.json`: Build scripts and dependencies

---

## Architecture

### Frontend Deployment
- **Hosting:** GitHub Pages CDN
- **Build Process:** Vite production build
- **Output Directory:** `client/dist`
- **HTTPS:** Automatic via GitHub Pages

### Backend Architecture
- **Option 1:** Serverless Functions (GitHub Actions scheduled)
- **Option 2:** External API (Vercel, Netlify, Railway)
- **Option 3:** Traditional server (AWS, Azure, DigitalOcean)

### Database
- **Recommended:** Neon PostgreSQL (serverless, free tier)
- **Alternative:** Supabase (PostgreSQL + Auth + Storage)
- **Connection:** Via `DATABASE_URL` environment variable

---

## Environment: MAIN (Production)

**Purpose:** Production environment serving live traffic  
**Protection:** Maximum branch protection enabled  
**Deployment:** Automatic on merge (requires approvals)  
**Domain:** Production domain with SSL  
**Monitoring:** Full logging, alerting, and performance tracking

### Merge Policy

- ✅ Requires 2 approving reviews
- ✅ Must pass all CI/CD checks
- ✅ No direct commits (PR only)
- ✅ Automated deployment on merge
- ✅ Status checks must pass:
  - Build successful
  - Tests passing (unit, integration, e2e)
  - Security scan clean
  - Performance benchmarks met

### Quality Gates

Before merge to production:
1. All tests passing in `github-staging`
2. Security audit completed
3. Performance testing verified
4. Documentation updated
5. Stakeholder approval obtained

---

## Live URL

**Production URL:** https://universal-standard.github.io/SWARM/

Configure custom domain:
1. Add `CNAME` file to repository root with your domain
2. Configure DNS records:
   - `CNAME` record pointing to `universal-standard.github.io`
   - Or `A` records to GitHub Pages IPs
3. Enable HTTPS in repository settings

---

## Getting Started

```bash
# Clone repository
git clone git@github.com:Universal-Standard/SWARM.git
cd SWARM

# Checkout this branch
git checkout github-main

# Install dependencies
npm install

# Configure environment
cp .env.example .env
# Edit .env with production credentials

# Build for production
npm run build

# Test build locally
npm run preview
```

---

## Deployment Workflow

### Standard Release Process

1. **Development** → Feature branch
2. **Testing** → `github-development` branch
3. **Integration** → `github-features` branch
4. **Pre-Production** → `github-staging` branch
5. **Production** → `github-main` branch (this)

### Hotfix Process

For critical production fixes:

```bash
# Create hotfix branch from production
git checkout github-main
git checkout -b hotfix/critical-bug

# Make fixes and test
git add .
git commit -m "fix: Critical production issue"

# Create PR directly to github-main
# Requires emergency approval process
```

---

## Monitoring & Observability

### Metrics to Track
- Page load time (target: <2s)
- Time to interactive (target: <3s)
- Uptime (target: 99.9%)
- Error rate (target: <0.1%)

### Logging
- GitHub Actions execution logs
- Browser console errors (via error tracking service)
- API response times and error rates

### Alerts
Configure alerts for:
- Deployment failures
- Build errors
- Performance degradation
- Security vulnerabilities

---

## Rollback Procedures

If critical issues occur after deployment:

```bash
# Option 1: Revert commit
git revert <commit-hash>
git push origin github-main

# Option 2: Reset to previous state
git reset --hard <previous-commit>
git push --force origin github-main

# Option 3: Deploy from staging
git checkout github-main
git reset --hard github-staging
git push --force origin github-main
```

**⚠️ Force push requires administrator privileges**

---

## Performance Optimization

### GitHub Pages Optimizations
- Minified assets (via Vite)
- Gzip compression (automatic)
- CDN distribution (global)
- Browser caching (configured via headers)

### Build Optimizations
```json
{
  "scripts": {
    "build": "vite build --mode production",
    "build:analyze": "vite-bundle-visualizer"
  }
}
```

---

## Security Considerations

### Content Security Policy
Configure CSP headers via meta tags:

```html
<meta http-equiv="Content-Security-Policy" 
      content="default-src 'self'; script-src 'self' 'unsafe-inline'">
```

### Secrets Management
- ⚠️ Never commit secrets to repository
- ✅ Use GitHub Secrets for CI/CD
- ✅ Use environment variables in runtime
- ✅ Rotate credentials quarterly

---

## Documentation

For detailed deployment instructions:
- [GitHub Pages Deployment Guide](docs/deployment/GITHUB_PAGES_DEPLOYMENT.md)
- [Multi-Platform Strategy](MULTI_PLATFORM_BRANCHES.md)
- [Branch Overview](BRANCHES.md)

---

## Troubleshooting

### Common Issues

**Build Fails**
```bash
# Clear cache and rebuild
rm -rf node_modules dist
npm install
npm run build
```

**404 Errors**
- Verify `404.html` exists
- Check router configuration (History mode vs Hash mode)
- Ensure base path matches repository name

**Assets Not Loading**
- Check Vite `base` configuration in `vite.config.ts`
- Verify asset paths are relative
- Check browser console for CORS errors

---

## Support

**Production Issues:**
- Emergency: Contact on-call engineer
- Non-urgent: Create issue with `production` label

**Platform Questions:**
- [GitHub Pages Documentation](https://docs.github.com/pages)
- [GitHub Actions Documentation](https://docs.github.com/actions)

---

**Branch:** `github-main`  
**Platform:** `GITHUB PAGES`  
**Environment:** `PRODUCTION`  
**Last Updated:** 2026-01-09  
**Status:** ✅ OPERATIONAL