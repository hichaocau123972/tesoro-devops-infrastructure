# Azure Resources Learning Guide - Tesoro XP Platform

This guide explains every Azure resource needed for the Tesoro XP loyalty rewards platform, why it's needed, how it works, and how it fits into the overall architecture.

**Purpose**: Understand the complete infrastructure without needing to deploy everything (due to Azure quota restrictions).

---

## Table of Contents

1. [Compute Resources](#compute-resources)
2. [Database Resources](#database-resources)
3. [Networking Resources](#networking-resources)
4. [Security Resources](#security-resources)
5. [Storage Resources](#storage-resources)
6. [Monitoring Resources](#monitoring-resources)
7. [How They All Connect](#how-they-all-connect)

---

## Compute Resources

These are where your application code actually runs.

### 1. App Service Plan

**What it is**: The "server" that hosts your web applications. Think of it as renting a virtual machine optimized for web apps.

**Why Tesoro needs it**: The main Tesoro XP web application (loyalty portal, API) needs somewhere to run 24/7.

**SKUs (Tiers)**:
- **Free (F1)**: Free, but limited to 60 min/day runtime. Good for testing.
- **Basic (B1-B3)**: $13-52/month. Good for dev environments. No auto-scaling.
- **Standard (S1-S3)**: $70-210/month. Auto-scaling, deployment slots, custom domains.
- **Premium (P1v3-P3v3)**: $146-584/month. High performance, zone redundancy, more scale.

**Tesoro Configuration**:
```bicep
// Dev: S1 Standard (1 core, 1.75 GB RAM)
// Staging: P1v3 Premium (2 cores, 8 GB RAM, 2 instances)
// Production: P2v3 Premium (4 cores, 16 GB RAM, 3 instances across zones)
```

**Key Features**:
- **Auto-scaling**: Automatically add more instances when traffic increases
- **Deployment slots**: Blue-green deployments (swap production ↔ staging instantly)
- **VNet integration**: Connect to private databases securely
- **Always On**: Keeps app warm (no cold starts)
- **SSL/TLS**: Free managed certificates

**Interview Talking Points**:
- "I chose Standard S1 for dev to enable VNet integration and deployment slots for testing blue-green deployments"
- "Production uses Premium P2v3 with 3 instances for zone redundancy and high availability"
- "Auto-scaling rules configured to scale out at 70% CPU, scale in at 30% CPU"

---

### 2. App Service (Web App)

**What it is**: The actual web application hosted on the App Service Plan. It's like installing software on the server.

**Why Tesoro needs it**: This IS the Tesoro XP application - the loyalty portal, REST API, and admin dashboard.

**Technology Stack**:
```bicep
linuxFxVersion: 'DOTNETCORE|8.0'  // .NET 8 runtime
```

**Configuration**:
- **HTTPS Only**: Force all traffic to use encryption
- **Client Affinity**: Disabled (for stateless API, better load balancing)
- **Health Check Path**: `/health` endpoint for monitoring
- **Environment Variables**: Stored as App Settings (connection strings, feature flags)

**CI/CD Integration**:
- GitHub Actions deploys to staging slot first
- Run automated tests
- If tests pass, swap staging → production (zero downtime)
- If tests fail, keep old production running

**Interview Talking Points**:
- "Configured health check endpoints so Azure can automatically restart unhealthy instances"
- "Using deployment slots for zero-downtime deployments with automatic rollback"
- "Integrated with Application Insights for distributed tracing and performance monitoring"

---

### 3. Container Apps (Optional - Not in Current Template)

**What it is**: Serverless containers. Like App Service but for Docker containers. More flexible, scales to zero.

**Why Tesoro might need it**: For background jobs like:
- Processing reward point calculations
- Sending email notifications
- Generating monthly reports

**When to use vs App Service**:
- **App Service**: Long-running web apps, APIs
- **Container Apps**: Jobs, microservices, event-driven workloads

---

### 4. Function Apps (Optional - Not in Current Template)

**What it is**: Serverless functions. Code that runs in response to events. Pay only when it executes.

**Why Tesoro might need it**:
- Webhook handlers (when user earns points, trigger immediately)
- Scheduled jobs (cron-style - cleanup expired rewards daily)
- Queue processing (process thousands of transactions asynchronously)

**Example Use Case**:
```
User makes purchase → Event Grid → Function App → Calculate points → Update database
```

---

## Database Resources

These store all the persistent data.

### 5. Azure SQL Database

**What it is**: Microsoft's fully managed SQL Server in the cloud. Like SQL Server but Azure handles backups, patching, high availability.

**Why Tesoro needs it**: Primary database for transactional data:
- User accounts and profiles
- Point balances and transaction history
- Reward catalog
- Order history
- Merchant partnerships

**SKUs (Tiers)**:
- **Basic**: $5/month, 2 GB. Good for dev/test.
- **Standard (S2)**: $75/month, 50 GB. Good for staging.
- **Premium**: $465+/month. Low latency, high IOPS for production.
- **Hyperscale**: Elastic, up to 100 TB. Enterprise scale.

**Tesoro Configuration**:
```bicep
// Dev: Basic (2 GB)
// Staging: Standard S2 (50 GB)
// Production: Hyperscale Gen5 4 cores (auto-scaling storage)
```

**Key Features**:
- **Automatic Backups**: Point-in-time restore up to 35 days
- **Geo-Replication**: Readable secondary in different region (disaster recovery)
- **Advanced Threat Protection**: Detects SQL injection attempts
- **Transparent Data Encryption (TDE)**: Data encrypted at rest
- **Private Endpoint**: Database not accessible from public internet

**Schema Design for Tesoro**:
```sql
-- Example tables
Users (UserId, Email, PasswordHash, CreatedAt)
PointsBalance (UserId, CurrentPoints, LifetimePoints)
Transactions (TransactionId, UserId, Points, Type, CreatedAt)
Rewards (RewardId, Name, PointsCost, Stock, ExpiresAt)
UserRewards (UserId, RewardId, RedeemedAt, Status)
```

**Interview Talking Points**:
- "Configured automatic failover to secondary region with 99.99% SLA"
- "Using private endpoints so database is only accessible from within VNet"
- "Point-in-time restore configured for 35 days for compliance requirements"
- "TDE enabled for PCI DSS compliance (payment card data protection)"

---

### 6. PostgreSQL Flexible Server

**What it is**: Open-source PostgreSQL database, fully managed by Azure. Alternative to SQL Server.

**Why Tesoro might need it**:
- Some apps prefer PostgreSQL over SQL Server
- Better for JSON document storage (loyalty program rules, dynamic rewards)
- Cost-effective for read-heavy workloads

**Tesoro Use Case**: Store non-transactional data:
- Analytics and reporting data
- User preferences (JSON documents)
- Audit logs
- Time-series data (point accrual trends)

**SKUs**:
- **Burstable B1ms**: $15/month, 1 vCore, 2 GB RAM. Dev/test.
- **General Purpose**: $73+/month. Production workloads.
- **Memory Optimized**: High-RAM scenarios.

**Key Features**:
- **High Availability**: Standby replica in different zone
- **Read Replicas**: Offload read queries for better performance
- **Extensions**: PostGIS (geo data), pg_cron (scheduled jobs)
- **Flexible Maintenance Windows**: Control when updates happen

**Interview Talking Points**:
- "Using PostgreSQL for analytics workloads to keep transactional SQL Server performant"
- "Configured read replicas for reporting dashboards to avoid impacting production"
- "Leveraging JSONB columns for flexible reward rule definitions"

---

### 7. Redis Cache

**What it is**: In-memory data store. Extremely fast (microsecond latency). Used for caching and session storage.

**Why Tesoro needs it**: Performance optimization:
- Cache user point balances (avoid database query on every page load)
- Session storage (user login state)
- Cache reward catalog (mostly static, update hourly)
- Rate limiting (prevent abuse - max 100 API calls per user per minute)
- Real-time leaderboards (top users by points)

**SKUs**:
- **Basic C0**: $16/month, 250 MB. Dev only (no SLA, no replication).
- **Standard C1**: $75/month, 1 GB. Production (replicated, 99.9% SLA).
- **Premium P1**: $300+/month. Clustering, persistence, VNet injection.

**Common Cache Patterns**:
```csharp
// Cache-aside pattern (most common)
var userPoints = await redis.GetAsync<int>($"points:{userId}");
if (userPoints == null) {
    userPoints = await database.GetPointsAsync(userId);
    await redis.SetAsync($"points:{userId}", userPoints, expiry: TimeSpan.FromMinutes(15));
}
return userPoints;
```

**Performance Impact**:
- Database query: 50-200ms
- Redis cache hit: 1-5ms
- **40x faster!**

**Interview Talking Points**:
- "Implemented cache-aside pattern to reduce database load by 80%"
- "Using Redis for distributed rate limiting across all app instances"
- "Configured 15-minute TTL on user point balances to balance freshness vs performance"
- "Standard tier provides 99.9% SLA with automatic replication"

---

## Networking Resources

These create secure, isolated networks for your resources.

### 8. Virtual Network (VNet)

**What it is**: Your own private network in Azure. Like having your own data center network in the cloud.

**Why Tesoro needs it**: Security isolation:
- App Services talk to databases privately (not over public internet)
- Control what can talk to what (network segmentation)
- Connect to on-premises networks if needed (hybrid cloud)

**Configuration**:
```bicep
Address Space: 10.0.0.0/16  // 65,536 IP addresses available

Subnets:
- app-service-subnet:     10.0.1.0/24 (256 IPs) - App Services
- container-apps-subnet:  10.0.2.0/24 (256 IPs) - Container workloads
- private-endpoints-subnet: 10.0.3.0/24 (256 IPs) - Database connections
- gateway-subnet:         10.0.4.0/24 (256 IPs) - Application Gateway (load balancer)
```

**Why Subnets?**:
Each subnet has its own security rules. Like having different locked rooms in a building:
- App Services can access databases
- Databases CANNOT initiate connections to app services
- Public internet CANNOT reach databases

**Interview Talking Points**:
- "Implemented network segmentation with separate subnets for compute, data, and networking layers"
- "Used /24 CIDR blocks providing 256 IPs per subnet for scalability"
- "VNet integration enables private, secure communication between services without traversing public internet"

---

### 9. Network Security Groups (NSGs)

**What it is**: Firewall rules for subnets. Control what traffic is allowed in/out.

**Why Tesoro needs it**: Defense in depth:
- Block all traffic by default
- Only allow what's needed
- Prevent lateral movement if one service is compromised

**Example Rules**:
```bicep
// App Service NSG
Allow HTTPS (443) from Internet → App Service subnet
Allow HTTPS (443) from App Service subnet → Private Endpoints subnet
Deny all other inbound traffic

// Database NSG
Allow PostgreSQL (5432) from App Service subnet → Private Endpoints
Allow SQL (1433) from App Service subnet → Private Endpoints
Deny all traffic from Internet
```

**Security Principle**: "Zero Trust" - assume breach, verify everything

**Interview Talking Points**:
- "Implemented least privilege network access - only allowing required ports and sources"
- "NSG logs sent to Log Analytics for security monitoring and threat detection"
- "Configured deny-by-default rules with explicit allow rules for required traffic"

---

### 10. Private Endpoints

**What it is**: Brings Azure services (like SQL Database) INTO your VNet. Gives them a private IP address.

**Why Tesoro needs it**: Security compliance:
- Database has NO public IP address
- Only accessible from within VNet
- PCI DSS requirement for payment data

**Without Private Endpoint**:
```
App Service → [Public Internet] → SQL Database (sqlserver.database.windows.net)
Risk: Traffic goes over public internet, attackers can see connection
```

**With Private Endpoint**:
```
App Service → [Private VNet] → SQL Database (10.0.3.5)
Secure: Traffic never leaves your private network
```

**Cost**: $7.30/month per endpoint

**Interview Talking Points**:
- "Configured private endpoints for all data services to meet PCI DSS compliance"
- "Database connections use RFC 1918 private IPs, eliminating internet exposure"
- "Private DNS zones ensure apps automatically resolve to private IPs"

---

### 11. Application Gateway (Optional - Not in Current Template)

**What it is**: Layer 7 (HTTP/HTTPS) load balancer with Web Application Firewall (WAF).

**Why Tesoro needs it**: Production security and performance:
- WAF blocks SQL injection, XSS attacks, bot traffic
- SSL/TLS termination (offload encryption from app servers)
- Load balance across multiple app instances
- Path-based routing (/api → API service, /admin → Admin service)

**Cost**: ~$125/month + $0.008 per GB processed

**Interview Talking Points**:
- "WAF configured with OWASP Top 10 ruleset to block common web attacks"
- "SSL termination at Application Gateway reduces compute load on app servers"
- "Health probes automatically remove unhealthy backends from rotation"

---

## Security Resources

These manage secrets, identities, and access control.

### 12. Azure Key Vault

**What it is**: Secure storage for secrets, encryption keys, and certificates. Like a digital safe.

**Why Tesoro needs it**: Security best practice:
- Never hardcode passwords in code
- Store database connection strings securely
- Store API keys (payment gateway, email service)
- Store SSL certificates
- Rotate secrets without redeploying apps

**What Goes in Key Vault**:
```
Secrets:
- SQL-ConnectionString
- PostgreSQL-Password
- Redis-AccessKey
- PaymentGateway-APIKey
- SendGrid-APIKey
- JWT-SigningKey

Certificates:
- *.tesoro.com (wildcard SSL)

Keys:
- data-encryption-key (for encrypting PII)
```

**Access Control**:
- App Service uses Managed Identity (no passwords needed!)
- Developers get read-only access
- Only Key Vault admins can modify

**Cost**: $0.03 per 10,000 operations (very cheap)

**Interview Talking Points**:
- "All secrets stored in Key Vault with RBAC controlling access"
- "App Services authenticate using Managed Identity - no credentials in code"
- "Key Vault integrated with App Settings for automatic secret injection"
- "Audit logs track all secret access for compliance"

---

### 13. Managed Identities

**What it is**: Automatically managed credentials for Azure services. No passwords to manage!

**Why Tesoro needs it**: Eliminate credential management:
- App Service needs to read Key Vault → uses Managed Identity
- App Service writes logs → uses Managed Identity
- No API keys to rotate, no passwords to leak

**How It Works**:
```csharp
// Old way (BAD - password in code)
var client = new KeyVaultClient(new KeyVaultClient.AuthenticationCallback(
    async (authority, resource, scope) => {
        var credential = new ClientCredential(clientId, clientSecret); // SECRET IN CODE!
        return await GetToken(credential);
    }
));

// New way (GOOD - Managed Identity)
var client = new SecretClient(
    new Uri("https://tesorodevkvyc6ih4pl.vault.azure.net"),
    new DefaultAzureCredential() // Automatically uses Managed Identity!
);
```

**Types**:
- **System-Assigned**: Created automatically with the resource, deleted when resource deleted
- **User-Assigned**: Created separately, can be assigned to multiple resources

**Tesoro Uses User-Assigned** for:
- app-identity: Used by App Service
- db-identity: Used by database admin tasks
- container-identity: Used by Container Apps

**Interview Talking Points**:
- "Eliminated all service credentials using Managed Identities"
- "Configured RBAC so app-identity has Key Vault Secrets User role"
- "No secrets in code, configuration, or CI/CD pipelines"

---

## Storage Resources

These store files, blobs, and unstructured data.

### 14. Storage Account

**What it is**: Highly scalable object storage. Like Amazon S3 or Google Cloud Storage.

**Why Tesoro needs it**: Store non-database files:
- User profile pictures
- Reward images (product photos)
- Receipt uploads (for point verification)
- Export files (CSV reports)
- Backups (database exports)
- Static website files (optional - host React frontend)

**Services Inside Storage Account**:

**Blob Storage** (like folders of files):
```
Container: profile-pictures/
- user-123.jpg
- user-456.png

Container: reward-images/
- reward-001.jpg
- reward-002.png

Container: receipts/
- 2025/01/receipt-abc123.pdf
```

**Table Storage** (NoSQL key-value store):
- Simple, cheap storage for logs or non-relational data
- Alternative to PostgreSQL for some use cases

**Queue Storage** (message queues):
- Decouple services (API puts message in queue, background job processes it)
- Example: User uploads receipt → Queue message → Function processes asynchronously

**File Storage** (SMB file shares):
- Share files across multiple app instances
- Useful for legacy apps

**Cost**:
- **Storage**: $0.018/GB/month (Hot tier)
- **Transactions**: $0.0004 per 10,000 operations
- Very cheap! 100 GB + 1M requests = ~$2/month

**Security**:
- **Private Only**: No public access
- **SAS Tokens**: Time-limited URLs for file access
- **Encryption**: All data encrypted at rest (AES-256)

**Interview Talking Points**:
- "Blob storage for user-uploaded content with private access via SAS tokens"
- "Configured lifecycle management to archive old receipts to Cool tier after 90 days"
- "Geo-redundant storage (GRS) for disaster recovery - data replicated to secondary region"

---

## Monitoring Resources

These track health, performance, and costs.

### 15. Log Analytics Workspace

**What it is**: Central repository for all logs. Think of it as a giant searchable database of everything happening in your infrastructure.

**Why Tesoro needs it**: Troubleshooting and insights:
- App Service logs → "Why did the app crash at 3am?"
- Database logs → "Which queries are slow?"
- NSG logs → "Is someone trying to attack us?"
- Metric data → "CPU usage spiked - need to scale?"

**Query Language (KQL - Kusto)**:
```kql
// Find all errors in last 24 hours
AppServiceHTTPLogs
| where TimeGenerated > ago(24h)
| where ScStatusCode >= 500
| summarize count() by ScStatusCode, CsHost
| order by count_ desc

// Find slow database queries
AzureDiagnostics
| where ResourceProvider == "MICROSOFT.SQL"
| where duration_s > 5  // Queries over 5 seconds
| project TimeGenerated, query_text_s, duration_s
| order by duration_s desc
```

**Retention**: 30-90 days (configurable)

**Cost**: First 5 GB/day free, then $2.30/GB

**Interview Talking Points**:
- "Centralized logging to Log Analytics for all services"
- "Created KQL queries for common troubleshooting scenarios"
- "Configured 30-day retention for cost optimization"

---

### 16. Application Insights

**What it is**: APM (Application Performance Monitoring) tool. Tracks application-level metrics, distributed tracing, and user telemetry.

**Why Tesoro needs it**: Understand app performance:
- How long does it take to load the rewards page?
- Which API endpoint is slowest?
- Are users getting errors?
- Where do users drop off in the checkout flow?

**What It Tracks**:
- **Requests**: HTTP requests, response times, status codes
- **Dependencies**: Calls to database, Redis, external APIs
- **Exceptions**: Crashes, errors with stack traces
- **Custom Events**: "User redeemed reward", "Points expired"
- **Traces**: Detailed logs with correlation across services
- **User Behavior**: Page views, sessions, funnel analysis

**Example Insights**:
```
Request: GET /api/rewards
- Duration: 450ms
- Dependencies:
  - Redis cache: 2ms (cache miss)
  - SQL query: 420ms ⚠️ SLOW!
  - API response: 28ms
- Result: 200 OK

Action: Investigate slow SQL query, add index
```

**Distributed Tracing**:
```
User Request → API Gateway → App Service → SQL Database → Redis
  [correlation_id: abc-123 tracked across all services]
```

**Cost**: $2.30/GB after 5 GB/month free

**Interview Talking Points**:
- "Application Insights provides end-to-end distributed tracing across services"
- "Set up custom events to track business metrics like reward redemptions"
- "Configured availability tests to ping app every 5 minutes from multiple regions"
- "Smart Detection automatically alerts on anomalies like sudden error spikes"

---

### 17. Action Groups

**What it is**: Notification mechanism. When alert triggers, what should happen?

**Why Tesoro needs it**: Get notified of problems:
- Email: "CPU > 90% for 15 minutes"
- SMS: "Database is down!"
- Webhook: Auto-create incident ticket in Jira
- Azure Function: Auto-scale or remediate

**Tesoro Action Group**:
```bicep
Name: tesoro-dev-ag
Actions:
- Email: devops-team@tesoro.com
- Email: dennis.brady@skyeluxtechnology.com
- SMS: +1-555-123-4567
- Webhook: https://hooks.slack.com/... (Slack channel)
```

**Cost**: Free (up to 1000 SMS, unlimited email/webhook)

---

### 18. Metric Alerts

**What it is**: Monitors metrics and triggers Action Groups when thresholds exceeded.

**Tesoro Alerts**:
```yaml
High CPU Alert:
  Metric: CPU Percentage
  Condition: > 80%
  Duration: 15 minutes
  Action: Email devops-team

Low Disk Space:
  Metric: Database Storage Used
  Condition: > 90%
  Action: Email + create Jira ticket

Failed Requests:
  Metric: HTTP 5xx errors
  Condition: > 10 per minute
  Action: SMS + Slack

High Response Time:
  Metric: Average response time
  Condition: > 5 seconds
  Duration: 5 minutes
  Action: Auto-scale + notify
```

**Interview Talking Points**:
- "Configured alerts for key SLIs - availability, latency, error rate"
- "Multi-stage alerting - warning email at 70% CPU, critical SMS at 90%"
- "Auto-remediation actions via webhooks to Azure Automation"

---

### 19. Workbooks

**What it is**: Custom dashboards. Visualize data from Log Analytics and metrics.

**Why Tesoro needs it**: Operational visibility:
- Executive dashboard: "Total users, points distributed, rewards redeemed"
- Operations dashboard: "Requests/sec, error rate, latency percentiles"
- Cost dashboard: "Spending by service, projected monthly cost"

**Example Workbook Sections**:
```
[Tesoro XP - Operations Dashboard]

System Health:
- App Service: ✅ Healthy (3 instances)
- SQL Database: ✅ Healthy (67% DTU)
- Redis Cache: ✅ Healthy (45% memory)

Performance (Last Hour):
- Requests: 45,234
- Avg Response Time: 124ms
- Error Rate: 0.02%
- P95 Latency: 450ms

Top Slow Queries:
1. GetUserRewardHistory - 1,245ms
2. CalculateMonthlyPoints - 892ms
3. GenerateReportData - 734ms
```

**Interview Talking Points**:
- "Created custom workbooks for different audiences - executives, developers, operations"
- "Real-time dashboards using KQL queries for operational insights"
- "Workbooks parameterized by environment (dev/staging/production)"

---

## How They All Connect

### Architecture Flow

```
                              Internet
                                 |
                                 v
                      [ Application Gateway ]
                      (WAF, SSL Termination)
                                 |
                                 v
                    [ Virtual Network - 10.0.0.0/16 ]
                                 |
            +--------------------+--------------------+
            |                                         |
            v                                         v
   [ App Service Subnet ]              [ Private Endpoints Subnet ]
     - App Service (S1)                   - SQL Database (Private)
     - Container Apps                     - PostgreSQL (Private)
                                          - Redis Cache (Private)
            |                                         ^
            |                                         |
            +-----------------------------------------+
                    (Private VNet Communication)

                    [ Key Vault ]
                  (Secrets Storage)
                         ^
                         |
                  (Managed Identity)
                         |
                    [ App Service ]

                    [ Storage Account ]
                  (Blobs, Files, Queues)
                         ^
                         |
                    [ App Service ]
                  (Store user uploads)

                   [ Log Analytics ]
                 (Centralized Logging)
                         ^
                         |
                +--------+--------+
                |        |        |
         [App Service] [SQL] [Redis]
         (All services send logs)

                 [ Application Insights ]
                  (App Performance)
                         ^
                         |
                   [ App Service ]
                (Telemetry SDK embedded)
```

### Request Flow Example: User Redeems Reward

```
1. User clicks "Redeem Reward" button in browser
   ↓
2. HTTPS request → Application Gateway (WAF checks for attacks)
   ↓
3. App Gateway → App Service (via private subnet)
   ↓
4. App Service authenticates user (checks JWT token)
   ↓
5. App Service reads reward details from Redis cache
   - Cache hit? Return immediately (fast path)
   - Cache miss? Query SQL Database
   ↓
6. Check user points balance from SQL Database
   ↓
7. If sufficient points:
   - Deduct points from balance
   - Create redemption record
   - Send message to Queue Storage (for email processing)
   ↓
8. Application Insights logs:
   - Request duration
   - Dependencies (Redis, SQL)
   - Custom event: "RewardRedeemed"
   ↓
9. Return success response to user
   ↓
10. Background job (Function App) picks up queue message
    - Sends confirmation email
    - Updates analytics
```

### Data Flow

```
User Data → App Service → SQL Database (transactional data)
                       → Redis Cache (session, temporary)
                       → Storage Account (profile pictures)
                       → PostgreSQL (analytics data)

All Logs → Log Analytics → Workbooks (visualization)
                        → Alerts (notifications)

Secrets → Key Vault → App Service (via Managed Identity)
```

---

## Interview Preparation

### Key Questions You Should Be Ready to Answer

**Q: "Why did you choose Azure over AWS or GCP?"**
A: "The job description specified Azure expertise. I focused on mastering one cloud deeply rather than surface-level knowledge of multiple clouds. Azure's integration with .NET was also a factor since Tesoro uses .NET."

**Q: "How do you handle database credentials?"**
A: "Never in code or config files. All secrets stored in Key Vault. App Services use Managed Identity to authenticate to Key Vault, eliminating credential management entirely."

**Q: "How would you scale this if traffic increased 10x?"**
A:
- "Enable auto-scaling on App Service Plan based on CPU/memory metrics"
- "Add read replicas for PostgreSQL to offload queries"
- "Increase Redis cache size or move to Premium for clustering"
- "Implement CDN for static content"
- "Consider database sharding if single SQL instance becomes bottleneck"

**Q: "What's your disaster recovery strategy?"**
A:
- "SQL Database geo-replication to secondary region (East US → West US)"
- "GRS (Geo-Redundant Storage) for Storage Account"
- "Infrastructure as Code (Bicep) allows redeployment to new region in minutes"
- "RPO: 15 minutes (database replication lag), RTO: 1 hour (manual failover)"

**Q: "How do you monitor costs?"**
A:
- "Budget alerts at $50, $75, $90 spending levels"
- "Daily cost anomaly monitoring"
- "Resource tags for cost allocation by environment and team"
- "Log Analytics capped at 1GB/day to control costs"
- "Auto-shutdown of dev resources overnight using Azure Automation"

**Q: "Security concerns with this architecture?"**
A:
- "All data services on private endpoints (no internet exposure)"
- "NSGs implement network segmentation and least privilege"
- "TDE enabled for encryption at rest"
- "TLS 1.2 minimum for all connections"
- "WAF protects against OWASP Top 10"
- "Managed Identities eliminate credential sprawl"
- "Regular vulnerability scanning with Azure Defender"

---

## What You've Learned (Even Without Deploying)

✅ **Infrastructure as Code**: Complete Bicep templates for production environment
✅ **Networking**: VNet design, subnets, NSGs, private endpoints
✅ **Security**: Zero trust architecture, Key Vault, Managed Identity
✅ **Compute**: App Services, scaling strategies, deployment slots
✅ **Data**: SQL, PostgreSQL, Redis - when to use each
✅ **Monitoring**: Comprehensive logging, alerting, dashboards
✅ **Cost Management**: Budget alerts, SKU selection, optimization
✅ **Troubleshooting**: Quota issues, deployment errors, soft delete

---

## Next Steps for Your Job Application

1. **GitHub Repository**: Push all code to GitHub with README
2. **Architecture Diagram**: Create visual diagram (use draw.io or Lucidchart)
3. **Demo Video**: Record 5-minute walkthrough of your templates
4. **Blog Post**: Write about challenges faced and solutions
5. **LinkedIn Post**: "Just built complete Azure infrastructure for loyalty platform..."

**You don't need to deploy everything to show you know your stuff!**

---

**Remember**: The templates, documentation, and understanding are worth MORE in an interview than saying "I deployed it once." Anyone can click buttons - you understand the WHY behind every decision.
