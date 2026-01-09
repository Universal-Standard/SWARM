# Branch Index

This repository has **16 platform-specific branches** organized into **4 groups**.

## Branch Status

✅ **All 16 branches have been created and configured**

## Branch Groups

### 🐙 GitHub Group
Optimized for GitHub Pages static hosting

| Branch | Status | Purpose |
|--------|--------|---------|
| `github-main` | ✅ Configured | Production deployment |
| `github-staging` | ✅ Created | Pre-production testing |
| `github-development` | ✅ Created | Active development |
| `github-features` | ✅ Created | Feature experiments |

**Documentation**: [docs/deployment/GITHUB_PAGES_DEPLOYMENT.md](docs/deployment/GITHUB_PAGES_DEPLOYMENT.md)

---

### ☁️ Cloudflare Group
Optimized for Cloudflare Pages + Workers edge computing

| Branch | Status | Purpose |
|--------|--------|---------|
| `cloudflare-main` | ✅ Configured | Production deployment |
| `cloudflare-staging` | ✅ Created | Pre-production testing |
| `cloudflare-development` | ✅ Created | Active development |
| `cloudflare-features` | ✅ Created | Feature experiments |

**Documentation**: 
- [docs/deployment/CLOUDFLARE_DEPLOYMENT.md](docs/deployment/CLOUDFLARE_DEPLOYMENT.md)
- [docs/deployment/CLOUDFLARE_WORKERS_GUIDE.md](docs/deployment/CLOUDFLARE_WORKERS_GUIDE.md)

---

### ⚡ Azure Group
Optimized for Microsoft Azure Static Web Apps + Functions

| Branch | Status | Purpose |
|--------|--------|---------|
| `azure-main` | ✅ Configured | Production deployment |
| `azure-staging` | ✅ Created | Pre-production testing |
| `azure-development` | ✅ Created | Active development |
| `azure-features` | ✅ Created | Feature experiments |

**Documentation**: [docs/deployment/AZURE_DEPLOYMENT.md](docs/deployment/AZURE_DEPLOYMENT.md)

---

### ☁️ AWS Group
Optimized for Amazon Web Services (S3, Lambda, EC2)

| Branch | Status | Purpose |
|--------|--------|---------|
| `aws-main` | ✅ Configured | Production deployment |
| `aws-staging` | ✅ Created | Pre-production testing |
| `aws-development` | ✅ Created | Active development |
| `aws-features` | ✅ Created | Feature experiments |

**Documentation**: [docs/deployment/AWS_DEPLOYMENT.md](docs/deployment/AWS_DEPLOYMENT.md)

---

## Quick Start Guide

### 1. Choose Your Platform

Pick the platform that best fits your needs:

| Need | Recommended Platform |
|------|---------------------|
| Zero-cost hosting | **GitHub** |
| Global low latency | **Cloudflare** |
| Enterprise features | **Azure** |
| Full AWS ecosystem | **AWS** |
| Static site only | **GitHub** or **Cloudflare** |
| Serverless backend | **Cloudflare** or **AWS** |
| Microsoft integration | **Azure** |

### 2. Checkout Your Platform Branch

```bash
# For GitHub deployment
git checkout github-development

# For Cloudflare deployment
git checkout cloudflare-development

# For Azure deployment
git checkout azure-development

# For AWS deployment
git checkout aws-development
```

### 3. Read Platform Documentation

Each platform branch contains a `PLATFORM.md` file with:
- Quick start guide
- Platform-specific features
- Configuration files
- Links to detailed documentation

### 4. Follow Deployment Guide

Detailed setup instructions are in `docs/deployment/`:
- `GITHUB_PAGES_DEPLOYMENT.md`
- `CLOUDFLARE_DEPLOYMENT.md`
- `AZURE_DEPLOYMENT.md`
- `AWS_DEPLOYMENT.md`

---

## Branch Workflow

Each platform follows the same development workflow:

```
features → development → staging → main
```

1. **Features**: Create new features and experiments
2. **Development**: Integrate and test changes
3. **Staging**: Pre-production testing and QA
4. **Main**: Production-ready code (auto-deploys)

### Example Workflow

```bash
# Work on a new feature for Cloudflare platform
git checkout cloudflare-features
git checkout -b feature/new-analytics

# Make changes and commit
git add .
git commit -m "Add analytics feature"

# Merge to development
git checkout cloudflare-development
git merge feature/new-analytics

# Test in staging
git checkout cloudflare-staging
git merge cloudflare-development

# Deploy to production
git checkout cloudflare-main
git merge cloudflare-staging
git push origin cloudflare-main  # Triggers auto-deployment
```

---

## Platform Comparison

| Feature | GitHub | Cloudflare | Azure | AWS |
|---------|--------|------------|-------|-----|
| **Cost (Free Tier)** | ✅ Forever | ✅ Generous | ✅ 12 months | ✅ 12 months |
| **Static Hosting** | ✅ | ✅ | ✅ | ✅ |
| **Serverless Backend** | ❌ | ✅ Workers | ✅ Functions | ✅ Lambda |
| **Custom Domain** | ✅ | ✅ | ✅ | ✅ |
| **Auto SSL** | ✅ | ✅ | ✅ | ✅ |
| **Global CDN** | ✅ | ✅ 300+ POPs | ✅ | ✅ |
| **Edge Computing** | ❌ | ✅ | ❌ | ✅ Lambda@Edge |
| **Auto-Deploy** | ✅ Actions | ✅ | ✅ | ✅ CodePipeline |
| **Database** | ❌ | ✅ D1 | ✅ | ✅ RDS |
| **Best For** | OSS/Docs | Global Apps | Enterprise | Full Stack |

---

## Platform Features Summary

### GitHub Pages
- ✅ Free forever for public repos
- ✅ GitHub Actions CI/CD
- ✅ Zero configuration
- ✅ Perfect for documentation and static sites
- ❌ Frontend only (no backend)

### Cloudflare Pages + Workers
- ✅ Edge computing in 300+ locations
- ✅ <50ms latency worldwide
- ✅ Serverless backend (Workers)
- ✅ Generous free tier
- ✅ Best performance for global users

### Azure Static Web Apps + Functions
- ✅ Enterprise-grade security
- ✅ Microsoft 365 integration
- ✅ Azure DevOps integration
- ✅ Built-in authentication
- ✅ Best for enterprise and Microsoft ecosystem

### AWS S3 + Lambda/EC2
- ✅ Full AWS ecosystem access
- ✅ Most flexible and comprehensive
- ✅ Multiple deployment options
- ✅ Best for complex applications
- ✅ Extensive monitoring and security

---

## Contributing

When contributing to this repository:

1. **Choose the appropriate platform** for your changes
2. **Work in the features branch** for that platform
3. **Follow the standard workflow**: features → development → staging → main
4. **Test thoroughly** in staging before merging to main
5. **Keep platform-specific changes isolated** to their respective branches
6. **Sync common changes** across platforms when applicable

---

## Maintenance

### Syncing Common Code

When making changes that affect all platforms:

1. Make changes in one platform's development branch
2. Create PRs to sync changes to other platform development branches
3. Test in each platform's staging environment
4. Merge to each platform's main branch individually

### Platform-Specific Updates

Updates specific to one platform should remain in that platform's branches only.

---

## Documentation

- **[MULTI_PLATFORM_BRANCHES.md](MULTI_PLATFORM_BRANCHES.md)** - Complete branch strategy guide
- **[README.md](README.md)** - Main project documentation
- **[docs/deployment/](docs/deployment/)** - Platform-specific deployment guides
- **[docs/README.md](docs/README.md)** - Complete documentation index

---

## Support

- **General Questions**: Open an issue
- **Platform-Specific Issues**: Include platform name in issue title
- **Deployment Help**: Check platform-specific documentation first

---

## Verification Commands

```bash
# List all branches
git branch -a

# Show platform branches only
git branch -a | grep -E '(github|cloudflare|azure|aws)'

# Checkout a specific platform
git checkout <platform>-development

# View branch relationships
git log --oneline --graph --all

# Compare branches
git diff github-main cloudflare-main
```

---

**Last Updated**: January 9, 2026

**Total Branches**: 16 (4 platforms × 4 branches each)

**Status**: ✅ All branches created and configured
