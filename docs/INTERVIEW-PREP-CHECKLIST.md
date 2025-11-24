# DevOps Engineer Interview Preparation Checklist

Comprehensive checklist for interviewing for the Tesoro XP DevOps Engineer role.

---

## Pre-Interview Preparation

### Portfolio Preparation (Complete These First)

- [ ] **GitHub Repository Created**
  - [ ] All Bicep templates committed
  - [ ] Documentation folder organized
  - [ ] README.md written (see template below)
  - [ ] .gitignore configured (no secrets!)
  - [ ] Repository is public (for portfolio showcase)

- [ ] **Architecture Diagram Created**
  - [ ] Visual diagram created using Draw.io or Lucidchart
  - [ ] Exported as PNG/PDF
  - [ ] Added to docs/ folder
  - [ ] Referenced in README

- [ ] **Documentation Review**
  - [ ] Read through LEARNING-GUIDE.md completely
  - [ ] Understand every Azure resource and why it's needed
  - [ ] Review ARCHITECTURE-DIAGRAM.md
  - [ ] Review cost-estimate.md

- [ ] **LinkedIn/Resume Updated**
  - [ ] Add project to experience section
  - [ ] Link to GitHub repository
  - [ ] Keywords: Azure, Bicep, IaC, DevOps, CI/CD
  - [ ] Post about the project with architecture diagram

---

## Technical Knowledge Checklist

### Azure Fundamentals ✅

- [ ] **Compute Services**
  - [ ] Explain App Service vs VMs vs Container Apps vs Functions
  - [ ] Describe App Service Plans and SKUs (Free, Basic, Standard, Premium)
  - [ ] Explain auto-scaling (scale-out vs scale-up)
  - [ ] Understand deployment slots and blue-green deployments
  - [ ] Know when to use each compute option

- [ ] **Database Services**
  - [ ] Explain Azure SQL Database SKUs (Basic, Standard, Premium, Hyperscale)
  - [ ] Understand PostgreSQL Flexible Server
  - [ ] Explain Redis Cache use cases (caching, sessions, rate limiting)
  - [ ] Describe backup and recovery options
  - [ ] Know difference between SQL Database and SQL Managed Instance

- [ ] **Networking**
  - [ ] Explain Virtual Networks (VNet) and subnets
  - [ ] Understand CIDR notation (10.0.0.0/16, 10.0.1.0/24)
  - [ ] Describe Network Security Groups (NSGs) and rules
  - [ ] Explain Private Endpoints vs Service Endpoints
  - [ ] Understand Application Gateway (Layer 7 load balancer + WAF)
  - [ ] Know the difference between public IP, private IP, and NAT

- [ ] **Security**
  - [ ] Explain Azure Key Vault and when to use it
  - [ ] Understand Managed Identities (System vs User-Assigned)
  - [ ] Describe RBAC (Role-Based Access Control)
  - [ ] Know encryption types (at rest vs in transit)
  - [ ] Understand Azure AD integration

- [ ] **Storage**
  - [ ] Explain Blob Storage vs File Storage vs Queue Storage
  - [ ] Understand storage tiers (Hot, Cool, Archive)
  - [ ] Describe replication options (LRS, GRS, ZRS)
  - [ ] Know when to use each storage type

- [ ] **Monitoring**
  - [ ] Explain Log Analytics Workspace and KQL queries
  - [ ] Understand Application Insights and distributed tracing
  - [ ] Describe metric alerts vs log alerts
  - [ ] Explain Action Groups
  - [ ] Know how to troubleshoot using logs

---

### Infrastructure as Code ✅

- [ ] **Bicep Knowledge**
  - [ ] Explain what Bicep is and why use it vs ARM templates
  - [ ] Describe modular template design
  - [ ] Understand parameters, variables, and outputs
  - [ ] Explain idempotency (can run deployment multiple times safely)
  - [ ] Know how to validate templates (bicep build, what-if)

- [ ] **Bicep vs Terraform**
  - [ ] When to use Bicep: Azure-native, simpler, no state file
  - [ ] When to use Terraform: Multi-cloud, mature ecosystem
  - [ ] Can explain trade-offs of each

- [ ] **Template Best Practices**
  - [ ] Parameterize for multiple environments (dev/staging/prod)
  - [ ] Use modules for reusability
  - [ ] Tag all resources for cost tracking
  - [ ] Implement naming conventions
  - [ ] Store sensitive values in Key Vault

---

### CI/CD & DevOps Practices ✅

- [ ] **GitHub Actions**
  - [ ] Explain workflow, job, step hierarchy
  - [ ] Understand triggers (push, pull_request, schedule)
  - [ ] Describe secrets management in GitHub
  - [ ] Know how to use OIDC for Azure authentication (no secrets!)
  - [ ] Understand approval gates and environments

- [ ] **Deployment Strategies**
  - [ ] Explain blue-green deployment
  - [ ] Describe canary deployment
  - [ ] Understand rolling updates
  - [ ] Know when to use deployment slots

- [ ] **Git Workflow**
  - [ ] Describe feature branch workflow
  - [ ] Explain pull request process
  - [ ] Understand GitFlow (feature, develop, main branches)
  - [ ] Know how to handle merge conflicts

- [ ] **Testing Strategies**
  - [ ] Unit tests (test individual functions)
  - [ ] Integration tests (test services together)
  - [ ] Smoke tests (basic health check after deployment)
  - [ ] Load tests (performance testing)

---

### Monitoring & Observability ✅

- [ ] **Logging**
  - [ ] Know the 3 pillars: Logs, Metrics, Traces
  - [ ] Understand structured logging vs unstructured
  - [ ] Explain log levels (DEBUG, INFO, WARN, ERROR)
  - [ ] Describe log retention strategies

- [ ] **Metrics & Alerts**
  - [ ] Explain SLI, SLO, SLA
    - SLI = Service Level Indicator (e.g., 99.5% uptime)
    - SLO = Service Level Objective (internal goal)
    - SLA = Service Level Agreement (contract with customer)
  - [ ] Describe alert fatigue and how to avoid it
  - [ ] Understand threshold-based vs anomaly-based alerts

- [ ] **Distributed Tracing**
  - [ ] Explain correlation IDs
  - [ ] Understand how Application Insights traces requests
  - [ ] Describe dependency tracking

---

### Security Best Practices ✅

- [ ] **Defense in Depth**
  - [ ] Explain layered security approach
  - [ ] Describe zero trust architecture
  - [ ] Understand principle of least privilege

- [ ] **Common Vulnerabilities**
  - [ ] OWASP Top 10 (SQL injection, XSS, broken auth, etc.)
  - [ ] How WAF protects against these
  - [ ] Importance of input validation

- [ ] **Secrets Management**
  - [ ] Never commit secrets to Git (use .gitignore, pre-commit hooks)
  - [ ] Store in Key Vault, reference in code via Managed Identity
  - [ ] Rotate secrets regularly
  - [ ] Use environment variables for configuration

- [ ] **Compliance**
  - [ ] PCI DSS for payment data
  - [ ] GDPR for user privacy
  - [ ] Audit logging for compliance

---

## Interview Question Practice

### Technical Questions (Must Practice!)

#### Architecture & Design

**Q: "Walk me through the architecture of your Tesoro XP project."**

**Answer Structure**:
1. High-level overview (3 tiers: presentation, application, data)
2. User request flow (Gateway → App Service → Database)
3. Security layers (WAF, Private Endpoints, Key Vault)
4. Monitoring setup (Log Analytics, Application Insights)

**Practice Out Loud**: Should take 3-5 minutes

---

**Q: "Why did you choose these specific Azure services?"**

**Answer**:
- **App Service**: PaaS eliminates OS management, built-in auto-scaling, deployment slots for zero-downtime
- **SQL Database**: Managed service with automatic backups, point-in-time restore, geo-replication
- **Redis Cache**: Sub-millisecond latency for frequently accessed data, reduces database load 80%
- **Private Endpoints**: Security requirement - no public internet exposure for data services
- **Key Vault**: Centralized secrets management with audit logging for compliance

---

**Q: "How would you scale this architecture for 10x traffic?"**

**Answer**:
1. **Horizontal scaling**: App Service auto-scale from 1 to 10 instances based on CPU
2. **Database scaling**: Add read replicas for PostgreSQL, use SQL Database Premium/Hyperscale
3. **Caching**: Increase Redis tier to Premium with clustering, implement CDN for static assets
4. **Global distribution**: Azure Front Door for geo-distribution and caching at edge
5. **Async processing**: Move heavy operations to queues + Azure Functions
6. **Database sharding**: If single DB becomes bottleneck (shard by user ID)

---

**Q: "What's your disaster recovery strategy?"**

**Answer**:
- **RPO (Recovery Point Objective)**: 15 minutes - SQL geo-replication lag
- **RTO (Recovery Time Objective)**: 1 hour - manual failover to secondary region
- **Backup strategy**:
  - SQL: Point-in-time restore 35 days, automated backups every hour
  - Storage: Geo-redundant storage (GRS), data replicated to secondary region
  - Infrastructure: Bicep templates allow full environment recreation in 20 minutes
- **Failover process**: DNS cutover to West US region, application restarts, verify health checks
- **Testing**: Quarterly DR drills to validate process

---

**Q: "How do you handle secrets and credentials?"**

**Answer**:
- **Never in code or config**: All secrets stored in Azure Key Vault
- **Managed Identity**: App Services authenticate to Key Vault without passwords
- **RBAC**: app-identity has "Key Vault Secrets User" role, read-only access
- **Rotation**: Automated secret rotation every 90 days via Azure Automation
- **Audit**: All Key Vault access logged to Log Analytics for security monitoring
- **CI/CD**: GitHub Actions uses OIDC for Azure auth, no secrets in GitHub

---

#### DevOps & CI/CD

**Q: "Describe your CI/CD pipeline."**

**Answer**:

**Infrastructure Pipeline**:
1. Developer pushes Bicep template to feature branch
2. GitHub Actions runs validation (bicep build, what-if preview)
3. Pull request requires peer review
4. Merge to main → auto-deploy to dev environment
5. Smoke tests run (health endpoints, connectivity tests)
6. Manual approval gate for staging deployment
7. Deploy to staging → run integration tests
8. Manual approval for production
9. Blue-green deployment to production using deployment slots
10. Monitor Application Insights for errors, auto-rollback if error rate > 5%

**Application Pipeline**:
1. Build .NET application, run unit tests (must have >80% coverage)
2. Security scan with Snyk (check for vulnerable dependencies)
3. Build Docker image, push to Azure Container Registry
4. Deploy to staging slot
5. Run smoke tests + integration tests
6. If all pass, swap staging → production (zero downtime)
7. Monitor for 15 minutes, rollback if issues detected

---

**Q: "How would you implement blue-green deployment?"**

**Answer**:
- App Service has deployment slots (production + staging)
- **Blue (production)**: Currently serving users, version 1.0
- **Green (staging)**: Deploy version 2.0 here
- Run tests on green slot (users can't see it)
- When ready: swap staging ↔ production (instant, no downtime)
- If issues found: swap back immediately (instant rollback)
- **Benefits**: Zero downtime, instant rollback, test in production-like environment

---

#### Monitoring & Troubleshooting

**Q: "An alert fires: 'CPU > 90% for 15 minutes.' What do you do?"**

**Answer** (Systematic approach):

**Immediate**:
1. Check Application Insights for request volume spike
2. Verify auto-scaling is working (is it scaling out?)
3. Check for slow database queries in Log Analytics
4. Look for exceptions or errors in App Service logs

**Investigation**:
```kql
// Check request volume
AppServiceHTTPLogs
| where TimeGenerated > ago(1h)
| summarize RequestsPerMinute = count() by bin(TimeGenerated, 1m)
| render timechart

// Find slow requests
AppServiceHTTPLogs
| where TimeGenerated > ago(1h)
| where TimeTaken > 5000  // 5 seconds
| summarize count() by CsUriStem
| order by count_ desc
```

**Resolution**:
- If traffic spike: Verify auto-scale, manually add instances if needed
- If slow query: Add database index, optimize query
- If memory leak: Restart app service, investigate code
- If DDoS attack: Enable Azure DDoS Protection, block IPs via WAF

**Follow-up**:
- Document incident in postmortem
- Adjust auto-scale thresholds if needed
- Create alert for specific slow endpoint

---

**Q: "How do you troubleshoot a 500 error in production?"**

**Answer**:

**Step 1: Gather Context**
- When did it start? (check Application Insights timeline)
- Is it affecting all users or specific ones?
- What changed recently? (recent deployment?)

**Step 2: Check Logs**
```kql
// Find exceptions
AppExceptions
| where TimeGenerated > ago(1h)
| summarize count() by outerMessage
| order by count_ desc

// Check dependencies
AppDependencies
| where TimeGenerated > ago(1h)
| where success == false
| summarize count() by target
```

**Step 3: Common Causes**
- Database connection timeout → check database metrics, connection pool
- API dependency down → check external service status
- Configuration issue → verify App Settings in Key Vault
- Deployment issue → rollback to previous version

**Step 4: Resolution**
- If recent deployment: Immediate rollback via slot swap
- If database issue: Scale up temporarily, investigate queries
- If external API down: Implement circuit breaker, return cached data

---

### Behavioral Questions

**Q: "Tell me about a time you had to troubleshoot a complex production issue."**

**Answer Structure** (STAR method):
- **Situation**: Set the scene (3-4 sentences)
- **Task**: What needed to be done
- **Action**: Steps you took (specific, detailed)
- **Result**: Outcome + what you learned

**Example**:
"In my Tesoro XP project simulation, I encountered SQL provisioning restrictions even after upgrading to Pay-As-You-Go. [Situation]

I needed to understand whether this was a regional issue, a quota problem, or a configuration error. [Task]

I systematically checked: (1) VM quotas using az vm list-usage to confirm quota availability, (2) reviewed deployment operations to find specific error codes, (3) researched Azure documentation on quota restrictions, and (4) identified that even paid accounts require explicit SQL/PostgreSQL quota requests for anti-fraud reasons. [Action]

While I couldn't immediately deploy the databases, I documented the quota request process, updated templates to be modular (allowing partial deployment), and created comprehensive documentation so the team could deploy when quotas were approved. This taught me the importance of understanding cloud provider limitations and building flexible IaC templates. [Result]"

---

**Q: "How do you prioritize tasks when everything is urgent?"**

**Answer**:
"I use a combination of impact assessment and time sensitivity:

1. **Severity classification**:
   - P0 (Critical): Production down, data loss risk → immediate action
   - P1 (High): Degraded performance, security risk → same day
   - P2 (Medium): Non-critical bugs, minor issues → this week
   - P3 (Low): Enhancements, technical debt → backlog

2. **Stakeholder communication**: If multiple P0 issues, I ask 'Which system has the most business impact right now?'

3. **Resource allocation**: Can tasks be parallelized? Delegate?

4. **Example**: If production is down AND a security vulnerability is reported:
   - Production down affects revenue NOW → fix first (2-hour RTO)
   - Security vuln is critical but not actively exploited → patch within 24 hours

5. **Document decisions**: Why we chose X over Y, communicate to stakeholders"

---

**Q: "Describe a time you made a mistake. What did you learn?"**

**Answer**:
"In this project, I initially tried to deploy Basic tier App Services (B1) because they were cheaper, but hit quota restrictions. [Mistake]

Rather than investigating available quotas first, I assumed 'Basic' meant widely available. [What went wrong]

I learned to always verify quotas BEFORE architectural decisions. Now I run 'az vm list-usage' as part of my planning phase to understand what's actually available. [Lesson learned]

I also learned that upgrading to Pay-As-You-Go doesn't automatically grant all quotas - some require explicit requests for fraud prevention. This taught me to research cloud provider limitations early in the design phase. [Broader lesson]

I documented this in a quota increase guide so others wouldn't face the same issue. [Making it right]"

---

### Questions to Ask Interviewer

Always ask 3-5 questions. Shows engagement and helps you evaluate fit.

**Technical/Role Questions**:
- [ ] "What does the current infrastructure look like? On-prem, hybrid, or fully cloud?"
- [ ] "What IaC tools does the team currently use? (Terraform, Bicep, ARM, CDK?)"
- [ ] "What's the deployment frequency? Daily, weekly, on-demand?"
- [ ] "How is the team structured? Separate DevOps team or embedded in product teams?"
- [ ] "What monitoring and observability tools are in place?"

**Culture/Process Questions**:
- [ ] "How does the team handle on-call rotations and incident response?"
- [ ] "What does success look like for this role in the first 90 days?"
- [ ] "How does the team balance new feature work vs technical debt vs operations?"
- [ ] "What's the code review process like?"
- [ ] "How are incidents handled? Blameless postmortems?"

**Growth Questions**:
- [ ] "What opportunities are there for learning and professional development?"
- [ ] "Are there budget/time allocated for certifications or training?"
- [ ] "How does the company support career progression for DevOps engineers?"

---

## Day-Before Checklist

- [ ] **Portfolio Ready**
  - [ ] GitHub repository accessible
  - [ ] Architecture diagram exported
  - [ ] Laptop/device ready for screen sharing

- [ ] **Practice**
  - [ ] Walk through architecture out loud (5 minutes)
  - [ ] Practice 3 technical questions
  - [ ] Practice 2 behavioral questions (STAR method)

- [ ] **Logistics**
  - [ ] Know interview time and time zone
  - [ ] Test video/audio setup if virtual
  - [ ] Have water nearby
  - [ ] Notebook for taking notes

- [ ] **Mental Preparation**
  - [ ] Review your resume
  - [ ] Review job description (highlight key requirements)
  - [ ] Get good sleep
  - [ ] Prepare 3-5 questions to ask

---

## During Interview

### First 5 Minutes
- [ ] Professional greeting, smile
- [ ] Thank them for the opportunity
- [ ] Listen carefully to their introduction
- [ ] Take notes on interviewer names/roles

### Technical Discussion
- [ ] Use whiteboard/screen share for architecture
- [ ] Think out loud (show problem-solving process)
- [ ] Ask clarifying questions ("How much traffic do we expect?")
- [ ] Admit when you don't know something, explain how you'd find out

### Closing
- [ ] Ask your prepared questions
- [ ] Thank them for their time
- [ ] Ask about next steps and timeline
- [ ] Send thank-you email within 24 hours

---

## Key Talking Points (Memorize These)

### Your Value Proposition
"I bring hands-on experience designing cloud-native architectures on Azure with infrastructure-as-code, implementing CI/CD pipelines, and building secure, scalable systems. My Tesoro XP project demonstrates end-to-end infrastructure design including networking, security, monitoring, and cost optimization - all using production-grade best practices like private endpoints, Managed Identities, and defense-in-depth security."

### Why You Want This Role
"I'm passionate about building reliable, automated infrastructure that enables developers to ship faster safely. The Tesoro XP loyalty platform presents interesting challenges around scale, security (PCI compliance), and global distribution. I'm excited to contribute to a mission-driven company that rewards customer loyalty."

### Why Azure/Cloud
"Cloud platforms like Azure enable rapid innovation through managed services, eliminating undifferentiated heavy lifting like OS patching, backups, and hardware management. Infrastructure-as-code ensures consistency, version control for infrastructure changes, and disaster recovery through redeployability. Auto-scaling and pay-as-you-go models optimize costs while maintaining performance."

---

## Common Mistakes to Avoid

❌ **Don't**:
- Badmouth previous employers
- Say "I don't know" without explaining how you'd find out
- Ramble (practice concise answers)
- Interrupt the interviewer
- Check your phone
- Forget to ask questions (shows lack of interest)
- Get defensive about gaps in knowledge

✅ **Do**:
- Be enthusiastic about the role and company
- Show curiosity and willingness to learn
- Admit knowledge gaps honestly
- Use specific examples from your project
- Take notes during the interview
- Follow up with thank-you email
- Be yourself

---

## Post-Interview

- [ ] **Same Day**:
  - [ ] Send thank-you email to all interviewers
  - [ ] Mention specific topics discussed
  - [ ] Reiterate your interest

- [ ] **Within a Week**:
  - [ ] Follow up if you haven't heard back
  - [ ] Continue improving your portfolio
  - [ ] Apply to similar roles (don't put all eggs in one basket)

- [ ] **If You Get an Offer**:
  - [ ] Review carefully (salary, benefits, PTO, remote policy)
  - [ ] Don't feel pressured to accept immediately
  - [ ] Negotiate if appropriate (research market rates)
  - [ ] Ask for offer in writing

- [ ] **If You Don't Get It**:
  - [ ] Ask for feedback (if appropriate)
  - [ ] Learn from the experience
  - [ ] Keep improving your skills
  - [ ] Apply to more positions

---

## Additional Resources

### Certifications (Nice to Have)
- [ ] AZ-900: Azure Fundamentals (entry-level)
- [ ] AZ-104: Azure Administrator (associate-level)
- [ ] AZ-400: DevOps Engineer Expert (advanced)

### Books
- "The Phoenix Project" by Gene Kim (DevOps culture)
- "Site Reliability Engineering" by Google (SRE practices)
- "Terraform: Up & Running" by Yevgeniy Brikman (IaC principles)

### Practice Platforms
- [ ] Azure Learn (free tutorials): https://learn.microsoft.com/training/
- [ ] A Cloud Guru / Pluralsight (video courses)
- [ ] GitHub Actions examples: https://github.com/actions/starter-workflows

---

## Confidence Boosters

Remember:
- ✅ You built a complete production-grade infrastructure from scratch
- ✅ You understand networking, security, monitoring, and cost management
- ✅ You can explain architectural decisions and trade-offs
- ✅ You demonstrate continuous learning (overcame Azure quota challenges)
- ✅ You have comprehensive documentation (rare!)

**You've got this! 🚀**

---

**Last Updated**: 2025-11-22
**Review Before Every Interview**
