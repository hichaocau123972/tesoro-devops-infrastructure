# Production Deployment Runbook

## Overview
This runbook provides step-by-step instructions for deploying infrastructure and application changes to the production environment.

## Severity
**HIGH** - Production changes require careful execution

## Prerequisites

### Required Access
- Azure Contributor role on production subscription
- GitHub repository write access
- Access to production Key Vault secrets
- Approval from at least one senior engineer

### Pre-Deployment Checklist
- [ ] All changes code reviewed and approved
- [ ] CI/CD pipeline passing all tests
- [ ] Security scan completed (no critical/high vulnerabilities)
- [ ] Staging environment tested successfully
- [ ] Database migration scripts tested (if applicable)
- [ ] Rollback plan documented
- [ ] Change notification sent to stakeholders
- [ ] Deployment window scheduled (business hours preferred)
- [ ] On-call engineer identified and available

### Tools Required
- Azure CLI (latest version)
- Git
- Access to GitHub Actions
- Slack for communication

## Deployment Types

### Type 1: Infrastructure-Only Deployment
Changes to Azure resources (networking, databases, scaling configuration)

### Type 2: Application-Only Deployment
Code changes, application configuration updates

### Type 3: Full Deployment
Both infrastructure and application changes

## Deployment Process

### Phase 1: Pre-Deployment (15-30 min before)

#### 1. Announce Deployment
Post in Slack #deployments channel:
```
🚀 Production Deployment Starting

Type: [Infrastructure / Application / Full]
ETA: [duration]
Changes: [brief description]
Deployer: @your-name
On-call backup: @backup-name
Rollback plan: Ready

#deployment #production
```

#### 2. Create Deployment Tracking Issue
```bash
# Create GitHub issue for tracking
gh issue create \
  --title "Production Deployment - $(date +%Y-%m-%d)" \
  --body "Deployment checklist and tracking" \
  --label "deployment,production"
```

#### 3. Verify Pre-Conditions
```bash
# Check current production health
az webapp show \
  --name tesoro-production-app-<suffix> \
  --resource-group tesoro-production-rg \
  --query "state"

# Verify no active incidents
# Check: https://status.azure.com
# Check: PagerDuty for active alerts

# Confirm staging environment healthy
az webapp show \
  --name tesoro-staging-app-<suffix> \
  --resource-group tesoro-staging-rg \
  --query "state"
```

#### 4. Take Pre-Deployment Snapshot
```bash
# Document current state
az deployment group list \
  --resource-group tesoro-production-rg \
  --query "[0].{name: name, timestamp: properties.timestamp}" \
  > pre-deployment-state.json

# Capture current metrics baseline
az monitor metrics list \
  --resource <app-service-resource-id> \
  --metric "Http5xx" "AverageResponseTime" \
  --start-time $(date -u -d '1 hour ago' '+%Y-%m-%dT%H:%M:%S') \
  --interval PT5M \
  > pre-deployment-metrics.json
```

### Phase 2: Infrastructure Deployment (If Applicable)

#### 1. Trigger Infrastructure Deployment
Via GitHub Actions:
```bash
# Option A: Via GitHub CLI
gh workflow run deploy-infrastructure.yml \
  -f environment=production

# Option B: Via Azure Portal
# Navigate to GitHub Actions → Deploy Infrastructure → Run workflow
```

#### 2. Monitor Deployment Progress
```bash
# Watch workflow execution
gh run watch

# Monitor Azure deployment
az deployment group list \
  --resource-group tesoro-production-rg \
  --query "[0].properties.provisioningState"
```

#### 3. Validate Infrastructure Changes
```bash
# Check deployment outputs
az deployment group show \
  --name <deployment-name> \
  --resource-group tesoro-production-rg \
  --query "properties.outputs"

# Verify resources created/updated
az resource list \
  --resource-group tesoro-production-rg \
  --output table
```

**Expected duration**: 10-20 minutes

### Phase 3: Application Deployment

#### 1. Create Deployment Slot (Blue-Green Strategy)
```bash
# Create staging slot if not exists
az webapp deployment slot create \
  --name tesoro-production-app-<suffix> \
  --resource-group tesoro-production-rg \
  --slot blue

# Deploy to blue slot
az webapp deployment source config-zip \
  --name tesoro-production-app-<suffix> \
  --resource-group tesoro-production-rg \
  --slot blue \
  --src ./deployment-package.zip
```

#### 2. Warm Up Staging Slot
```bash
# Get slot URL
SLOT_URL=$(az webapp deployment slot list \
  --name tesoro-production-app-<suffix> \
  --resource-group tesoro-production-rg \
  --query "[?name=='blue'].defaultHostName" -o tsv)

# Warm up application
for i in {1..10}; do
  curl -s "https://${SLOT_URL}/health" > /dev/null
  echo "Warmup request $i completed"
  sleep 2
done
```

#### 3. Run Smoke Tests on Slot
```bash
# Health check
HEALTH_STATUS=$(curl -s "https://${SLOT_URL}/health" | jq -r '.status')

if [ "$HEALTH_STATUS" != "healthy" ]; then
  echo "❌ Health check failed! Aborting deployment."
  exit 1
fi

# Test critical endpoints
curl -f "https://${SLOT_URL}/api/rewards/status" || exit 1
curl -f "https://${SLOT_URL}/api/transactions/health" || exit 1

echo "✅ Smoke tests passed"
```

#### 4. Swap Deployment Slots
```bash
# Perform slot swap (zero-downtime)
az webapp deployment slot swap \
  --name tesoro-production-app-<suffix> \
  --resource-group tesoro-production-rg \
  --slot blue \
  --target-slot production

echo "🔄 Slot swap completed"
```

**Expected duration**: 5-10 minutes

### Phase 4: Database Migration (If Applicable)

⚠️ **CRITICAL**: Always test migrations in staging first!

#### 1. Backup Production Database
```bash
# Create manual backup before migration
az sql db export \
  --server tesoro-production-sql \
  --name tesoro-production-db \
  --admin-user sqladmin \
  --admin-password <password> \
  --storage-key <storage-key> \
  --storage-key-type StorageAccessKey \
  --storage-uri "https://tesoroprodst.blob.core.windows.net/backups/pre-migration-$(date +%Y%m%d-%H%M%S).bacpac"
```

#### 2. Run Migration Scripts
```bash
# Connect to database
az sql db execute \
  --server tesoro-production-sql \
  --name tesoro-production-db \
  --admin-user sqladmin \
  --admin-password <password> \
  --query-file ./migrations/V001__add_rewards_table.sql

# Verify migration
az sql db execute \
  --server tesoro-production-sql \
  --name tesoro-production-db \
  --admin-user sqladmin \
  --admin-password <password> \
  --query "SELECT * FROM __MigrationHistory ORDER BY AppliedOn DESC"
```

#### 3. Validate Data Integrity
```bash
# Run validation queries
az sql db execute \
  --server tesoro-production-sql \
  --name tesoro-production-db \
  --admin-user sqladmin \
  --admin-password <password> \
  --query-file ./migrations/verify.sql
```

**Expected duration**: 5-30 minutes (depending on migration complexity)

### Phase 5: Post-Deployment Validation

#### 1. Immediate Health Checks (0-5 min)
```bash
# Check application health
curl -f https://tesoro-production.azurewebsites.net/health

# Check API endpoints
curl -f https://tesoro-production.azurewebsites.net/api/health

# Verify database connectivity
curl -f https://tesoro-production.azurewebsites.net/api/diagnostics/database
```

#### 2. Monitor Error Rates (5-10 min)
```bash
# Check Application Insights for errors
az monitor app-insights metrics show \
  --app tesoro-production-ai \
  --resource-group tesoro-production-rg \
  --metric "exceptions/count" \
  --start-time $(date -u -d '10 minutes ago' '+%Y-%m-%dT%H:%M:%S') \
  --interval PT1M
```

Expected: Error rate < 0.1%

#### 3. Performance Validation (10-15 min)
```bash
# Check response times
az monitor app-insights metrics show \
  --app tesoro-production-ai \
  --resource-group tesoro-production-rg \
  --metric "requests/duration" \
  --start-time $(date -u -d '15 minutes ago' '+%Y-%m-%dT%H:%M:%S') \
  --interval PT1M \
  --aggregation avg
```

Expected: p95 < 500ms

#### 4. End-to-End Testing (15-20 min)
```bash
# Run automated E2E tests
cd tests/e2e
npm run test:production

# Manual critical path test:
# 1. User login
# 2. Create transaction
# 3. Process reward
# 4. Verify reward recorded
```

#### 5. Monitor Business Metrics (20-30 min)
- Check transaction processing rate
- Verify rewards are being calculated
- Confirm no spike in customer support tickets
- Review real-time user activity

### Phase 6: Communication & Documentation

#### 1. Announce Successful Deployment
Post in Slack #deployments:
```
✅ Production Deployment Complete

Status: Successful
Duration: [X minutes]
Deployed: [commit hash / version]
Changes: [summary]

Health checks: ✅ Passing
Performance: ✅ Normal
Errors: ✅ < 0.1%

Deployed by: @your-name
```

#### 2. Update Documentation
```bash
# Tag release in Git
git tag -a v1.2.3 -m "Production release 2025-11-21"
git push origin v1.2.3

# Update deployment log
echo "$(date -u +%Y-%m-%d\ %H:%M:%S) - v1.2.3 deployed to production" \
  >> deployments.log
```

#### 3. Close Deployment Issue
```bash
gh issue close <issue-number> \
  --comment "Deployment completed successfully. All health checks passing."
```

## Rollback Procedure

**If issues detected within 30 minutes of deployment:**

### Quick Rollback (Application)
```bash
# Swap slots back
az webapp deployment slot swap \
  --name tesoro-production-app-<suffix> \
  --resource-group tesoro-production-rg \
  --slot production \
  --target-slot blue

echo "🔙 Rollback completed"
```

### Infrastructure Rollback
See [Rollback Runbook](./rollback.md) for detailed steps

### Database Rollback
⚠️ **CRITICAL**: Database rollbacks are complex
1. Stop application traffic
2. Restore from backup
3. Review data loss implications
4. Coordinate with engineering leadership

## Deployment Timing

### Preferred Windows
- **Best**: Tuesday-Thursday, 10 AM - 2 PM PT
- **Acceptable**: Monday-Friday, 9 AM - 4 PM PT
- **Avoid**: Fridays after 2 PM, weekends, holidays, end of month

### Deployment Freeze Periods
- Black Friday / Cyber Monday week
- End of quarter (last 3 days)
- Major holiday periods
- During active incidents

## Emergency Deployment

For critical hotfixes only:

1. **Approval Required**: VP Engineering or Director
2. **Minimal Changes**: Only what's necessary to fix issue
3. **Expedited Testing**: Focus on critical path
4. **Enhanced Monitoring**: Watch closely for 2 hours post-deployment
5. **Post-Mortem**: Why was emergency deployment needed?

## Common Issues

### Issue: Slot Swap Fails
```bash
# Check slot configuration
az webapp config appsettings list \
  --name tesoro-production-app-<suffix> \
  --resource-group tesoro-production-rg \
  --slot blue

# Verify slot is healthy
az webapp show \
  --name tesoro-production-app-<suffix> \
  --resource-group tesoro-production-rg \
  --slot blue \
  --query "state"
```

### Issue: Database Migration Fails
1. **STOP IMMEDIATELY** - Do not proceed with app deployment
2. Restore database from pre-migration backup
3. Review migration script for errors
4. Test in staging environment
5. Reschedule deployment

### Issue: Performance Degradation After Deployment
1. Check resource utilization (CPU, memory)
2. Review slow query logs
3. Compare metrics to baseline
4. If > 2x baseline response time: Consider rollback
5. Investigate and fix, or rollback

## Post-Deployment Monitoring

### First Hour: Active Monitoring
- Watch Application Insights live metrics
- Monitor error rates and exceptions
- Check response time trends
- Review database performance

### First 24 Hours: Enhanced Monitoring
- Automated alerts active
- On-call engineer aware
- Business metrics tracking
- Customer feedback monitoring

### First Week: Trend Analysis
- Compare KPIs week-over-week
- Review customer support tickets
- Analyze performance trends
- Plan optimizations if needed

## Metrics for Success

| Metric | Target | Action if Exceeded |
|--------|--------|-------------------|
| Error Rate | < 0.1% | Investigate immediately |
| Response Time | p95 < 500ms | Review performance |
| Availability | > 99.99% | Check health endpoints |
| Rollback Rate | < 5% | Review deployment process |

## References
- [Rollback Procedure](./rollback.md)
- [Database Migration Guide](./database-migration.md)
- [Blue-Green Deployment](./blue-green.md)
- [Azure App Service Deployment](https://learn.microsoft.com/azure/app-service/deploy-best-practices)

## Contacts
- **DevOps Lead**: devops-lead@tesoro-xp.com
- **Engineering Manager**: eng-manager@tesoro-xp.com
- **On-Call**: See PagerDuty schedule
