# AZURE Platform - FEATURES Environment

**Platform:** Azure Static Web Apps + Functions  
**Environment:** Feature Integration  
**Purpose:** Test Azure service integrations

## Deployment
```bash
az staticwebapp create \
  --name swarm-features \
  --resource-group swarm-features-rg \
  --branch azure-features
```

## Testing Focus
- Azure Functions integration
- Cosmos DB performance
- Service Bus messaging
- Event Grid triggers

**Branch:** `azure-features` | **Platform:** `AZURE` | **Environment:** `FEATURES`