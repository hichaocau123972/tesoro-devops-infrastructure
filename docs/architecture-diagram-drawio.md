# Creating Visual Architecture Diagram - Step-by-Step Guide

Follow these steps to create a professional architecture diagram for your portfolio.

---

## Quick Start: Using Draw.io (Recommended - 100% Free)

### Step 1: Open Draw.io

1. Go to https://app.diagrams.net/
2. Click **"Create New Diagram"**
3. Choose **"Blank Diagram"**
4. Name it: `tesoro-architecture`
5. Click **"Create"**

### Step 2: Load Azure Icons

1. Click **"More Shapes"** (bottom left)
2. Search for **"Azure"** in the search box
3. Check these boxes:
   - ✅ Azure (Basic)
   - ✅ Azure Enterprise
   - ✅ Azure Icons
4. Click **"Apply"**

Now you'll see Azure icons in the left sidebar!

---

## Step 3: Create Your Diagram - Layer by Layer

### Layer 1: Internet/Users (Top)

**Drag these shapes:**
1. Find **"Actor"** shape (person icon) or use a circle
2. Label it: **"Users"**
3. Add an arrow pointing down

### Layer 2: Application Gateway

**From Azure shapes panel:**
1. Drag **"Application Gateway"** icon
2. Label it: **"Application Gateway (WAF)"**
3. Add text box below:
   ```
   • SSL/TLS Termination
   • OWASP Top 10 Protection
   • Layer 7 Load Balancing
   ```
4. Draw arrow from Users to App Gateway

### Layer 3: Virtual Network Container

**Create a large rectangle (container):**
1. Use **Rectangle** shape from basic shapes
2. Make it large (will contain multiple resources)
3. Set fill color: Light blue (#E3F2FD)
4. Set border: Darker blue (#1976D2)
5. Label at top: **"Virtual Network (10.0.0.0/16)"**

### Inside VNet - Layer 3a: App Service Subnet

**Create subnet rectangle:**
1. Smaller rectangle inside VNet
2. Fill color: Light green (#E8F5E9)
3. Label: **"App Service Subnet (10.0.1.0/24)"**

**Add App Service:**
1. Drag **"App Service"** icon from Azure shapes
2. Place inside subnet rectangle
3. Label: **"Tesoro Web App"**
4. Add text:
   ```
   .NET 8.0
   Auto-scaling: 1-5 instances
   Deployment Slots
   ```

### Inside VNet - Layer 3b: Private Endpoints Subnet

**Create another subnet rectangle:**
1. Rectangle below App Service subnet
2. Fill color: Light orange (#FFF3E0)
3. Label: **"Private Endpoints Subnet (10.0.3.0/24)"**

**Add three database icons:**
1. Drag **"SQL Database"** icon
   - Label: **"Azure SQL"**
   - Text: `Basic tier, 2GB`

2. Drag **"PostgreSQL"** icon
   - Label: **"PostgreSQL"**
   - Text: `Burstable B1ms, 32GB`

3. Drag **"Redis Cache"** icon
   - Label: **"Redis Cache"**
   - Text: `Standard C1, 1GB`

**Connect resources:**
- Draw arrows from App Service to each database (inside VNet)
- Label arrows: "Private Connection"

### Layer 4: External Services (Outside VNet)

**Key Vault:**
1. Drag **"Key Vault"** icon
2. Place to the right of VNet
3. Label: **"Azure Key Vault"**
4. Text:
   ```
   • Connection Strings
   • API Keys
   • Certificates
   ```
5. Draw dotted line from App Service to Key Vault
6. Label line: "Managed Identity"

**Storage Account:**
1. Drag **"Storage Account"** icon
2. Place below Key Vault
3. Label: **"Storage Account"**
4. Text:
   ```
   • Blob: User uploads
   • Queue: Async jobs
   ```
5. Draw arrow from App Service to Storage

**Monitoring:**
1. Drag **"Log Analytics"** icon
2. Place at bottom right
3. Label: **"Log Analytics + App Insights"**
4. Draw dotted arrows from all resources to this
5. Label: "Logs & Metrics"

---

## Step 4: Add Color Coding

Use consistent colors for resource types:

| Type | Color | Example Resources |
|------|-------|-------------------|
| **Networking** | Blue (#2196F3) | VNet, NSG, App Gateway |
| **Compute** | Green (#4CAF50) | App Service |
| **Data** | Orange (#FF9800) | SQL, PostgreSQL, Redis |
| **Security** | Red (#F44336) | Key Vault |
| **Storage** | Purple (#9C27B0) | Storage Account |
| **Monitoring** | Teal (#009688) | Log Analytics |

**How to apply colors:**
1. Select a shape
2. Click the **paint bucket** icon in toolbar
3. Choose color from palette
4. Adjust opacity if needed (80% looks good)

---

## Step 5: Add Legends and Notes

**Create a legend box:**
1. Draw a small rectangle in bottom left
2. Add text:
   ```
   LEGEND
   ──────
   ─────► HTTPS Traffic
   ┄┄┄┄► Private Connection
   🔒     Encrypted
   ```

**Add environment badge:**
1. Small rounded rectangle in top right
2. Text: **"Environment: Development"**
3. Fill: Green for dev, Yellow for staging, Red for production

---

## Step 6: Export and Save

**For GitHub/Portfolio:**
1. **File** → **Export As** → **PNG**
2. Settings:
   - ✅ Selection Only: OFF (export whole diagram)
   - ✅ Transparent Background: ON
   - Border Width: 10px
   - Scale: 200% (high quality)
3. Click **"Export"**
4. Save as: `tesoro-architecture.png`

**Also save as PDF for presentations:**
1. **File** → **Export As** → **PDF**
2. Same settings as PNG
3. Save as: `tesoro-architecture.pdf`

**Save the source file:**
1. **File** → **Save As**
2. Choose location
3. Save as: `tesoro-architecture.drawio`
4. Keep this file so you can edit later!

---

## Example Layout (Text Version)

Here's how your diagram should look:

```
┌────────────────────────────────────────────────────────────┐
│                          USERS                              │
│                        (Internet)                           │
└──────────────────────────┬─────────────────────────────────┘
                           │ HTTPS
                           ▼
        ┌──────────────────────────────────────┐
        │    Application Gateway (WAF)         │
        │  • SSL Termination                   │
        │  • OWASP Top 10 Protection          │
        └──────────────┬───────────────────────┘
                       │ Private IP
                       ▼
┌──────────────────────────────────────────────────────────────┐
│          Virtual Network (10.0.0.0/16)                       │
│  ┌───────────────────────────────────────────────────┐      │
│  │  App Service Subnet (10.0.1.0/24)                  │      │
│  │  ┌─────────────────────────────────────────────┐  │      │
│  │  │  Tesoro Web App                             │  │      │
│  │  │  • .NET 8.0                                 │  │      │
│  │  │  • Auto-scaling: 1-5 instances              │  │      │
│  │  └─────────────────┬───────────────────────────┘  │      │
│  └────────────────────┼──────────────────────────────┘      │
│                       │                                       │
│  ┌────────────────────▼──────────────────────────────┐      │
│  │  Private Endpoints Subnet (10.0.3.0/24)           │      │
│  │  ┌─────────┐  ┌──────────┐  ┌─────────────┐     │      │
│  │  │ SQL DB  │  │PostgreSQL│  │ Redis Cache │     │      │
│  │  │ Basic   │  │ B1ms     │  │ Standard C1 │     │      │
│  │  └─────────┘  └──────────┘  └─────────────┘     │      │
│  └───────────────────────────────────────────────────┘      │
└──────────────────────────────────────────────────────────────┘

         ┌─────────────┐            ┌──────────────┐
         │  Key Vault  │            │   Storage    │
         │  🔒 Secrets │            │   Account    │
         └──────▲──────┘            └──────▲───────┘
                │                          │
                │ Managed Identity         │
                └──────────────────────────┘
                           │
                           │
                  ┌────────▼──────────┐
                  │  Log Analytics    │
                  │  + App Insights   │
                  │  (Monitoring)     │
                  └───────────────────┘
```

---

## Alternative: Lucidchart (Also Free)

If you prefer Lucidchart:

1. Go to https://www.lucidchart.com/
2. Create free account
3. Click **"+ New"** → **"Lucidchart"**
4. In left panel, search **"Azure"**
5. Import Azure shape library
6. Follow same layout steps as Draw.io

---

## Alternative: PowerPoint/Google Slides

If you want to use familiar tools:

1. **Download Azure Icons**:
   - Go to: https://learn.microsoft.com/en-us/azure/architecture/icons/
   - Download SVG icon set
   - Unzip the file

2. **Insert in PowerPoint/Slides**:
   - Insert → Pictures → Browse
   - Select Azure icons you need
   - Arrange according to layout above
   - Add shapes, arrows, text boxes

3. **Export**:
   - File → Save As → PNG
   - Choose high resolution

---

## Pro Tips for Great Diagrams

✅ **Consistency**: Use same icon sizes for same resource types
✅ **Alignment**: Use grid/guides to align everything neatly
✅ **White Space**: Don't crowd - leave breathing room
✅ **Labels**: Clear, concise labels on everything
✅ **Flow**: Top to bottom (users → infrastructure → data)
✅ **Color**: Use sparingly - too many colors = confusing
✅ **Legend**: Always include if using colors/symbols

❌ **Avoid**:
- Too many colors
- Tiny text (minimum 10pt)
- Crossing lines (makes it messy)
- Unclear arrows (label what they mean)

---

## What to Include in Your Diagram

### Essential Elements:
- ✅ Users/Internet
- ✅ Application Gateway
- ✅ Virtual Network boundary
- ✅ App Service
- ✅ Databases (SQL, PostgreSQL, Redis)
- ✅ Key Vault
- ✅ Storage Account
- ✅ Log Analytics

### Nice to Have:
- Network Security Groups (NSG icons on subnets)
- Managed Identities (show connections)
- GitHub Actions (CI/CD flow)
- Backup storage
- Budget alerts icon

### For Advanced Diagram:
- Multi-region setup (primary + secondary)
- DR failover flow
- Blue-green deployment slots
- Monitoring alerts workflow

---

## Next Steps

1. **Create the diagram** (spend 30-60 minutes)
2. **Save in multiple formats**:
   - PNG for README.md
   - PDF for presentations
   - Source file (.drawio) for edits

3. **Add to your repository**:
   ```bash
   mkdir -p docs/images
   cp tesoro-architecture.png docs/images/
   ```

4. **Update README.md**:
   ```markdown
   ## Architecture

   ![Tesoro Architecture](docs/images/tesoro-architecture.png)
   ```

5. **Include in interviews**:
   - Have it ready to screen share
   - Print it out if in-person
   - Walk through the flow

---

## Example Script for Presenting Your Diagram

**Opening (30 seconds):**
"This is the Azure infrastructure for Tesoro XP, a loyalty rewards platform. It's a multi-tier, cloud-native architecture with defense-in-depth security."

**Walk Through (2 minutes):**
1. **"Users come in through HTTPS"** → Point to top
2. **"Application Gateway handles SSL and WAF protection"** → OWASP Top 10
3. **"Traffic flows into our private Virtual Network"** → No internet exposure
4. **"App Service hosts the .NET application with auto-scaling"** → 1-5 instances
5. **"Private endpoints connect to databases securely"** → SQL, PostgreSQL, Redis
6. **"Key Vault stores all secrets using Managed Identity"** → No passwords in code
7. **"Everything logs to Log Analytics for monitoring"** → Full observability

**Closing (30 seconds):**
"This design prioritizes security, scalability, and cost optimization. All defined as Infrastructure as Code using Bicep for reproducibility."

---

**Time to create: 30-60 minutes**
**Looks professional: Absolutely!**
**Cost: $0 (all free tools)**

Good luck! 🎨
