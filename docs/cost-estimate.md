# Azure Infrastructure Cost Estimate - Tesoro XP

This document provides estimated monthly costs for the Tesoro XP infrastructure across different environments.

**Last Updated**: 2025-11-22
**Region**: Australia Central
**Currency**: USD

---

## Summary

| Environment | Monthly Cost (Estimated) | Notes |
|-------------|-------------------------|-------|
| **Minimal (Current)** | **$0 - $5/month** | Free tier eligible, minimal usage |
| **Dev (Basic Tier)** | **$50 - $100/month** | Development environment |
| **Dev (Production-like)** | **$300 - $500/month** | Full featured dev environment |
| **Staging** | **$500 - $800/month** | Pre-production testing |
| **Production** | **$1,500 - $3,000/month** | High availability, scaled |

---

## Detailed Breakdown - Dev Environment (Basic Tier)

This is what you're trying to deploy with the full `main.bicep` template on a **simplified configuration**.

### Compute - App Service
- **App Service Plan**: Basic B1 (1 core, 1.75 GB RAM)
  - **Cost**: ~$13/month
  - **Free tier alternative**: F1 (Free, limited to 60 min/day) = $0

### Database - SQL Server
- **SQL Database**: Basic tier (2 GB storage)
  - **Cost**: ~$5/month
  - **Free tier**: Not available for SQL

### Database - PostgreSQL
- **PostgreSQL Flexible Server**: Burstable B1ms (1 vCore, 32 GB storage)
  - **Cost**: ~$15/month
  - **Free tier**: 750 hours/month of B1ms = Potentially $0

### Storage
- **Storage Account**: Standard LRS (Locally Redundant)
  - **Storage**: First 5 GB free, then $0.02/GB
  - **Transactions**: First 20,000 free
  - **Estimated cost**: ~$2/month for dev usage

### Networking
- **Virtual Network**: Free
- **Network Security Groups**: Free
- **Data transfer**: First 5 GB outbound free, then $0.087/GB
  - **Estimated cost**: ~$5/month

### Security - Key Vault
- **Key Vault**: Standard tier
  - **Secret operations**: First 10,000 free, then $0.03/10,000
  - **Estimated cost**: ~$1/month

### Monitoring
- **Log Analytics Workspace**: Pay-as-you-go
  - **Data ingestion**: First 5 GB/month free, then $2.30/GB
  - **Data retention**: 31 days free, 90 days additional retention
  - **Estimated cost**: ~$3/month for light dev usage

### Redis Cache (if added)
- **Azure Cache for Redis**: Basic C0 (250 MB)
  - **Cost**: ~$16/month
  - **Not included in current template**

---

## Monthly Cost Estimate (Dev - Basic Tier)

| Service | Monthly Cost | Can Use Free Tier? |
|---------|-------------|-------------------|
| App Service (B1) | $13 | ✅ Yes (F1, limited) |
| SQL Database (Basic) | $5 | ❌ No |
| PostgreSQL (B1ms) | $15 | ✅ Yes (750 hrs/month) |
| Storage Account | $2 | ✅ Mostly (5 GB free) |
| Virtual Network | $0 | ✅ Yes |
| Key Vault | $1 | ✅ Mostly (10k ops free) |
| Log Analytics | $3 | ✅ Partially (5 GB free) |
| Data Transfer | $5 | ✅ Partially (5 GB free) |
| **TOTAL** | **~$44/month** | **Can reduce to ~$10/month** |

---

## How to Minimize Costs

### Strategy 1: Maximum Free Tier Usage (~$5-10/month)

```bicep
// Use these SKUs in your Bicep templates:

// App Service - Free Tier
sku: {
  name: 'F1'  // Instead of B1
  tier: 'Free'
}

// PostgreSQL - Free Tier (750 hours/month)
sku: {
  name: 'Standard_B1ms'  // Keep this, it's free tier eligible
  tier: 'Burstable'
}

// SQL Database - Lowest paid tier (no free option)
sku: {
  name: 'Basic'  // Already using this - cheapest option at ~$5/month
  tier: 'Basic'
}
```

**Result**: ~$5-10/month (only SQL Database costs, everything else free)

### Strategy 2: Dev Hours Only (Stop resources when not using)

Stop resources overnight and weekends using automation:

```bash
# Stop App Service (saves $13/month if stopped 16h/day)
az webapp stop --name tesoro-dev-app --resource-group tesoro-dev-rg

# Stop PostgreSQL (saves $15/month if stopped when not needed)
az postgres flexible-server stop --name tesoro-dev-postgres --resource-group tesoro-dev-rg

# Restart when needed
az webapp start --name tesoro-dev-app --resource-group tesoro-dev-rg
az postgres flexible-server start --name tesoro-dev-postgres --resource-group tesoro-dev-rg
```

**Savings**: 50-70% reduction = ~$20/month instead of $44

### Strategy 3: Ephemeral Environments Only

Only create infrastructure when you need it:
- Deploy when starting work session
- Delete when done for the day
- Use the deployment scripts for quick setup

**Cost**: ~$1-5/month (only storage and Key Vault persist)

---

## Cost by Environment (Full Production Setup)

### Development (~$100/month)
- Basic/Standard S1 App Service
- Basic SQL Database
- Burstable PostgreSQL
- Standard storage
- Minimal monitoring

### Staging (~$500/month)
- Standard S2 App Service
- Standard S2 SQL Database
- General Purpose PostgreSQL
- Geo-redundant storage
- Full monitoring + alerts

### Production (~$2,000/month)
- Premium P1v3 App Service (zone redundant)
- Hyperscale SQL Database
- High Availability PostgreSQL
- Zone-redundant storage with geo-replication
- Application Gateway + CDN
- Comprehensive monitoring
- Redis Cache
- Multiple availability zones

---

## Azure Free Tier Benefits (12 Months)

When you upgrade to Pay-As-You-Go, you still get 12 months of free services:

| Service | Free Amount | Value |
|---------|-------------|-------|
| App Service | 10 web apps | $0 (limited hours) |
| SQL Database | 250 GB | $0 |
| PostgreSQL | 750 hours B1ms | ~$15/month |
| Blob Storage | 5 GB LRS | ~$0.10/month |
| File Storage | 5 GB | ~$0.10/month |
| Bandwidth | 15 GB outbound | ~$1.30/month |
| Key Vault | 10,000 operations | ~$0.03/month |

**Total value**: ~$15-20/month free for 12 months

---

## How to Set Up Payment

### Option 1: Stay on Free Tier (Recommended for Learning)
- **Cost**: $0 initially, then ~$5-10/month for SQL Database
- **How**: Request quota increases (we covered this)
- **Wait time**: 1-3 business days
- **Best for**: Learning, portfolio projects, minimal usage

### Option 2: Upgrade to Pay-As-You-Go
- **Cost**: You pay for what you use, billed monthly
- **How**: See steps below
- **Benefits**: Immediate access, no quota restrictions, keep free credits
- **Best for**: Need access immediately, can afford ~$50/month

---

## Steps to Upgrade to Pay-As-You-Go

1. **Go to Azure Portal**: https://portal.azure.com

2. **Navigate to Subscriptions**:
   - Click **"Subscriptions"** in the left menu
   - Click on your subscription name

3. **Upgrade Your Subscription**:
   - Look for **"Upgrade"** banner at the top, or
   - Click **"Overview"** → **"Upgrade subscription"**

4. **Provide Payment Information**:
   - Enter credit/debit card details
   - Billing address
   - Contact information

5. **Review and Confirm**:
   - Review the upgrade terms
   - You'll keep any remaining free credits ($200 if still in trial)
   - Click **"Upgrade"**

6. **Verification**:
   - Azure may charge $1 to verify your card (refunded immediately)
   - Upgrade usually completes in 2-5 minutes

7. **Set Spending Limits** (Important!):
   ```bash
   # After upgrade, set a spending limit alert
   az monitor action-group create \
     --name "budget-alert-email" \
     --resource-group tesoro-dev-rg \
     --short-name "BudgetAlert"
   ```

---

## Cost Control Recommendations

### 1. Set Budget Alerts

Create budget alerts at multiple thresholds:

**Azure Portal** → **Cost Management + Billing** → **Budgets** → **Add**

Recommended budgets:
- **$25/month**: 50% warning for minimal dev
- **$50/month**: 100% warning for basic dev
- **$75/month**: Critical alert (something's wrong)

### 2. Enable Daily Cost Emails

**Cost Management + Billing** → **Cost alerts** → **Subscribe to daily cost summary**

### 3. Use Azure Pricing Calculator

Before deploying, estimate costs:
https://azure.microsoft.com/pricing/calculator/

### 4. Tag All Resources

Tag resources for cost tracking:
```bicep
tags: {
  environment: 'dev'
  costCenter: 'engineering'
  project: 'tesoro-xp'
  owner: 'your-name'
}
```

View costs by tag: **Cost Management** → **Cost analysis** → Group by **Tag**

### 5. Review Costs Weekly

Check **Cost Management + Billing** → **Cost analysis** weekly to catch any surprises early.

---

## What I Recommend for You

Given you're building a portfolio project for a job application:

### Phase 1: NOW (Free Tier)
1. ✅ Keep the minimal infrastructure running (~$0/month)
2. ✅ Request quota increases (free, takes 1-3 days)
3. ✅ Set up documentation, CI/CD, architecture diagrams
4. ✅ Learn Bicep, practice deployments

### Phase 2: AFTER QUOTA APPROVAL (Still Free/Cheap)
1. Deploy full dev infrastructure with free tier SKUs
2. Estimated cost: ~$5-10/month (just SQL Database)
3. Show working deployment in job interviews
4. Delete when not actively using: ~$1/month

### Phase 3: IF YOU GET THE JOB (Paid)
1. Upgrade to Pay-As-You-Go
2. Deploy production-like environment
3. Estimated cost: ~$50-100/month for impressive demo

**Bottom line**: You can build an impressive portfolio project for **$0-10/month** while waiting for quota approval. Only upgrade to paid if you need immediate access or want to show production-grade infrastructure.

---

## Questions?

**Q: What if I forget to delete resources and get a huge bill?**
**A**: Set budget alerts at $25 and $50. Azure will email you. Also, dev infrastructure maxes out around $100/month even if you forget.

**Q: Can I pause my subscription to avoid charges?**
**A**: No, but you can delete resources (keep VNet, it's free) and redeploy when needed using the Bicep templates.

**Q: Will I lose my free credits if I upgrade?**
**A**: No! If you have $200 free credits remaining, you keep them after upgrading to Pay-As-You-Go.

**Q: What's the cheapest way to show I know Azure for the job?**
**A**: Minimal infrastructure ($0) + comprehensive documentation + Bicep templates + architecture diagrams. Shows you understand the concepts without needing to spend money.

---

**Remember**: For a DevOps portfolio project, **documentation and architecture understanding** matter more than actually running expensive production infrastructure. You can impress with a $10/month dev environment if it's well-documented and properly architected.
