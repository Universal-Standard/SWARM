# AZURE Platform - DEVELOPMENT Environment

**Platform:** Azure Static Web Apps + Functions  
**Environment:** Development/Testing  
**Purpose:** Azure ecosystem development and testing

## Deployment
```bash
az staticwebapp create \
  --name swarm-dev \
  --resource-group swarm-dev-rg \
  --branch azure-development
```

## Configuration
- Development Function Apps
- Test Azure SQL database
- Development slot deployment
- Verbose Application Insights logging

**Branch:** `azure-development` | **Platform:** `AZURE` | **Environment:** `DEVELOPMENT`