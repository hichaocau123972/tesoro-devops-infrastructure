# Tesoro XP Infrastructure - Deployment Status

**Last Updated**: 2025-11-22
**Environment**: Development (dev)
**Region**: US East
**Subscription**: Pay-As-You-Go (Upgraded)

---

## Current Status: ⚠️ Partial Deployment Pending

### ✅ Completed Actions

1. **Upgraded to Pay-As-You-Go** ✅
   - Subscription type: Azure subscription 1
   - Payment method: Credit card on file
   - Status: Active

2. **Set Up Budget Alerts** ✅
   - Monthly budget: $100
   - Email alerts at: 50% ($50), 75% ($75), 90% ($90)
   - Contact: dennis.brady@skyeluxtechnology.com
   - View in Portal: Cost Management + Billing → Budgets → tesoro-monthly-budget

3. **Region Selection** ✅
   - Primary region: **US East** (30% cheaper than Australia Central)
   - Deleted Australia Central resources (including expensive Redis Cache ~$75/month)

4. **Template Updates** ✅
   - Updated `main.bicep` default location to `eastus`
   - Changed App Service from B2 (Basic) to S1 (Standard) for quota compatibility
   - Commented out database module (SQL/PostgreSQL) due to provisioning restrictions

5. **Key Vault Soft Delete Management** ✅
   - Purged deleted Key Vault from Australia Central
   - Name `tesorodevkvyc6ih4pl` is now available for reuse

---

## ⚠️ Remaining Issues

### 1. Database Provisioning Restrictions

**Even on Pay-As-You-Go, SQL Database and PostgreSQL provisioning are restricted.**

```
Error: ProvisioningDisabled
Message: Provisioning is restricted in this region. Please choose a different region.
For exceptions to this rule please open a support request with Issue type of 'Service and subscription limits'.
```

**Status**: Requires quota increase request (see guide at `docs/azure-quota-increase-guide.md`)

**Affected Resources**:
- ❌ Azure SQL Database (Basic tier)
- ❌ PostgreSQL Flexible Server (Burstable B1ms)

**Temporary Solution**: Database module commented out in `main.bicep` (lines 71-91)

### 2. App Service Quota

**Original Issue**: Basic VMs quota was 0
**Resolution**: Changed from B2 (Basic) to S1 (Standard) tier in `compute.bicep`
**Current Quota**: Standard family has sufficient quota (10 vCPUs available)

---

## 📋 Next Steps

### Immediate (Can Do Now)

1. **Wait for resource group deletion to complete** (in progress)
   - Current RG `tesoro-dev-rg` is being deleted
   - Contains: VNet, Storage, Redis Cache ($75/month), Key Vault, Managed Identities
   - Estimated time: 5-10 minutes

2. **Deploy infrastructure without databases**
   ```bash
   az deployment sub create \
     --location eastus \
     --name "tesoro-dev-$(date +%Y%m%d-%H%M%S)" \
     --template-file infrastructure/bicep/main.bicep \
     --parameters environment=dev appName=tesoro
   ```

3. **Verify deployment**
   - Expected resources: VNet, Storage, Redis, Key Vault, App Service, Log Analytics, Monitoring
   - Estimated cost: ~$90-100/month (includes Redis Cache Standard ~$75)

### Medium Term (1-3 Business Days)

4. **Request Database Quota Increases**
   - Follow guide: `docs/azure-quota-increase-guide.md`
   - Services needed:
     - Azure SQL Database provisioning in US East
     - PostgreSQL Flexible Server provisioning in US East
   - Expected approval time: 1-3 business days

5. **Re-enable database module after quota approval**
   - Uncomment lines 71-91 in `main.bicep`
   - Uncomment line 144 in `main.bicep` (database output)
   - Redeploy infrastructure

---

## 📊 Cost Summary

### Current Monthly Estimate (US East, Pay-As-You-Go)

| Service | SKU/Tier | Monthly Cost | Status |
|---------|----------|-------------|--------|
| **App Service Plan** | S1 Standard | ~$70 | ✅ Ready to deploy |
| **Redis Cache** | Standard C1 | ~$75 | ✅ Ready to deploy |
| **SQL Database** | Basic | ~$5 | ❌ Quota restricted |
| **PostgreSQL** | Burstable B1ms | ~$15 | ❌ Quota restricted |
| **Storage Account** | Standard LRS | ~$2 | ✅ Ready to deploy |
| **Virtual Network** | Standard | $0 | ✅ Ready to deploy |
| **Key Vault** | Standard | ~$1 | ✅ Ready to deploy |
| **Log Analytics** | Pay-as-you-go | ~$3 | ✅ Ready to deploy |
| **Data Transfer** | Outbound | ~$5 | ✅ Ready to deploy |
| **TOTAL (Without DB)** | | **~$156/month** | |
| **TOTAL (With DB)** | | **~$176/month** | After quota approval |

### ⚠️ Cost Optimization Recommendations

**Current template includes Redis Cache Standard ($75/month) which you may not need for dev:**

To reduce costs, consider:
1. **Remove Redis Cache** from `database.bicep` → Saves $75/month → **$81/month total**
2. **Use F1 Free App Service** (no VNet) → Saves $70/month → **$11/month total**
3. **Stop resources when not in use**:
   ```bash
   # Stop App Service
   az webapp stop --name <app-name> --resource-group tesoro-dev-rg

   # Delete Redis (easy to recreate)
   az redis delete --name <redis-name> --resource-group tesoro-dev-rg
   ```

**Recommended dev environment cost**: **$10-30/month** (minimal setup without Redis)

---

## 🎯 What Can Be Demonstrated Now

Even without databases, you can demonstrate:

### ✅ Infrastructure as Code
- Complete Bicep templates with modular design
- Networking, security, compute, storage, monitoring modules
- Parameterized for multiple environments (dev/staging/production)

### ✅ Networking & Security
- Virtual Network with multiple subnets
- Network Security Groups (NSGs)
- VNet integration for App Services
- Private endpoints architecture (designed, pending deployment)

### ✅ Identity & Access Management
- Managed Identities for services
- Azure Key Vault for secrets management
- RBAC configuration

### ✅ Monitoring & Observability
- Log Analytics Workspace
- Action Groups for alerts
- Workbooks for dashboards
- Application Insights integration

### ✅ DevOps Best Practices
- Modular infrastructure design
- Environment parameterization
- Cost management with budget alerts
- Documentation (architecture, runbooks, ADRs)

### ⏳ Pending (After Quota Approval)
- Database provisioning (SQL + PostgreSQL)
- High availability database configurations
- Database private endpoints

---

## 📝 Files Modified

### Infrastructure Templates
- `infrastructure/bicep/main.bicep`
  - Changed default location: `australiacentral` → `eastus`
  - Commented out database module (lines 71-91)
  - Commented out database output (line 144)

- `infrastructure/bicep/modules/compute.bicep`
  - Changed App Service SKU: `B2 Basic` → `S1 Standard`
  - Reason: Basic VMs quota = 0, Standard has quota available

### Documentation
- `docs/azure-quota-increase-guide.md` - How to request quota increases
- `docs/cost-estimate.md` - Detailed cost breakdown by environment
- `docs/setup-guide-beginners.md` - Beginner setup guide
- `DEPLOYMENT-STATUS.md` - This file

### Scripts
- `scripts/bash/setup-budget-alerts.sh` - Budget alert automation
- `scripts/bash/health-check.sh` - Resource health validation

---

## 🚀 Commands Ready to Run

### Once Resource Group Deletion Completes

```bash
# Check if RG is deleted
az group exists --name tesoro-dev-rg
# Should return: false

# Deploy infrastructure (without databases)
az deployment sub create \
  --location eastus \
  --name "tesoro-dev-$(date +%Y%m%d-%H%M%S)" \
  --template-file infrastructure/bicep/main.bicep \
  --parameters environment=dev appName=tesoro

# Monitor deployment
az deployment sub show --name <deployment-name> \
  --query "{Name:name, State:properties.provisioningState, Duration:properties.duration}"

# List deployed resources
az resource list --resource-group tesoro-dev-rg -o table

# Check costs
az consumption usage list \
  --start-date $(date -v-1d +%Y-%m-%d) \
  --end-date $(date +%Y-%m-%d) \
  -o table
```

---

## 📞 Support Requests Needed

### Azure Support Portal

1. **SQL Database Provisioning**
   - Type: Service and subscription limits (quotas)
   - Service: SQL Database
   - Location: US East
   - Request: Enable provisioning for development/learning purposes

2. **PostgreSQL Provisioning**
   - Type: Service and subscription limits (quotas)
   - Service: Azure Database for PostgreSQL
   - Location: US East
   - Request: Enable provisioning for development/learning purposes

**Justification Template**:
```
I am building a DevOps portfolio project for a loyalty rewards platform (Tesoro XP).
This is for educational/learning purposes to demonstrate Azure infrastructure skills.

Environment: Development
Expected usage: Minimal workloads, learning/testing only
Resources needed:
- 1 SQL Database (Basic tier)
- 1 PostgreSQL Flexible Server (Burstable B1ms)

I have upgraded to Pay-As-You-Go and set budget alerts to manage costs responsibly.
```

---

## ✅ Success Criteria

### Phase 1: Infrastructure Without Databases (Current)
- [x] Budget alerts configured
- [x] Templates updated for US East
- [x] App Service SKU compatible with quota
- [ ] Resource group deleted (in progress)
- [ ] Infrastructure deployed successfully
- [ ] All resources healthy and accessible

### Phase 2: Complete Infrastructure (After Quota Approval)
- [ ] Quota increase requests submitted
- [ ] SQL Database quota approved
- [ ] PostgreSQL quota approved
- [ ] Database module re-enabled
- [ ] Full infrastructure deployed
- [ ] All resources integrated and tested

---

## 🎓 Learning Outcomes

This deployment process has demonstrated:

1. **Azure Cost Management**
   - Regional pricing differences (30% savings by switching regions)
   - Budget alerts and spending limits
   - Resource cost optimization

2. **Quota Management**
   - Understanding Azure subscription limits
   - Quota increase request process
   - Working within free-tier constraints

3. **Infrastructure as Code**
   - Modular Bicep template design
   - Idempotent deployments
   - Environment parameterization

4. **Troubleshooting**
   - Key Vault soft delete and purge process
   - Deployment error analysis
   - Resource group deletion timing

5. **DevOps Best Practices**
   - Documentation-driven development
   - Cost monitoring from day one
   - Incremental deployment strategy

---

**Next Action**: Wait for resource group deletion to complete, then deploy infrastructure without databases.
