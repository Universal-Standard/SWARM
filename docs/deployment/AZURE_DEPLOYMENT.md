# Azure Deployment Guide

Deploy PROJECT-SWARM to Microsoft Azure using Azure Static Web Apps for the frontend and Azure Functions for the backend.

## Overview

Azure deployment provides enterprise-grade hosting with:
- ✅ Azure Static Web Apps for frontend
- ✅ Azure Functions for serverless backend
- ✅ Azure DevOps integration
- ✅ Enterprise security and compliance
- ✅ Microsoft 365 and Active Directory integration
- ✅ Global CDN
- ✅ Automatic SSL certificates
- ✅ Custom domains

## Prerequisites

- **Azure Account**: [Create free account](https://azure.microsoft.com/free/)
- **Azure CLI**: [Install Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli)
- **Node.js 22+**: Required for building the application
- **Git**: For deployment

## Cost Estimate

**Azure Static Web Apps**:
- Free tier: $0/month (100 GB bandwidth, 0.5 GB storage)
- Standard tier: ~$9/month (100 GB bandwidth included, then $0.15/GB)

**Azure Functions**:
- Consumption plan: Pay per execution (~$0/month for low traffic)
- Premium plan: ~$150+/month (for always-on, VNet integration)

**Total estimated cost**: $0-20/month for small to medium applications

## Quick Start

### 1. Install Azure CLI
```bash
# macOS
brew install azure-cli

# Windows
winget install Microsoft.AzureCLI

# Linux
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

### 2. Login to Azure
```bash
az login
```

### 3. Create Resource Group
```bash
az group create \
  --name swarm-rg \
  --location eastus
```

### 4. Deploy Static Web App
```bash
# Install Static Web Apps CLI
npm install -g @azure/static-web-apps-cli

# Create Static Web App
az staticwebapp create \
  --name swarm-app \
  --resource-group swarm-rg \
  --source https://github.com/YOUR_USERNAME/SWARM \
  --location eastus \
  --branch azure-main \
  --app-location "client" \
  --output-location "dist"
```

### 5. Configure Environment Variables
```bash
# Set environment variables in Azure Portal
# or use Azure CLI:
az staticwebapp appsettings set \
  --name swarm-app \
  --setting-names \
    DATABASE_URL=your_database_url \
    OPENAI_API_KEY=your_openai_key
```

## Detailed Setup

### Frontend Deployment (Azure Static Web Apps)

#### Via Azure Portal

1. **Navigate to Azure Portal**
   - Go to [portal.azure.com](https://portal.azure.com)
   - Click "Create a resource"
   - Search for "Static Web App"

2. **Configure Basic Settings**
   - Subscription: Select your subscription
   - Resource Group: Create new or select existing
   - Name: `swarm-app`
   - Plan type: Free or Standard
   - Region: Choose closest to your users

3. **Configure Deployment**
   - Source: GitHub
   - Organization: Your GitHub username
   - Repository: SWARM
   - Branch: `azure-main`
   - Build presets: Custom
   - App location: `/client`
   - Output location: `dist`

4. **Review and Create**
   - Review settings
   - Click "Create"
   - Wait 2-5 minutes for deployment

#### Via GitHub Actions

Azure Static Web Apps automatically creates a GitHub Actions workflow:

```yaml
# .github/workflows/azure-static-web-apps.yml
name: Azure Static Web Apps CI/CD

on:
  push:
    branches:
      - azure-main
      - azure-staging
  pull_request:
    types: [opened, synchronize, reopened, closed]
    branches:
      - azure-main

jobs:
  build_and_deploy_job:
    runs-on: ubuntu-latest
    name: Build and Deploy Job
    steps:
      - uses: actions/checkout@v3
        with:
          submodules: true

      - name: Build And Deploy
        uses: Azure/static-web-apps-deploy@v1
        with:
          azure_static_web_apps_api_token: ${{ secrets.AZURE_STATIC_WEB_APPS_API_TOKEN }}
          repo_token: ${{ secrets.GITHUB_TOKEN }}
          action: "upload"
          app_location: "/client"
          output_location: "dist"
```

### Backend Deployment (Azure Functions)

#### 1. Create Function App
```bash
# Create storage account (required for Functions)
az storage account create \
  --name swarmfuncstorage \
  --resource-group swarm-rg \
  --location eastus \
  --sku Standard_LRS

# Create Function App
az functionapp create \
  --resource-group swarm-rg \
  --consumption-plan-location eastus \
  --runtime node \
  --runtime-version 20 \
  --functions-version 4 \
  --name swarm-functions \
  --storage-account swarmfuncstorage
```

#### 2. Configure Functions
Create `azure-functions/host.json`:
```json
{
  "version": "2.0",
  "extensions": {
    "http": {
      "routePrefix": "api"
    }
  }
}
```

Create `azure-functions/function.json`:
```json
{
  "bindings": [
    {
      "authLevel": "anonymous",
      "type": "httpTrigger",
      "direction": "in",
      "name": "req",
      "methods": ["get", "post", "put", "delete"]
    },
    {
      "type": "http",
      "direction": "out",
      "name": "res"
    }
  ]
}
```

#### 3. Deploy Functions
```bash
# Install Azure Functions Core Tools
npm install -g azure-functions-core-tools@4

# Deploy functions
cd azure-functions
func azure functionapp publish swarm-functions
```

### Database Setup

#### Option 1: Azure Database for PostgreSQL
```bash
# Create PostgreSQL server
az postgres flexible-server create \
  --resource-group swarm-rg \
  --name swarm-db \
  --location eastus \
  --admin-user swarmadmin \
  --admin-password YourSecurePassword123! \
  --sku-name Standard_B1ms \
  --storage-size 32

# Get connection string
az postgres flexible-server show-connection-string \
  --server-name swarm-db
```

#### Option 2: Use Neon or Supabase
Configure the DATABASE_URL environment variable with your external PostgreSQL connection string.

### Custom Domain Configuration

#### Add Custom Domain
```bash
# Add custom domain
az staticwebapp hostname set \
  --name swarm-app \
  --resource-group swarm-rg \
  --hostname yourdomain.com

# Validate domain
az staticwebapp hostname show \
  --name swarm-app \
  --resource-group swarm-rg \
  --hostname yourdomain.com
```

#### Configure DNS
Add these records to your DNS provider:
```
Type: CNAME
Name: www
Value: your-app.azurestaticapps.net

Type: TXT
Name: @
Value: (validation token from Azure)
```

## Environment Variables

Configure in Azure Portal or via CLI:

```bash
az staticwebapp appsettings set \
  --name swarm-app \
  --setting-names \
    DATABASE_URL="postgresql://user:pass@host/db" \
    OPENAI_API_KEY="sk-..." \
    ANTHROPIC_API_KEY="sk-ant-..." \
    GOOGLE_GENAI_API_KEY="..." \
    SESSION_SECRET="your-secret-key" \
    NODE_ENV="production"
```

## CI/CD Setup

### Azure DevOps Pipeline

Create `azure-pipelines.yml`:
```yaml
trigger:
  branches:
    include:
      - azure-main
      - azure-staging

pool:
  vmImage: 'ubuntu-latest'

steps:
  - task: NodeTool@0
    inputs:
      versionSpec: '22.x'
    displayName: 'Install Node.js'

  - script: |
      npm ci
      npm run build
    displayName: 'npm install and build'

  - task: AzureStaticWebApp@0
    inputs:
      app_location: '/client'
      output_location: 'dist'
      azure_static_web_apps_api_token: $(AZURE_STATIC_WEB_APPS_API_TOKEN)
```

## Monitoring and Logging

### Application Insights

```bash
# Create Application Insights
az monitor app-insights component create \
  --app swarm-insights \
  --location eastus \
  --resource-group swarm-rg

# Get instrumentation key
az monitor app-insights component show \
  --app swarm-insights \
  --resource-group swarm-rg \
  --query instrumentationKey
```

Add to environment variables:
```bash
APPLICATIONINSIGHTS_CONNECTION_STRING="InstrumentationKey=your-key"
```

### View Logs
```bash
# View application logs
az staticwebapp logs show \
  --name swarm-app \
  --resource-group swarm-rg

# View function logs
az webapp log tail \
  --name swarm-functions \
  --resource-group swarm-rg
```

## Security

### Enable Authentication

Azure Static Web Apps supports built-in authentication:

1. Navigate to your Static Web App in Azure Portal
2. Go to "Authentication" section
3. Enable providers (Microsoft, GitHub, Google, etc.)
4. Configure redirect URLs

### Configure CORS
```bash
az functionapp cors add \
  --name swarm-functions \
  --resource-group swarm-rg \
  --allowed-origins https://your-app.azurestaticapps.net
```

## Scaling

### Static Web App Scaling
- Automatically scales (no configuration needed)
- Global CDN distribution

### Function App Scaling
```bash
# Scale to Premium plan for better performance
az functionapp plan create \
  --resource-group swarm-rg \
  --name swarm-premium-plan \
  --location eastus \
  --sku EP1 \
  --is-linux

az functionapp update \
  --resource-group swarm-rg \
  --name swarm-functions \
  --plan swarm-premium-plan
```

## Troubleshooting

### Build Fails
```bash
# Check build logs in Azure Portal
# Or use CLI:
az staticwebapp show \
  --name swarm-app \
  --resource-group swarm-rg
```

### Functions Not Working
```bash
# Check function app logs
az webapp log tail \
  --name swarm-functions \
  --resource-group swarm-rg

# Restart function app
az functionapp restart \
  --name swarm-functions \
  --resource-group swarm-rg
```

### Database Connection Issues
- Verify connection string in environment variables
- Check firewall rules allow Azure services
- Verify database credentials

## Cleanup

To remove all resources:
```bash
# Delete entire resource group
az group delete --name swarm-rg --yes
```

## Resources

- [Azure Static Web Apps Documentation](https://docs.microsoft.com/azure/static-web-apps/)
- [Azure Functions Documentation](https://docs.microsoft.com/azure/azure-functions/)
- [Azure Database for PostgreSQL](https://docs.microsoft.com/azure/postgresql/)
- [Azure DevOps](https://dev.azure.com/)

## Support

- Azure Support: [support.microsoft.com](https://support.microsoft.com)
- Repository Issues: [GitHub Issues](https://github.com/Universal-Standard/SWARM/issues)

---

**Next Steps**:
- Configure environment variables
- Set up custom domain
- Enable Application Insights
- Configure Azure DevOps pipeline
