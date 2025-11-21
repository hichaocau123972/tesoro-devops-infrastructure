# Getting Started Guide

This guide will help you set up and deploy the Tesoro XP infrastructure on Azure.

## Prerequisites

### Required Tools

1. **Azure CLI** (version 2.50.0 or higher)
   ```bash
   # Install on macOS
   brew install azure-cli

   # Install on Windows
   winget install Microsoft.AzureCLI

   # Verify installation
   az --version
   ```

2. **Azure Bicep**
   ```bash
   # Install (if not included with Azure CLI)
   az bicep install

   # Verify installation
   az bicep version
   ```

3. **Git**
   ```bash
   git --version
   ```

4. **PowerShell** (for Windows) or **Bash** (for macOS/Linux)

### Required Access

- Azure subscription with **Owner** or **Contributor** role
- Ability to create Azure AD service principals
- GitHub repository access with write permissions
- PagerDuty/OpsGenie account for on-call rotation (production)

## Initial Setup

### 1. Clone the Repository

```bash
git clone https://github.com/tesoro-xp/tesoro-devops-infrastructure.git
cd tesoro-devops-infrastructure
```

### 2. Authenticate to Azure

```bash
# Login to Azure
az login

# Set your subscription
az account set --subscription "Your-Subscription-Name"

# Verify
az account show
```

### 3. Create Service Principal for CI/CD

```bash
# Create service principal
az ad sp create-for-rbac \
  --name "tesoro-devops-sp" \
  --role contributor \
  --scopes /subscriptions/{subscription-id} \
  --sdk-auth

# Save the output - you'll need it for GitHub Secrets
```

### 4. Configure GitHub Secrets

Add the following secrets to your GitHub repository:

| Secret Name | Description | How to Get |
|-------------|-------------|------------|
| `AZURE_SUBSCRIPTION_ID` | Azure subscription ID | `az account show --query id -o tsv` |
| `AZURE_TENANT_ID` | Azure AD tenant ID | `az account show --query tenantId -o tsv` |
| `AZURE_CLIENT_ID` | Service principal client ID | From step 3 output |
| `AZURE_CLIENT_SECRET` | Service principal secret | From step 3 output |

**Setting up OIDC (Recommended)**:
```bash
# Create federated credential for GitHub Actions
az ad app federated-credential create \
  --id <application-id> \
  --parameters '{
    "name": "GitHubActionsOIDC",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:your-org/tesoro-devops-infrastructure:ref:refs/heads/main",
    "audiences": ["api://AzureADTokenExchange"]
  }'
```

## Deploy Your First Environment

### Development Environment

The easiest way to start is by deploying the development environment:

#### Option 1: Using PowerShell Script

```powershell
# Navigate to scripts directory
cd scripts/powershell

# Run deployment script
./Deploy-Infrastructure.ps1 -Environment dev -WhatIf

# Review changes, then deploy
./Deploy-Infrastructure.ps1 -Environment dev
```

#### Option 2: Using GitHub Actions

```bash
# Trigger workflow via GitHub CLI
gh workflow run deploy-infrastructure.yml -f environment=dev

# Monitor workflow
gh run watch
```

#### Option 3: Using Azure CLI Directly

```bash
# Deploy using Bicep
az deployment sub create \
  --name tesoro-dev-$(date +%Y%m%d-%H%M%S) \
  --location eastus \
  --template-file infrastructure/bicep/main.bicep \
  --parameters environment=dev location=eastus appName=tesoro
```

### Verify Deployment

```bash
# Run health check script
./scripts/bash/health-check.sh dev

# Check resources in Azure Portal
az resource list \
  --resource-group tesoro-dev-rg \
  --output table
```

## Post-Deployment Configuration

### 1. Update Key Vault Secrets

```bash
# Get Key Vault name
KV_NAME=$(az keyvault list \
  --resource-group tesoro-dev-rg \
  --query "[0].name" -o tsv)

# Set connection strings (replace with actual values)
az keyvault secret set \
  --vault-name $KV_NAME \
  --name sql-connection-string \
  --value "Server=tcp:tesoro-dev-sql.database.windows.net,1433;..."

az keyvault secret set \
  --vault-name $KV_NAME \
  --name redis-connection-string \
  --value "tesoro-dev-redis.redis.cache.windows.net:6380,password=..."
```

### 2. Configure Application Insights

```bash
# Get instrumentation key
az monitor app-insights component show \
  --resource-group tesoro-dev-rg \
  --app tesoro-dev-ai \
  --query "instrumentationKey" -o tsv
```

### 3. Set Up Monitoring Alerts

The deployment automatically creates basic alerts. To customize:

```bash
# List current alerts
az monitor metrics alert list \
  --resource-group tesoro-dev-rg \
  --output table

# Update alert threshold example
az monitor metrics alert update \
  --name tesoro-dev-cpu-alert \
  --resource-group tesoro-dev-rg \
  --condition "avg CpuPercentage > 90"
```

## Deploying Additional Environments

### Staging Environment

```bash
# Deploy staging (similar to dev but with production-like resources)
./scripts/powershell/Deploy-Infrastructure.ps1 -Environment staging
```

### Production Environment

⚠️ **Important**: Production requires additional approvals and careful planning.

1. **Pre-Production Checklist**:
   - [ ] All changes tested in dev and staging
   - [ ] Security scan completed
   - [ ] Disaster recovery plan documented
   - [ ] Team trained on runbooks
   - [ ] Monitoring and alerting verified
   - [ ] Backup strategy tested

2. **Deploy Production**:
   ```bash
   # Production deployments should go through GitHub Actions
   # with manual approval gates

   # Trigger via GitHub
   gh workflow run deploy-infrastructure.yml -f environment=production
   ```

3. **Post-Production Steps**:
   - Verify all health checks passing
   - Test disaster recovery procedures
   - Configure backup retention policies
   - Set up PagerDuty/OpsGenie rotations
   - Enable enhanced monitoring

## Common Tasks

### View Infrastructure State

```bash
# List all deployments
az deployment sub list \
  --query "[].{name: name, timestamp: properties.timestamp, state: properties.provisioningState}" \
  --output table

# View specific deployment
az deployment sub show \
  --name tesoro-dev-20251121-120000 \
  --query "properties.outputs"
```

### Update Infrastructure

```bash
# Make changes to Bicep files
vim infrastructure/bicep/modules/compute.bicep

# Preview changes
az deployment sub what-if \
  --location eastus \
  --template-file infrastructure/bicep/main.bicep \
  --parameters environment=dev

# Apply changes
az deployment sub create \
  --name tesoro-dev-update-$(date +%Y%m%d-%H%M%S) \
  --location eastus \
  --template-file infrastructure/bicep/main.bicep \
  --parameters environment=dev
```

### Scale Resources

```bash
# Scale App Service
az appservice plan update \
  --name tesoro-dev-asp \
  --resource-group tesoro-dev-rg \
  --number-of-workers 3

# Scale database (change SKU)
az sql db update \
  --server tesoro-dev-sql \
  --name tesoro-dev-db \
  --resource-group tesoro-dev-rg \
  --service-objective S2
```

### View Logs

```bash
# Stream application logs
az webapp log tail \
  --name tesoro-dev-app-<suffix> \
  --resource-group tesoro-dev-rg

# Query Application Insights
az monitor app-insights query \
  --app tesoro-dev-ai \
  --resource-group tesoro-dev-rg \
  --analytics-query "traces | where timestamp > ago(1h) | take 10"
```

## Troubleshooting

### Deployment Failures

1. **Check deployment logs**:
   ```bash
   az deployment sub show \
     --name <deployment-name> \
     --query "properties.error"
   ```

2. **Validate template**:
   ```bash
   az bicep build --file infrastructure/bicep/main.bicep
   ```

3. **Check resource quotas**:
   ```bash
   az vm list-usage --location eastus --output table
   ```

### Authentication Issues

```bash
# Clear token cache
az account clear

# Re-login
az login

# Verify permissions
az role assignment list \
  --assignee $(az ad signed-in-user show --query id -o tsv) \
  --output table
```

### Resource Not Found

```bash
# Check if resource group exists
az group exists --name tesoro-dev-rg

# List all resource groups
az group list --output table
```

## Best Practices

1. **Always test in dev first**: Never deploy directly to production
2. **Use What-If analysis**: Preview changes before applying
3. **Tag resources**: Helps with cost tracking and management
4. **Document changes**: Use ADRs for significant decisions
5. **Monitor costs**: Set up budget alerts in Azure
6. **Regular backups**: Verify backup and restore procedures monthly
7. **Security first**: Regular security scans and updates

## Cost Management

### Estimate Costs

```bash
# Use Azure Pricing Calculator
# https://azure.microsoft.com/pricing/calculator/

# Monitor current costs
az consumption usage list \
  --start-date $(date -d '1 month ago' '+%Y-%m-%d') \
  --end-date $(date '+%Y-%m-%d') \
  --query "[].{date: usageStart, cost: pretaxCost}" \
  --output table
```

### Optimize Costs

1. **Auto-shutdown dev environments**:
   ```bash
   # Stop dev resources after hours
   az webapp stop --name tesoro-dev-app --resource-group tesoro-dev-rg
   ```

2. **Use reserved instances** for production
3. **Right-size resources** based on actual usage
4. **Delete unused resources** regularly

## Getting Help

### Documentation
- [Architecture Overview](./architecture/overview.md)
- [Runbooks](./runbooks/README.md)
- [Security Best Practices](./security/best-practices.md)
- [Monitoring Guide](./monitoring/overview.md)

### Support Channels
- **DevOps Team**: devops-team@tesoro-xp.com
- **Slack**: #devops-help
- **On-Call**: See PagerDuty schedule

### External Resources
- [Azure Bicep Documentation](https://learn.microsoft.com/azure/azure-resource-manager/bicep/)
- [Azure Well-Architected Framework](https://learn.microsoft.com/azure/well-architected/)
- [Azure DevOps Best Practices](https://learn.microsoft.com/azure/devops/best-practices/)

## Next Steps

Now that you have the infrastructure deployed:

1. **Deploy Application**: Follow application deployment guide
2. **Set Up Monitoring**: Configure dashboards and alerts
3. **Run Load Tests**: Verify performance under load
4. **Configure Backups**: Test disaster recovery procedures
5. **Enable Auto-Scaling**: Set up scaling rules
6. **Security Hardening**: Complete security checklist
7. **Documentation**: Update team runbooks

## Appendix

### Useful Azure CLI Commands

```bash
# List all resources with tags
az resource list --query "[].{name: name, type: type, tags: tags}" --output table

# Get resource costs
az consumption usage list --output table

# Check service health
az rest --method get --url "https://management.azure.com/subscriptions/{subscription-id}/providers/Microsoft.ResourceHealth/availabilityStatuses?api-version=2022-10-01"

# Export resource group as template
az group export --name tesoro-dev-rg --output json > exported-template.json
```

### Environment Variables

Create a `.env` file for local development:

```bash
# Azure
export AZURE_SUBSCRIPTION_ID="your-subscription-id"
export AZURE_TENANT_ID="your-tenant-id"

# Tesoro
export TESORO_ENVIRONMENT="dev"
export TESORO_REGION="eastus"
```

Source it:
```bash
source .env
```
