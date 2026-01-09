# Multi-Platform Branch Strategy

This repository uses a multi-platform branch strategy to support deployment across four major cloud platforms. Each platform has four dedicated branches for different stages of development.

**📋 Quick Reference**: See [BRANCHES.md](BRANCHES.md) for a complete index of all 16 branches with their current status.

---

## Branch Groups

### 🐙 Group 1: GitHub-Centric
Optimized for GitHub Pages static hosting and GitHub Actions workflows.

- **github-main** - Production branch for GitHub Pages deployment
- **github-development** - Active development for GitHub platform features
- **github-features** - Feature branches and experiments for GitHub integration
- **github-staging** - Pre-production testing for GitHub deployments

**Best For**: Open-source projects, documentation sites, static web applications

**Key Features**:
- GitHub Pages automatic deployment
- GitHub Actions CI/CD
- Static site generation
- Zero-cost hosting

### ☁️ Group 2: Cloudflare-Centric
Optimized for Cloudflare Pages frontend and Cloudflare Workers backend (edge computing).

- **cloudflare-main** - Production branch for Cloudflare Pages + Workers
- **cloudflare-development** - Active development for Cloudflare platform features
- **cloudflare-features** - Feature branches for edge computing capabilities
- **cloudflare-staging** - Pre-production testing for Cloudflare deployments

**Best For**: Global applications requiring low latency, serverless edge computing

**Key Features**:
- Edge computing in 300+ locations
- Auto-scaling with zero configuration
- Cloudflare Workers for backend API
- Global CDN with <50ms latency worldwide
- Cost-effective with generous free tier

### ⚡ Group 3: Azure-Centric
Optimized for Microsoft Azure cloud services (Azure Static Web Apps, Azure Functions, etc.).

- **azure-main** - Production branch for Azure deployments
- **azure-development** - Active development for Azure platform features
- **azure-features** - Feature branches for Azure integrations
- **azure-staging** - Pre-production testing for Azure deployments

**Best For**: Enterprise applications, Microsoft-stack integrations, hybrid cloud

**Key Features**:
- Azure Static Web Apps
- Azure Functions for serverless backend
- Azure DevOps integration
- Enterprise-grade security and compliance
- Integration with Microsoft 365, Active Directory

### ☁️ Group 4: AWS-Centric
Optimized for Amazon Web Services (S3 static hosting, Lambda, EC2, etc.).

- **aws-main** - Production branch for AWS deployments
- **aws-development** - Active development for AWS platform features
- **aws-features** - Feature branches for AWS services integration
- **aws-staging** - Pre-production testing for AWS deployments

**Best For**: Scalable applications, complex infrastructure, full AWS ecosystem

**Key Features**:
- S3 + CloudFront for static hosting
- Lambda for serverless functions
- EC2 for full-stack deployments
- RDS for managed databases
- Comprehensive AWS service ecosystem

## Branch Workflow

### Development Flow
```
features -> development -> staging -> main
```

1. **Features Branch**: New features and experiments
2. **Development Branch**: Integration and active development
3. **Staging Branch**: Pre-production testing and QA
4. **Main Branch**: Production-ready code

### Platform Selection
Choose your platform based on your requirements:

| Requirement | Recommended Platform |
|-------------|---------------------|
| Zero-cost hosting | GitHub |
| Global low latency | Cloudflare |
| Enterprise features | Azure |
| Full AWS ecosystem | AWS |
| Edge computing | Cloudflare |
| Static site only | GitHub or Cloudflare |
| Serverless backend | Cloudflare or AWS |
| Microsoft integration | Azure |

## Getting Started

### 1. Choose Your Platform
Select the platform group that best fits your needs (GitHub, Cloudflare, Azure, or AWS).

### 2. Clone the Repository
```bash
git clone https://github.com/Universal-Standard/SWARM.git
cd SWARM
```

### 3. Checkout Your Platform Branch
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

### 4. Follow Platform-Specific Setup
Each platform branch includes:
- Platform-specific configuration files
- Deployment guides in `docs/deployment/`
- Environment setup instructions
- CI/CD workflow templates

## Deployment Guides

Detailed deployment instructions are available in the `docs/deployment/` directory:

- **GitHub**: `docs/deployment/GITHUB_PAGES_DEPLOYMENT.md`
- **Cloudflare**: `docs/deployment/CLOUDFLARE_DEPLOYMENT.md`
- **Azure**: `docs/deployment/AZURE_DEPLOYMENT.md` (to be created)
- **AWS**: `docs/deployment/AWS_DEPLOYMENT.md` (to be created)

## Contributing

When contributing to this repository:

1. **Choose the appropriate platform branch** for your changes
2. **Create feature branches** from the platform's `features` branch
3. **Merge into development** after review
4. **Test in staging** before merging to main
5. **Follow platform-specific conventions** for configuration and deployment

## Branch Protection

All `main` and `staging` branches should have branch protection enabled:
- Require pull request reviews
- Require status checks to pass
- No direct pushes to main or staging
- Automated deployments triggered on merge

## Maintenance

### Syncing Common Code
Common code changes should be applied to all platform branches:
1. Make changes in one platform's development branch
2. Create PRs to sync changes to other platforms
3. Adapt platform-specific configurations as needed

### Platform-Specific Updates
Updates specific to one platform should remain in that platform's branches.

## Repository Structure

Each branch maintains the same general structure with platform-specific variations:

```
SWARM/
├── .github/              # CI/CD workflows (platform-specific)
├── client/               # Frontend application
├── server/               # Backend application
├── shared/               # Shared code
├── docs/                 # Documentation
│   ├── deployment/       # Platform-specific deployment guides
│   └── ...
├── wrangler.toml         # Cloudflare configuration
├── azure-pipelines.yml   # Azure configuration
├── .github/workflows/    # GitHub Actions or AWS CodePipeline
└── ...
```

## Benefits of Multi-Platform Strategy

1. **Flexibility**: Choose the best platform for your needs
2. **Experimentation**: Test different platforms without breaking production
3. **Optimization**: Platform-specific configurations for best performance
4. **Risk Management**: Diversify across multiple cloud providers
5. **Learning**: Gain experience with multiple cloud platforms

## Questions?

- Check the platform-specific documentation in `docs/deployment/`
- Review the general documentation in `docs/README.md`
- Open an issue for platform-specific questions

---

**Related Documentation**:
- [Repository Structure](REPOSITORY_STRUCTURE.md)
- [Getting Started](GETTING_STARTED.md)
- [Contributing Guide](CONTRIBUTING.md)
- [Multi-Platform Deployment](docs/deployment/MULTI_PLATFORM_DEPLOYMENT.md)
