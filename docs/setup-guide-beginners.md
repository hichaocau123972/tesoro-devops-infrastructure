# Complete Setup Guide for Beginners

This guide assumes you have **no prior Azure experience** and will walk you through everything step-by-step.

## Prerequisites

Before starting, you'll need:
- A computer (Windows, macOS, or Linux)
- An internet connection
- An email address
- A phone number for verification
- A credit/debit card (for Azure verification only - see free tier info below)

## Part 1: Create Your Azure Account

### Step 1: Sign Up for Azure Free Tier

1. **Open your browser** and go to: https://azure.microsoft.com/free/

2. **Click "Start free"** or **"Free account"**

3. **Sign in or create a Microsoft account**:
   - Use an existing Microsoft account (Outlook, Hotmail, Xbox, etc.)
   - OR create a new one with any email address

4. **Complete the registration form**:
   - Personal information (name, country, etc.)
   - Phone verification (you'll receive a code via SMS)
   - Credit card verification
     - ⚠️ **Important**: Your card won't be charged
     - It's only for identity verification
     - You'll get a notification before any charges occur

5. **Agree to terms** and click **"Sign up"**

6. **Wait for confirmation** - You should see "Welcome to Azure" message

### What You Get Free

✅ **$200 USD credit** for first 30 days - use for anything
✅ **12 months free** of specific services:
   - 750 hours of B1S Virtual Machines
   - 5 GB blob storage
   - 250 GB SQL Database
   - And more: https://azure.microsoft.com/free/

✅ **Always free** (with limits):
   - App Service (10 apps)
   - Functions (1 million requests/month)
   - And more

### Cost Safety Tips

- Set up **budget alerts** (we'll do this later)
- Start with **dev environment only** (costs ~$5-10/day with free credits)
- **Delete resources** when not in use
- Azure will **notify you** before charging your card

## Part 2: Install Azure CLI

Azure CLI is the command-line tool to manage Azure resources.

### For macOS

1. **Open Terminal** (Applications → Utilities → Terminal)

2. **Install using Homebrew** (recommended):
   ```bash
   # Install Homebrew if you don't have it
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

   # Install Azure CLI
   brew update && brew install azure-cli
   ```

3. **Verify installation**:
   ```bash
   az --version
   ```

   You should see version 2.50.0 or higher.

### For Windows

1. **Download the installer**:
   - Go to: https://aka.ms/installazurecliwindows
   - Download the MSI installer

2. **Run the installer**:
   - Double-click the downloaded file
   - Follow the installation wizard
   - Use default settings

3. **Open PowerShell** (not Command Prompt):
   - Press Windows key
   - Type "PowerShell"
   - Right-click and "Run as Administrator"

4. **Verify installation**:
   ```powershell
   az --version
   ```

### For Linux (Ubuntu/Debian)

```bash
# Update package list
sudo apt-get update

# Install prerequisites
sudo apt-get install ca-certificates curl apt-transport-https lsb-release gnupg

# Download and install Microsoft signing key
curl -sL https://packages.microsoft.com/keys/microsoft.asc | \
    gpg --dearmor | \
    sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null

# Add Azure CLI repository
AZ_REPO=$(lsb_release -cs)
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | \
    sudo tee /etc/apt/sources.list.d/azure-cli.list

# Install Azure CLI
sudo apt-get update
sudo apt-get install azure-cli

# Verify
az --version
```

## Part 3: First Time Azure Login

1. **Open your terminal** (macOS/Linux) or **PowerShell** (Windows)

2. **Login to Azure**:
   ```bash
   az login
   ```

3. **What happens next**:
   - A browser window will open
   - Sign in with the Microsoft account you used for Azure
   - You'll see "You have logged in. You can close this window."
   - Return to your terminal

4. **Verify you're logged in**:
   ```bash
   az account show
   ```

   You should see JSON output with your subscription details.

5. **List your subscriptions**:
   ```bash
   az account list --output table
   ```

   You should see at least one subscription (likely named "Azure subscription 1" or "Free Trial")

## Part 4: Set Up Your Development Environment

### Install Git (if not already installed)

**macOS**:
```bash
# Check if Git is installed
git --version

# If not installed, use Homebrew
brew install git
```

**Windows**:
- Download from: https://git-scm.com/download/win
- Run installer with default settings

**Linux**:
```bash
sudo apt-get install git
```

### Verify Git Installation
```bash
git --version
```

## Part 5: Set Up Cost Management (Important!)

Before deploying anything, let's set up budget alerts so you don't accidentally overspend.

### Create a Budget Alert

1. **Via Azure Portal** (easiest for beginners):

   a. Go to: https://portal.azure.com

   b. Sign in with your Azure account

   c. In the search bar at top, type **"Cost Management"**

   d. Click **"Cost Management + Billing"**

   e. In left menu, click **"Cost Management"** → **"Budgets"**

   f. Click **"+ Add"** to create a new budget

   g. Configure your budget:
   - **Name**: "Monthly Development Budget"
   - **Reset period**: Monthly
   - **Creation date**: Today
   - **Expiration date**: One year from now
   - **Amount**: $50 (or whatever you're comfortable with)

   h. Click **"Next"** to set alerts:
   - **Alert 1**: 50% of budget ($25)
   - **Alert 2**: 75% of budget ($37.50)
   - **Alert 3**: 90% of budget ($45)
   - **Alert 4**: 100% of budget ($50)

   i. Add your email address for notifications

   j. Click **"Create"**

2. **Via Azure CLI** (alternative):
   ```bash
   # We'll set this up after you deploy your first resource group
   ```

## Part 6: Understand Azure Basics

Before deploying, let's understand key Azure concepts:

### What is a Subscription?
- Your billing container
- You have one from the free tier
- All resources are created under a subscription

### What is a Resource Group?
- A logical container for resources
- Think of it as a folder
- Example: "tesoro-dev-rg" holds all dev environment resources
- **Important**: Deleting a resource group deletes everything in it!

### What is a Region?
- Physical Azure data center location
- Examples: "East US", "West Europe", "Southeast Asia"
- We'll use "East US" (default in our templates)
- Closer regions = lower latency

### Common Azure Services in This Project

| Service | What It Does | Cost (approx) |
|---------|--------------|---------------|
| **App Service** | Hosts web applications | $13-55/month (dev) |
| **SQL Database** | Relational database | $5-15/month (dev) |
| **Redis Cache** | In-memory cache | $16-50/month (dev) |
| **Storage Account** | File/blob storage | $1-5/month |
| **Key Vault** | Secrets management | ~$0.03/month |
| **Application Insights** | Monitoring/logging | Free tier available |

**Dev Environment Total**: ~$40-150/month (covered by your $200 credit!)

## Part 7: Get the Project Code

1. **Navigate to your projects folder**:
   ```bash
   cd ~/Projects
   # Or wherever you keep your code
   ```

2. **The project is already there**:
   ```bash
   cd /Users/dbmpro2/Projects/ai-projects/tesoro-devops-infrastructure
   ```

3. **Verify the files**:
   ```bash
   ls -la
   ```

   You should see:
   - `infrastructure/` folder
   - `docs/` folder
   - `scripts/` folder
   - `README.md`
   - And other files

## Part 8: Your First Deployment (Dev Environment)

Now you're ready to deploy! We'll start with the smallest, cheapest environment.

### Option A: Deploy Using Our Script (Easiest)

1. **Navigate to the project**:
   ```bash
   cd /Users/dbmpro2/Projects/ai-projects/tesoro-devops-infrastructure
   ```

2. **Make sure you're logged into Azure**:
   ```bash
   az account show
   ```

3. **Run the deployment script in "What-If" mode** (preview only, no changes):
   ```bash
   # For macOS/Linux
   cd scripts/powershell
   pwsh Deploy-Infrastructure.ps1 -Environment dev -WhatIf

   # If you don't have PowerShell on Mac/Linux, install it:
   # brew install --cask powershell  (macOS)
   # See: https://learn.microsoft.com/powershell/scripting/install/installing-powershell
   ```

4. **Review the output** - it will show what would be created

5. **Deploy for real** (removes -WhatIf flag):
   ```bash
   pwsh Deploy-Infrastructure.ps1 -Environment dev
   ```

6. **Wait for deployment** (takes 10-15 minutes):
   - Watch the progress in your terminal
   - Don't close the window

### Option B: Deploy Using Azure CLI Directly

If you prefer not to use PowerShell:

1. **Navigate to project root**:
   ```bash
   cd /Users/dbmpro2/Projects/ai-projects/tesoro-devops-infrastructure
   ```

2. **Preview what will be deployed**:
   ```bash
   az deployment sub what-if \
     --location eastus \
     --template-file infrastructure/bicep/main.bicep \
     --parameters environment=dev location=eastus appName=tesoro
   ```

3. **Review the output** - look for resources that will be created

4. **Deploy**:
   ```bash
   az deployment sub create \
     --name tesoro-dev-$(date +%Y%m%d-%H%M%S) \
     --location eastus \
     --template-file infrastructure/bicep/main.bicep \
     --parameters environment=dev location=eastus appName=tesoro
   ```

5. **Wait and watch** - deployment takes 10-15 minutes

### What's Happening During Deployment?

The script is creating:
- ✅ Resource Group (container for everything)
- ✅ Virtual Network (isolated network)
- ✅ App Service (to host your application)
- ✅ SQL Database (for data storage)
- ✅ Redis Cache (for fast data access)
- ✅ Storage Account (for files/blobs)
- ✅ Key Vault (for secrets)
- ✅ Application Insights (for monitoring)

## Part 9: Verify Your Deployment

### Check in Azure Portal (Visual)

1. **Go to**: https://portal.azure.com

2. **Click "Resource groups"** in left menu

3. **You should see**: "tesoro-dev-rg"

4. **Click on it** to see all resources

5. **Explore the resources**:
   - Click on each one
   - Look at the Overview tab
   - Check the status (should say "Running" or "Online")

### Check Using Our Health Script

1. **Make the script executable** (macOS/Linux only):
   ```bash
   chmod +x scripts/bash/health-check.sh
   ```

2. **Run the health check**:
   ```bash
   ./scripts/bash/health-check.sh dev
   ```

3. **Review results**:
   - Green ✓ = Good
   - Yellow ⚠ = Warning (usually OK)
   - Red ✗ = Problem

### Check Using Azure CLI

```bash
# List all resources in your dev environment
az resource list \
  --resource-group tesoro-dev-rg \
  --output table

# Check App Service status
az webapp list \
  --resource-group tesoro-dev-rg \
  --output table
```

## Part 10: Understanding Costs

### Check Current Costs

1. **Via Azure Portal**:
   - Go to: https://portal.azure.com
   - Click "Cost Management + Billing"
   - Click "Cost analysis"
   - View your current spending

2. **Via Azure CLI**:
   ```bash
   # View cost analysis (may take 24-48 hours to show data)
   az consumption usage list \
     --start-date $(date -d '1 day ago' '+%Y-%m-%d') \
     --end-date $(date '+%Y-%m-%d')
   ```

### Expected Daily Costs (Dev Environment)

- **App Service (Basic B2)**: ~$0.40/day
- **SQL Database (Basic)**: ~$0.16/day
- **Redis (Basic C1)**: ~$0.50/day
- **Storage**: ~$0.10/day
- **Other services**: ~$0.10/day

**Total**: ~$1.50-2.00/day or **$45-60/month**

This is well within your $200 credit!

## Part 11: Stop/Start Resources to Save Money

When you're not using the dev environment, you can stop resources:

### Stop Everything (Save Money)

```bash
# Stop the App Service
az webapp stop \
  --name $(az webapp list --resource-group tesoro-dev-rg --query "[0].name" -o tsv) \
  --resource-group tesoro-dev-rg

# Stop SQL Database (switch to serverless tier)
# Note: This requires changing the tier, which we can do later
```

### Start Everything Again

```bash
# Start the App Service
az webapp start \
  --name $(az webapp list --resource-group tesoro-dev-rg --query "[0].name" -o tsv) \
  --resource-group tesoro-dev-rg
```

### Delete Everything (Complete Cleanup)

⚠️ **Warning**: This permanently deletes all resources!

```bash
# Delete the entire resource group
az group delete \
  --name tesoro-dev-rg \
  --yes \
  --no-wait

# Verify deletion
az group exists --name tesoro-dev-rg
# Should return: false
```

## Part 12: Next Steps After First Deployment

Once your dev environment is deployed and verified:

### 1. Explore Azure Portal
- Get familiar with the interface
- Click around and explore your resources
- Check the monitoring dashboards

### 2. Learn the Basics
- Read: [docs/architecture/overview.md](../architecture/overview.md)
- Understand what each component does
- Review the architecture diagrams

### 3. Try Making a Change
- Modify a Bicep template (like changing App Service tier)
- Run what-if to preview
- Deploy the change
- See how updates work

### 4. Set Up Monitoring
- Go to Application Insights in Azure Portal
- Explore the dashboards
- Set up a custom alert

### 5. Practice Operational Tasks
- Run health checks
- View logs in Azure Portal
- Practice stopping/starting services

## Common Issues and Solutions

### Issue: "az: command not found"

**Solution**: Azure CLI not installed or not in PATH
```bash
# Reinstall Azure CLI
# macOS:
brew install azure-cli

# Verify installation
which az
```

### Issue: "Subscription not found"

**Solution**: You're not logged in or wrong subscription selected
```bash
# Login again
az login

# List subscriptions
az account list --output table

# Set the right one
az account set --subscription "your-subscription-name"
```

### Issue: "Deployment failed: QuotaExceeded"

**Solution**: You've hit a limit on the free tier
- Check your quota: Portal → Subscriptions → Usage + quotas
- Try a different region
- Or contact Azure support to request increase

### Issue: "Deployment failed: Location not available"

**Solution**: Service not available in that region
```bash
# Try different region
az deployment sub create \
  --location westus2 \
  ... (rest of command)
```

### Issue: Cost is higher than expected

**Solution**:
1. Check Cost Management in Portal
2. Look for unexpected services
3. Verify you're using the right tier (Basic not Premium)
4. Delete unused resources
5. Stop services when not in use

## Getting Help

### Documentation
- **Azure Docs**: https://learn.microsoft.com/azure/
- **Azure CLI Reference**: https://learn.microsoft.com/cli/azure/
- **Project Docs**: Check `/docs` folder

### Community
- **Azure Forum**: https://learn.microsoft.com/answers/
- **Stack Overflow**: Tag questions with [azure]
- **Reddit**: r/AZURE

### Support
- **Azure Support**: https://portal.azure.com → Help + support
- **Free tier includes**: Billing support
- **Technical support**: Requires paid plan (but forums are free!)

## Summary Checklist

After completing this guide, you should have:

- ✅ Azure account created
- ✅ Azure CLI installed
- ✅ Logged into Azure
- ✅ Budget alerts configured
- ✅ Project code ready
- ✅ Dev environment deployed
- ✅ Resources verified in Portal
- ✅ Health checks passing
- ✅ Understanding of costs

## What's Next?

Now that you have your dev environment running:

1. **Learn Azure fundamentals** - Free course: https://learn.microsoft.com/training/azure/
2. **Explore the project** - Read all documentation in `/docs`
3. **Try deploying an application** - Add actual code to the App Service
4. **Practice operations** - Use the runbooks to learn procedures
5. **When ready** - Deploy staging environment

## Practice Exercise

Try this on your own:

1. Check current costs in Azure Portal
2. Stop the App Service using CLI
3. Verify it's stopped in Portal
4. Start it again
5. Run health check to verify

This teaches you basic resource management!

---

**Congratulations!** You've set up Azure and deployed your first infrastructure. Welcome to the cloud! 🎉

For any questions, refer back to this guide or check the other documentation in the `/docs` folder.
