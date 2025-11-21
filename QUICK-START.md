# Quick Start - Tesoro DevOps Infrastructure

## 🚀 Get Started in 5 Minutes

### 1. Prerequisites Check
```bash
# Verify tools installed
az --version          # Azure CLI 2.50+
az bicep version      # Bicep
git --version         # Git

# Login to Azure
az login
az account set --subscription "Your-Subscription-Name"
```

### 2. Deploy Development Environment
```bash
# Option A: Using PowerShell (Windows/macOS/Linux)
cd scripts/powershell
./Deploy-Infrastructure.ps1 -Environment dev

# Option B: Using Azure CLI directly
az deployment sub create \
  --name tesoro-dev-$(date +%Y%m%d-%H%M%S) \
  --location eastus \
  --template-file infrastructure/bicep/main.bicep \
  --parameters environment=dev location=eastus appName=tesoro
```

### 3. Verify Deployment
```bash
# Run health checks
./scripts/bash/health-check.sh dev

# View resources
az resource list --resource-group tesoro-dev-rg --output table
```

## 📋 Common Commands

### Infrastructure Management
```bash
# Preview changes (what-if)
az deployment sub what-if \
  --location eastus \
  --template-file infrastructure/bicep/main.bicep \
  --parameters environment=dev

# View deployment history
az deployment sub list --output table

# Delete environment (dev only!)
az group delete --name tesoro-dev-rg --yes
```

### Monitoring
```bash
# Check App Service logs
az webapp log tail \
  --name tesoro-dev-app-<suffix> \
  --resource-group tesoro-dev-rg

# Query Application Insights
az monitor app-insights query \
  --app tesoro-dev-ai \
  --resource-group tesoro-dev-rg \
  --analytics-query "requests | take 10"
```

### Secrets Management
```bash
# Set secret in Key Vault
az keyvault secret set \
  --vault-name tesoro-dev-kv-<suffix> \
  --name my-secret \
  --value "secret-value"

# Get secret
az keyvault secret show \
  --vault-name tesoro-dev-kv-<suffix> \
  --name my-secret \
  --query value -o tsv
```

## 📚 Key Documentation

| Document | Purpose |
|----------|---------|
| [PROJECT-SUMMARY.md](PROJECT-SUMMARY.md) | Complete project overview |
| [README.md](README.md) | Repository introduction |
| [Getting Started](docs/getting-started.md) | Detailed setup guide |
| [Architecture](docs/architecture/overview.md) | System design |
| [Runbooks](docs/runbooks/README.md) | Operational procedures |
| [Security](docs/security/best-practices.md) | Security guidelines |

## 🔥 Emergency Procedures

### Service Down
See: [docs/runbooks/emergency/service-down.md](docs/runbooks/emergency/service-down.md)

Quick steps:
1. Check Azure service health
2. Review recent deployments
3. Check application logs
4. Rollback if needed

### Rollback Deployment
```bash
# Swap deployment slots
az webapp deployment slot swap \
  --name tesoro-production-app-<suffix> \
  --resource-group tesoro-production-rg \
  --slot staging \
  --target-slot production
```

## 🛠 Useful Scripts

| Script | Purpose | Usage |
|--------|---------|-------|
| `scripts/powershell/Deploy-Infrastructure.ps1` | Deploy infrastructure | `./Deploy-Infrastructure.ps1 -Environment dev` |
| `scripts/bash/health-check.sh` | Check system health | `./health-check.sh production` |

## 🎯 Deployment Workflow

```
1. Develop → Test locally
2. Create PR → Ephemeral environment auto-deployed
3. Merge to develop → Auto-deploy to dev
4. Merge to main → Auto-deploy to staging
5. Manual approval → Deploy to production
```

## 💡 Tips & Best Practices

✅ **Always test in dev first** - Never skip environments
✅ **Use what-if before deploying** - Preview changes
✅ **Check health after deployment** - Run health-check.sh
✅ **Monitor for 30 minutes** - Watch for issues
✅ **Document incidents** - Update runbooks

## 🆘 Getting Help

- **Documentation**: Check `/docs` directory
- **Runbooks**: See `/docs/runbooks` for procedures
- **Issues**: Create GitHub issue
- **Questions**: devops-team@tesoro-xp.com

## 📊 Environment URLs

After deployment, your environments will be available at:

- **Dev**: https://tesoro-dev-app-{suffix}.azurewebsites.net
- **Staging**: https://tesoro-staging-app-{suffix}.azurewebsites.net
- **Production**: https://tesoro-production-app-{suffix}.azurewebsites.net

Replace `{suffix}` with the unique suffix from deployment outputs.

## 🔒 Security Checklist

Before deploying to production:

- [ ] All secrets in Key Vault
- [ ] Private endpoints configured
- [ ] HTTPS enforced
- [ ] TLS 1.2+ minimum
- [ ] Network isolation enabled
- [ ] Monitoring alerts configured
- [ ] Backup strategy tested
- [ ] Incident response plan ready

## 📈 Success Criteria

Your deployment is successful when:

- ✅ Health check script passes
- ✅ Application responds to /health endpoint
- ✅ Database connectivity verified
- ✅ Monitoring dashboards populated
- ✅ Alerts configured and tested
- ✅ No errors in Application Insights

---

**Ready to deploy?** Start with the development environment and work your way up!

For detailed instructions, see [Getting Started Guide](docs/getting-started.md)
