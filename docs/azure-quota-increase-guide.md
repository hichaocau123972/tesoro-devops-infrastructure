# Azure Quota Increase Request Guide

This guide walks you through requesting quota increases for your Azure subscription to enable full infrastructure deployment.

## Prerequisites

- Active Azure subscription
- Access to Azure Portal
- Understanding of which quotas you need (see below)

## Quotas Needed for Full Tesoro Infrastructure

Based on the deployment failures, you need to request increases for:

| Service | Current Quota | Required | Priority |
|---------|--------------|----------|----------|
| Basic VMs | 0 | 4 | **HIGH** - Needed for App Service |
| SQL Database | Restricted | Enabled | **HIGH** - Core database |
| PostgreSQL Flexible Server | Restricted | Enabled | **MEDIUM** - Secondary database |

## Step-by-Step: Request Quota Increase

### Method 1: Azure Portal (Recommended for Beginners)

#### Step 1: Navigate to Quotas
1. Sign in to [Azure Portal](https://portal.azure.com)
2. In the search bar at the top, type **"Quotas"**
3. Click on **"Quotas"** from the results (or navigate to **Subscriptions** → Your subscription → **Usage + quotas**)

#### Step 2: Request Basic VMs Quota Increase

1. In the Quotas page, use the filter/search:
   - **Provider**: `Microsoft.Compute`
   - **Location**: `Australia Central`
   - **Quota name**: Search for `"Basic"`

2. Look for **"Total Regional vCPUs"** or **"Standard BS Family vCPUs"**

3. Click the checkbox next to the quota

4. Click **"Request increase"** at the top

5. In the form that appears:
   - **New limit**: Enter `8` (this gives you room for 4 Basic VMs)
   - **Justification**:
     ```
     I am setting up a development environment for a loyalty rewards platform (Tesoro XP).
     I need to deploy Azure App Services which require Basic VMs for the app service plan.
     This is for learning/educational purposes and will be running minimal workloads.
     Required: 4 Basic VMs for dev environment.
     ```
   - **Preferred contact method**: Email
   - **Severity**: C - Minimal impact (since this is dev/learning)

6. Click **"Submit"**

#### Step 3: Request SQL Database Access

1. In the Azure Portal, click the **"?"** icon in the top right (Help)

2. Click **"Help + support"**

3. Click **"Create a support request"**

4. Fill out the form:

   **Basics tab:**
   - **Issue type**: `Service and subscription limits (quotas)`
   - **Subscription**: Your subscription
   - **Quota type**: Search for and select `SQL Database`
   - Click **"Next"**

   **Problem details tab:**
   - **Deployment model**: `Resource Manager`
   - **Location**: `Australia Central`
   - **Quota type**: Select `Enable provisioning`
   - **Description**:
     ```
     I am requesting access to provision SQL Database resources in the Australia Central region.

     Purpose: Educational/learning project - building a DevOps portfolio project for a loyalty rewards platform (Tesoro XP).

     Environment: Development (dev)
     Required: 1 SQL Server with 1 Basic tier database
     Expected usage: Minimal, development workloads only

     Current error: "Provisioning is restricted in this region. Please choose a different region."

     I am on a free/trial subscription and need access to provision SQL resources for learning purposes.
     ```
   - **Severity**: C - Minimal impact

   **Additional details tab:**
   - Add your contact information
   - Click **"Next"**

   **Review + create tab:**
   - Review your request
   - Click **"Create"**

#### Step 4: Request PostgreSQL Flexible Server Access

1. Repeat the same process as Step 3, but:
   - **Quota type**: `Azure Database for PostgreSQL`
   - **Description**:
     ```
     I am requesting access to provision PostgreSQL Flexible Server resources in the Australia Central region.

     Purpose: Educational/learning project - building a DevOps portfolio project for a loyalty rewards platform (Tesoro XP).

     Environment: Development (dev)
     Required: 1 PostgreSQL Flexible Server (Standard_B1ms tier)
     Expected usage: Minimal, development workloads only

     Current error: "Subscriptions are restricted from provisioning in location 'eastus'. Try again in a different location."

     I am on a free/trial subscription and need access to provision PostgreSQL resources for learning purposes.
     ```

### Method 2: Azure CLI (Advanced)

You can also create quota increase requests using the Azure CLI:

```bash
# For Basic VMs quota
az support tickets create \
  --ticket-name "BasicVMQuota-$(date +%Y%m%d)" \
  --title "Request Basic VM Quota Increase - Australia Central" \
  --description "Requesting increase of Basic VM quota from 0 to 8 in Australia Central for dev environment" \
  --severity minimal \
  --problem-classification "/providers/Microsoft.Support/services/quota_service_guid/problemClassifications/compute_quota_problemClassification_guid" \
  --contact-first-name "Your First Name" \
  --contact-last-name "Your Last Name" \
  --contact-email "your.email@example.com" \
  --contact-country "US" \
  --contact-language "en-us" \
  --contact-timezone "Pacific Standard Time"
```

**Note**: The CLI method requires specific GUIDs that vary. The portal method is much simpler for first-time users.

## What Happens Next?

### Timeline
- **Basic VMs quota**: Usually approved within **1-24 hours** for reasonable increases
- **SQL Database access**: Can take **1-3 business days**
- **PostgreSQL access**: Can take **1-3 business days**

### Notification
- You'll receive email updates on your support request
- Check **Azure Portal** → **Help + support** → **All support requests** for status

### Approval
Once approved, you'll receive an email confirmation. You can then:

```bash
# Verify your new quota
az vm list-usage --location australiacentral -o table | grep -i "basic"

# Re-run the full infrastructure deployment
az deployment sub create \
  --location australiacentral \
  --template-file infrastructure/bicep/main.bicep \
  --parameters environment=dev location=australiacentral appName=tesoro
```

## Common Questions

### Q: Will I be charged for requesting quota increases?
**A**: No, requesting quota increases is free. You're only charged when you actually deploy and use resources.

### Q: Can I deploy to a different region that doesn't have restrictions?
**A**: Unfortunately, free accounts typically have the same restrictions across all regions. Australia Central was chosen because you already have some quota there.

### Q: What if my request is denied?
**A**: You can:
1. Provide more details about your use case (educational/learning project)
2. Start with the minimal infrastructure (already working)
3. Consider upgrading to a pay-as-you-go subscription (requires credit card)

### Q: Do I need to request quotas for every region?
**A**: No, only request for the region you're deploying to (Australia Central in this case).

### Q: Can I speed up the approval process?
**A**: Not really, but you can:
- Clearly explain it's for educational/learning purposes
- Keep requested amounts reasonable (don't ask for 100 VMs)
- Respond quickly to any questions from Azure support

## Alternative: Upgrade to Pay-As-You-Go

If you need immediate access and can't wait for quota approvals:

1. **Azure Portal** → **Subscriptions** → Your subscription
2. Click **"Upgrade"** or **"Change plan"**
3. Follow the wizard to upgrade to Pay-As-You-Go
   - Requires credit card
   - You'll still have $200 free credit if on trial
   - Only charged after free credits are used

**Pros**: Immediate access to all services
**Cons**: Requires credit card, potential for unexpected charges if you exceed free tier

## Next Steps

While waiting for quota approval:

1. ✅ **Continue with minimal infrastructure** - Already deployed and working
2. ✅ **Set up CI/CD pipelines** - Can work with minimal infrastructure
3. ✅ **Write documentation** - Architecture, runbooks, etc.
4. ✅ **Learn Bicep/Azure** - Read through the templates, modify them
5. ⏳ **Monitor quota requests** - Check Azure Portal for updates

Once quotas are approved, you can deploy the full infrastructure!

## Troubleshooting

### "I don't see the Quotas option in the portal"
- Try searching for "Usage + quotas" instead
- Navigate via: Subscriptions → Click your subscription → Usage + quotas

### "I can't create support requests"
- Free tier accounts have limited support
- For quota increases, use the "Quotas" page directly (Method 1, Step 2)
- Alternatively, post in [Azure Forums](https://learn.microsoft.com/answers/tags/133/azure) for community help

### "My request was auto-closed"
- Reopen it and provide more details about your educational use case
- Emphasize this is for learning/portfolio building
- Mention you're following a job description project

---

**Created**: 2025-11-22
**Last Updated**: 2025-11-22
**Next Review**: After first quota approval
