# Service Down Runbook

## Overview
This runbook guides you through responding to a critical service outage where the Tesoro XP platform is unavailable to users.

## Severity
**CRITICAL (P0)**

## Symptoms
- Health check endpoints returning 5xx errors or timing out
- Application Gateway showing all backend instances unhealthy
- Azure Monitor alerts: "Service Unavailable"
- User reports of inability to access the platform
- Synthetic monitoring showing 0% availability

## Prerequisites
- Azure Portal access (Contributor role minimum)
- Azure CLI installed and authenticated
- Access to Application Insights
- PagerDuty/Slack for communications

## Immediate Actions (First 5 Minutes)

### 1. Acknowledge the Incident
```bash
# Update incident status
# If using PagerDuty, acknowledge via mobile app or:
pd incident acknowledge --id <incident-id>
```

### 2. Create War Room
- Create dedicated Slack channel: `#incident-YYYY-MM-DD-service-down`
- Invite: DevOps team, Engineering lead, Product manager
- Post initial status update

### 3. Check Service Health
```bash
# Check App Service status
az webapp show \
  --name tesoro-production-app-<suffix> \
  --resource-group tesoro-production-rg \
  --query "{state: state, availabilityState: availabilityState}"

# Check Application Gateway backend health
az network application-gateway show-backend-health \
  --name tesoro-production-appgw \
  --resource-group tesoro-production-rg
```

## Diagnostic Steps

### 1. Verify Azure Service Health
```bash
# Check for Azure outages
az rest --method get \
  --url "https://management.azure.com/subscriptions/{subscription-id}/providers/Microsoft.ResourceHealth/availabilityStatuses?api-version=2022-10-01"
```
- **If Azure outage detected**: Document, notify stakeholders, wait for Azure resolution
- **If no Azure outage**: Continue to step 2

### 2. Check Recent Deployments
```bash
# List recent deployments
az deployment group list \
  --resource-group tesoro-production-rg \
  --query "[0:5].{name: name, timestamp: properties.timestamp, state: properties.provisioningState}"

# Check App Service deployment history
az webapp deployment list-publishing-profiles \
  --name tesoro-production-app-<suffix> \
  --resource-group tesoro-production-rg
```

**Was there a deployment in the last hour?**
- **Yes**: Likely deployment-related → Go to [Rollback Procedure](../deployment/rollback.md)
- **No**: Continue to step 3

### 3. Check Application Logs
```bash
# Stream application logs
az webapp log tail \
  --name tesoro-production-app-<suffix> \
  --resource-group tesoro-production-rg
```

Look for:
- Unhandled exceptions
- Dependency failures (database, cache, external APIs)
- Out of memory errors
- Startup failures

**In Azure Portal**:
1. Navigate to Application Insights
2. Go to Failures blade
3. Check exception count in last hour
4. Review stack traces for common patterns

### 4. Check Database Connectivity
```bash
# Check SQL Server status
az sql server show \
  --name tesoro-production-sql \
  --resource-group tesoro-production-rg \
  --query "{state: state, status: fullyQualifiedDomainName}"

# Test database connectivity from App Service
az webapp ssh \
  --name tesoro-production-app-<suffix> \
  --resource-group tesoro-production-rg

# Inside SSH session:
sqlcmd -S tesoro-production-sql.database.windows.net -U sqladmin -P <password> -Q "SELECT 1"
```

**If database is down**: Escalate to Database team, see [Database Failure](./database-failure.md)

### 5. Check Resource Limits
```bash
# Check CPU and Memory
az monitor metrics list \
  --resource /subscriptions/<sub-id>/resourceGroups/tesoro-production-rg/providers/Microsoft.Web/sites/tesoro-production-app \
  --metric "CpuPercentage" "MemoryPercentage" \
  --start-time $(date -u -d '1 hour ago' '+%Y-%m-%dT%H:%M:%S') \
  --interval PT1M \
  --aggregation Average
```

**If resources exhausted**: See [High CPU](../troubleshooting/high-cpu.md) or [Memory Leaks](../troubleshooting/memory-leaks.md)

## Resolution Steps

### Scenario A: Recent Deployment Caused Outage

1. **Initiate Rollback**
```bash
# Get previous deployment slot
az webapp deployment slot swap \
  --name tesoro-production-app-<suffix> \
  --resource-group tesoro-production-rg \
  --slot staging \
  --target-slot production \
  --action swap
```

2. **Verify Service Recovery**
```bash
# Check health endpoint
curl -I https://tesoro-production.azurewebsites.net/health

# Expected: HTTP/1.1 200 OK
```

3. **Monitor for 10 minutes** to ensure stability

### Scenario B: Application Crash Loop

1. **Restart App Service**
```bash
az webapp restart \
  --name tesoro-production-app-<suffix> \
  --resource-group tesoro-production-rg
```

2. **Monitor startup**
```bash
az webapp log tail \
  --name tesoro-production-app-<suffix> \
  --resource-group tesoro-production-rg
```

3. **If restart fails**: Scale out to add more instances
```bash
az appservice plan update \
  --name tesoro-production-asp \
  --resource-group tesoro-production-rg \
  --number-of-workers 5
```

### Scenario C: Database Connection Failure

1. **Verify connection string in Key Vault**
```bash
az keyvault secret show \
  --vault-name tesoro-production-kv \
  --name sql-connection-string \
  --query "value"
```

2. **Test database connectivity manually**
3. **Check firewall rules** (see step 4 in Diagnostics)
4. **Restart database if necessary** (requires approval)

### Scenario D: External Dependency Failure

1. **Identify failing dependency** from logs
2. **Enable circuit breaker** (if implemented)
3. **Switch to degraded mode** (if applicable)
4. **Contact vendor** for third-party APIs

### Scenario E: Azure Platform Issue

1. **Document Azure incident number**
2. **Open Azure support ticket** (Severity A)
3. **Implement workaround if possible**:
   - Redirect traffic to secondary region (if configured)
   - Enable static maintenance page
4. **Monitor Azure status page**: https://status.azure.com

## Communication Template

### Initial Notification (Within 15 min)
```
🚨 INCIDENT: Service Outage

Status: Investigating
Impact: All users unable to access Tesoro XP platform
Started: [timestamp]
ETA: Under investigation

Actions:
- War room created: #incident-YYYY-MM-DD-service-down
- On-call team engaged
- Diagnostics in progress

Next update: [15 minutes]
```

### Resolution Notification
```
✅ RESOLVED: Service Outage

Status: Resolved
Duration: [X minutes]
Root Cause: [Brief description]

Resolution:
- [What was done]
- Service confirmed healthy at [timestamp]

Follow-up:
- Post-mortem scheduled for [date/time]
- Action items to prevent recurrence
```

## Verification Steps

After resolution:

1. **Health Check**
```bash
curl https://tesoro-production.azurewebsites.net/health
# Expected: {"status": "healthy", "timestamp": "..."}
```

2. **End-to-End Test**
- Execute critical user journey (login → transaction → rewards)
- Verify all core features functional

3. **Monitor Metrics**
- Check Application Insights for error rate < 0.1%
- Verify response times normal (p95 < 500ms)
- Confirm database queries performing well

4. **Alert Status**
- Verify all alerts cleared in Azure Monitor
- Confirm availability test passing

## Rollback Plan

If resolution steps don't work:

1. Enable static maintenance page at CDN level
2. Page engineering leadership for emergency escalation
3. Consider failing over to disaster recovery region (if configured)
4. Engage Azure support with Severity A ticket

## Prevention

After incident resolution:

1. **Immediate**:
   - Add specific monitoring for root cause
   - Create alert for early warning signs
   - Update this runbook with learnings

2. **Short-term (1 week)**:
   - Implement automated rollback on health check failure
   - Add circuit breakers for external dependencies
   - Improve deployment validation

3. **Long-term (1 month)**:
   - Multi-region deployment for high availability
   - Chaos engineering to test failure scenarios
   - Enhanced observability for faster diagnosis

## Related Alerts
- `tesoro-production-availability-alert`
- `tesoro-production-http5xx-alert`
- `tesoro-production-response-time-alert`

## Escalation

**Cannot resolve within 30 minutes?**
1. Page Infrastructure Manager: +1-555-0102
2. Notify VP Engineering: +1-555-0103
3. Engage Azure Support: Severity A ticket
4. Consider external communication (status page, customer emails)

## Post-Incident Checklist

- [ ] Incident documented in tracking system
- [ ] Root cause identified and documented
- [ ] Post-mortem meeting scheduled (within 48 hours)
- [ ] Customer communication sent (if applicable)
- [ ] Action items created and assigned
- [ ] Runbook updated with learnings
- [ ] Monitoring/alerting improved
- [ ] On-call handoff note updated

## References
- [Azure App Service Diagnostics](https://learn.microsoft.com/azure/app-service/overview-diagnostics)
- [Application Insights Failure Analysis](https://learn.microsoft.com/azure/azure-monitor/app/failures)
- [Rollback Procedure](../deployment/rollback.md)
- [Database Failure Runbook](./database-failure.md)
