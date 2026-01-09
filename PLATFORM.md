# AZURE Platform - MAIN Environment

## Quick Start
Production deployment on Azure Static Web Apps + Functions.

**Platform:** Azure Static Web Apps + Functions  
**Environment:** Production  
**Integration:** Full Azure ecosystem

## Deployment

### Prerequisites
```bash
# Install Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Login
az login
```

### Deploy
```bash
# Create resource group
az group create --name swarm-rg --location eastus

# Create Static Web App
az staticwebapp create \
  --name swarm-app \
  --resource-group swarm-rg \
  --source https://github.com/Universal-Standard/SWARM \
  --branch azure-main
```

## Platform Features
- **Frontend:** Azure Static Web Apps (global CDN)
- **Backend:** Azure Functions (serverless)
- **Database:** Azure SQL or Cosmos DB
- **Auth:** Azure AD B2C integration
- **Monitoring:** Application Insights

## Configuration Files
- `staticwebapp.config.json`: Static Web Apps config
- `host.json`: Azure Functions host config
- `.github/workflows/azure-static-web-apps.yml`: CI/CD

## Environment Variables
```bash
AZURE_STATIC_WEB_APPS_API_TOKEN=<deployment-token>
DATABASE_CONNECTION_STRING=<azure-sql-connection>
APPLICATION_INSIGHTS_KEY=<instrumentation-key>
```

## Enterprise Features
- Azure AD integration
- Managed identities
- Private endpoints
- Compliance certifications (SOC 2, HIPAA, etc.)

**Branch:** `azure-main` | **Platform:** `AZURE` | **Environment:** `PRODUCTION`