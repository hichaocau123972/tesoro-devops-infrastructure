# Getting Started Checklist - Complete Beginner

Follow this checklist in order. Check off each item as you complete it.

## 📋 Phase 1: Account Setup (30 minutes)

- [ ] **1.1** Go to https://azure.microsoft.com/free/
- [ ] **1.2** Click "Start free" or "Free account"
- [ ] **1.3** Sign in with Microsoft account (or create new one)
- [ ] **1.4** Complete registration form
- [ ] **1.5** Verify phone number (you'll get SMS code)
- [ ] **1.6** Add credit card for verification (won't be charged)
- [ ] **1.7** Accept terms and complete signup
- [ ] **1.8** See "Welcome to Azure" confirmation

**✅ You now have**: $200 credit for 30 days + 12 months of free services!

---

## 🛠 Phase 2: Install Tools (15 minutes)

### For macOS:

- [ ] **2.1** Open Terminal (Applications → Utilities → Terminal)
- [ ] **2.2** Install Homebrew (if needed):
  ```bash
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  ```
- [ ] **2.3** Install Azure CLI:
  ```bash
  brew update && brew install azure-cli
  ```
- [ ] **2.4** Verify installation:
  ```bash
  az --version
  ```
  You should see version 2.50.0 or higher

- [ ] **2.5** Install PowerShell (optional but recommended):
  ```bash
  brew install --cask powershell
  ```

### For Windows:

- [ ] **2.1** Download Azure CLI installer: https://aka.ms/installazurecliwindows
- [ ] **2.2** Run the installer (double-click MSI file)
- [ ] **2.3** Follow installation wizard with default settings
- [ ] **2.4** Open PowerShell as Administrator
- [ ] **2.5** Verify installation:
  ```powershell
  az --version
  ```

### Verify Git (all platforms):

- [ ] **2.6** Check if Git is installed:
  ```bash
  git --version
  ```
- [ ] **2.7** If not installed:
  - **macOS**: `brew install git`
  - **Windows**: Download from https://git-scm.com/download/win

**✅ You now have**: Azure CLI and Git installed!

---

## 🔐 Phase 3: Login to Azure (5 minutes)

- [ ] **3.1** Open Terminal (macOS/Linux) or PowerShell (Windows)
- [ ] **3.2** Run login command:
  ```bash
  az login
  ```
- [ ] **3.3** Browser opens → Sign in with your Azure account
- [ ] **3.4** See "You have logged in" message in browser
- [ ] **3.5** Close browser and return to terminal
- [ ] **3.6** Verify login worked:
  ```bash
  az account show
  ```
  You should see JSON with your subscription details

- [ ] **3.7** List your subscriptions:
  ```bash
  az account list --output table
  ```
  You should see at least one (probably "Azure subscription 1" or "Free Trial")

**✅ You are now**: Authenticated to Azure!

---

## 💰 Phase 4: Set Budget Alert (10 minutes)

This prevents surprise charges!

- [ ] **4.1** Go to https://portal.azure.com
- [ ] **4.2** Sign in with your Azure account
- [ ] **4.3** In search bar at top, type: **Cost Management**
- [ ] **4.4** Click **"Cost Management + Billing"**
- [ ] **4.5** In left menu: Cost Management → **Budgets**
- [ ] **4.6** Click **"+ Add"**
- [ ] **4.7** Configure budget:
  - Name: "Monthly Development Budget"
  - Reset period: Monthly
  - Amount: **$50**
- [ ] **4.8** Click **"Next"** and set alerts at: 50%, 75%, 90%, 100%
- [ ] **4.9** Add your email address
- [ ] **4.10** Click **"Create"**

**✅ You will now**: Get email alerts before overspending!

---

## 📁 Phase 5: Prepare the Project (2 minutes)

- [ ] **5.1** Open Terminal/PowerShell
- [ ] **5.2** Navigate to project:
  ```bash
  cd /Users/dbmpro2/Projects/ai-projects/tesoro-devops-infrastructure
  ```
- [ ] **5.3** Verify files exist:
  ```bash
  ls -la
  ```
  You should see folders: infrastructure, docs, scripts, etc.

- [ ] **5.4** Read the project summary:
  ```bash
  cat PROJECT-SUMMARY.md
  ```

**✅ You are in**: The project directory!

---

## 🚀 Phase 6: Deploy Dev Environment (20 minutes)

**IMPORTANT**: This will use some of your $200 credit (~$2/day)

### Preview First (What-If)

- [ ] **6.1** Run preview to see what will be created:
  ```bash
  az deployment sub what-if \
    --location eastus \
    --template-file infrastructure/bicep/main.bicep \
    --parameters environment=dev location=eastus appName=tesoro
  ```

- [ ] **6.2** Review the output
  - Look for resources to be created
  - Check if anything looks wrong (it shouldn't!)

### Deploy for Real

- [ ] **6.3** Run the actual deployment:
  ```bash
  az deployment sub create \
    --name tesoro-dev-$(date +%Y%m%d-%H%M%S) \
    --location eastus \
    --template-file infrastructure/bicep/main.bicep \
    --parameters environment=dev location=eastus appName=tesoro
  ```

- [ ] **6.4** Wait 10-15 minutes (grab a coffee! ☕)
  - Don't close the terminal window
  - Watch the progress messages

- [ ] **6.5** When complete, you should see: "provisioningState": "Succeeded"

**✅ You just deployed**: Your first cloud infrastructure!

---

## ✅ Phase 7: Verify Deployment (10 minutes)

### Check in Azure Portal (Visual)

- [ ] **7.1** Go to https://portal.azure.com
- [ ] **7.2** Click **"Resource groups"** in left menu
- [ ] **7.3** You should see: **"tesoro-dev-rg"**
- [ ] **7.4** Click on it to view all resources
- [ ] **7.5** Count the resources (should be ~8-10)
- [ ] **7.6** Check that statuses show "Running" or "Online"

### Check with Health Script

- [ ] **7.7** Make script executable (macOS/Linux only):
  ```bash
  chmod +x scripts/bash/health-check.sh
  ```

- [ ] **7.8** Run health check:
  ```bash
  ./scripts/bash/health-check.sh dev
  ```

- [ ] **7.9** Verify you see mostly green checkmarks ✓
  - Some yellow ⚠ warnings are OK
  - Red ✗ means something failed (check troubleshooting)

### Check with Azure CLI

- [ ] **7.10** List all resources:
  ```bash
  az resource list --resource-group tesoro-dev-rg --output table
  ```

- [ ] **7.11** Take a screenshot or save the output

**✅ Your infrastructure is**: Running and healthy!

---

## 💵 Phase 8: Check Costs (5 minutes)

- [ ] **8.1** Go to Azure Portal: https://portal.azure.com
- [ ] **8.2** Click **"Cost Management + Billing"**
- [ ] **8.3** Click **"Cost analysis"**
- [ ] **8.4** Note: Data may take 24-48 hours to appear
- [ ] **8.5** Expected daily cost: **~$2-3/day**
- [ ] **8.6** This equals: **~$60-90/month** (covered by your $200 credit!)

**✅ You are now**: Tracking your spending!

---

## 🎓 Phase 9: Learn the Basics (30 minutes)

- [ ] **9.1** Read: `docs/architecture/overview.md`
  ```bash
  cat docs/architecture/overview.md
  ```

- [ ] **9.2** Understand what each Azure service does:
  - App Service = Hosts web applications
  - SQL Database = Stores data
  - Redis = Fast caching
  - Key Vault = Stores secrets
  - Storage = Files and blobs

- [ ] **9.3** Explore Azure Portal:
  - Click on each resource
  - Read the Overview tab
  - Look at Monitoring → Metrics

- [ ] **9.4** Read: `QUICK-START.md` for common commands
  ```bash
  cat QUICK-START.md
  ```

**✅ You now understand**: What you deployed and why!

---

## 🧪 Phase 10: Practice Basic Operations (15 minutes)

### Stop the App Service (Save Money)

- [ ] **10.1** Get the App Service name:
  ```bash
  az webapp list --resource-group tesoro-dev-rg --query "[0].name" -o tsv
  ```

- [ ] **10.2** Copy that name

- [ ] **10.3** Stop it:
  ```bash
  az webapp stop --name YOUR-APP-NAME --resource-group tesoro-dev-rg
  ```
  (Replace YOUR-APP-NAME with the actual name)

- [ ] **10.4** Verify in Portal: It should show "Stopped"

### Start it Again

- [ ] **10.5** Start it:
  ```bash
  az webapp start --name YOUR-APP-NAME --resource-group tesoro-dev-rg
  ```

- [ ] **10.6** Verify in Portal: Should show "Running"

- [ ] **10.7** Run health check again:
  ```bash
  ./scripts/bash/health-check.sh dev
  ```

**✅ You can now**: Start and stop resources!

---

## 🧹 Phase 11: Cleanup (When Done Testing)

**Only do this when you're done testing!**

### Option A: Keep It Running
- Cost: ~$2-3/day
- You have $200 credit = ~60-90 days
- Good if you want to keep learning

### Option B: Stop Resources (Partial Savings)
- Stops App Service (saves ~$0.40/day)
- Database and Redis still cost money
- Run:
  ```bash
  az webapp stop --name YOUR-APP-NAME --resource-group tesoro-dev-rg
  ```

### Option C: Delete Everything (Full Cleanup)
⚠️ **WARNING**: This permanently deletes everything!

- [ ] **11.1** Double-check you want to delete
- [ ] **11.2** Run deletion:
  ```bash
  az group delete --name tesoro-dev-rg --yes --no-wait
  ```

- [ ] **11.3** Verify deletion (after a few minutes):
  ```bash
  az group exists --name tesoro-dev-rg
  ```
  Should return: `false`

- [ ] **11.4** Check in Portal: Resource group should be gone

**✅ Resources deleted**: No more charges!

---

## 🎯 What's Next?

After completing all phases, you can:

### Short Term (This Week)
- [ ] Explore Azure Portal more deeply
- [ ] Read all documentation in `/docs` folder
- [ ] Try modifying a Bicep template and redeploying
- [ ] Set up monitoring alerts

### Medium Term (This Month)
- [ ] Take free Azure Fundamentals course: https://learn.microsoft.com/training/azure/
- [ ] Deploy the staging environment
- [ ] Practice the runbooks in `/docs/runbooks`
- [ ] Deploy a real application to App Service

### Long Term (3+ Months)
- [ ] Get Azure certifications (AZ-900, AZ-104, AZ-400)
- [ ] Deploy to production (when ready)
- [ ] Implement advanced features (multi-region, DR)
- [ ] Apply for DevOps jobs with this portfolio!

---

## 🆘 Troubleshooting

### Problem: "az: command not found"
**Solution**: Azure CLI not installed properly
- Reinstall: `brew install azure-cli` (macOS)
- Or download installer for Windows

### Problem: "Subscription not found"
**Solution**: Not logged in correctly
```bash
az logout
az login
az account show
```

### Problem: Deployment failed
**Solution**: Check error message carefully
- Often quota exceeded on free tier
- Try different region: `--location westus2`
- Or contact Azure support

### Problem: Health check shows red errors
**Solution**: Resources still starting up
- Wait 5-10 minutes
- Run health check again
- Check Azure Portal for resource status

### Problem: Costs higher than expected
**Solution**: Check what's running
- Go to Portal → Cost Management
- Look for unexpected services
- Delete unused resources
- Stop services when not using

---

## 📚 Helpful Resources

**Azure Documentation**:
- Azure Docs: https://learn.microsoft.com/azure/
- Azure CLI Reference: https://learn.microsoft.com/cli/azure/
- Free Training: https://learn.microsoft.com/training/

**This Project**:
- Complete guide: `docs/setup-guide-beginners.md`
- Quick reference: `QUICK-START.md`
- Architecture: `docs/architecture/overview.md`
- All runbooks: `docs/runbooks/`

**Get Help**:
- Azure Q&A: https://learn.microsoft.com/answers/
- Stack Overflow: Tag [azure]
- This project: Create GitHub issue

---

## ✅ Completion Checklist

You're done when you can check all these:

- ✅ Azure account created with $200 credit
- ✅ Azure CLI installed and working
- ✅ Successfully logged into Azure
- ✅ Budget alerts configured
- ✅ Dev environment deployed successfully
- ✅ Resources verified in Azure Portal
- ✅ Health check script runs and passes
- ✅ Can view costs in Cost Management
- ✅ Can start/stop resources via CLI
- ✅ Understand what each Azure service does

**Congratulations!** 🎉

You've successfully:
- Set up Azure from scratch
- Deployed production-grade infrastructure
- Learned basic cloud operations
- Gained hands-on DevOps experience

**Time to celebrate!** You're now a cloud engineer! ☁️

---

**Total Time**: ~2-3 hours (if following all steps)
**Cost**: ~$2-3/day (covered by free $200 credit)
**Result**: Real-world DevOps portfolio project!

---

**Pro Tip**: Take screenshots of your Azure Portal resources and save them. This is proof of your work for interviews!
