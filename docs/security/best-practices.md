# Security Best Practices

## Overview

Security is paramount for Tesoro XP as we handle sensitive financial transaction data and payment card information. This document outlines our security practices, controls, and compliance requirements.

## Security Principles

1. **Defense in Depth**: Multiple layers of security controls
2. **Least Privilege**: Minimal permissions required for each component
3. **Zero Trust**: Never trust, always verify
4. **Security by Default**: Secure configurations out of the box
5. **Encryption Everywhere**: Data encrypted at rest and in transit

## Identity & Access Management

### Azure AD Integration

**Authentication**:
- All human access via Azure AD with MFA required
- Service-to-service: Managed Identities (no credentials in code)
- External APIs: Azure AD B2C for customer authentication

**Authorization**:
- Role-Based Access Control (RBAC) for all Azure resources
- Just-In-Time (JIT) access for production resources
- Conditional Access policies based on location, device compliance

### Role Definitions

| Role | Permissions | Who |
|------|-------------|-----|
| Owner | Full control (avoid using) | Subscription admins only |
| Contributor | Create/manage resources (no access grants) | DevOps engineers |
| Reader | View resources only | Support team, auditors |
| Key Vault Secrets User | Read secrets | Application identities |
| SQL DB Contributor | Manage databases | Database admins |
| Custom: Deployer | Deploy infrastructure only | CI/CD pipelines |

### Access Review Process

1. **Quarterly Reviews**: Review all access permissions
2. **Leavers Process**: Immediate revocation on employee departure
3. **Privilege Escalation**: Temporary elevated access with approval workflow
4. **Audit Trail**: All access changes logged and monitored

## Secrets Management

### Azure Key Vault Standards

**Secrets Storage**:
- ALL secrets, connection strings, API keys in Key Vault
- NO secrets in code, configuration files, or environment variables (except Key Vault reference)
- Separate Key Vaults per environment
- Premium SKU for production (HSM-backed keys)

**Access Patterns**:
```csharp
// ✅ CORRECT: Using Managed Identity
var client = new SecretClient(
    new Uri("https://tesoro-prod-kv.vault.azure.net/"),
    new DefaultAzureCredential());

var secret = await client.GetSecretAsync("sql-connection-string");
```

```csharp
// ❌ WRONG: Hardcoded secrets
var connectionString = "Server=...;Password=hardcoded123;";
```

### Secret Rotation

| Secret Type | Rotation Frequency | Automation |
|-------------|-------------------|------------|
| Database passwords | 90 days | Automated |
| API keys | 180 days | Automated |
| Certificates | 365 days | Azure managed |
| Service principal secrets | 90 days | Manual with alerts |

**Rotation Process**:
1. Generate new secret
2. Add new secret to Key Vault (v2)
3. Update applications to use new secret
4. Verify functionality
5. Delete old secret after 7-day grace period

### Sensitive Data Handling

**PCI DSS Compliance**:
- NO credit card data stored in our systems
- Tokenization via payment processor
- Only store last 4 digits + token reference
- PCI SAQ-A compliance level

**PII Protection**:
- Encrypt at rest (AES-256)
- Encrypt in transit (TLS 1.2+)
- Data masking in non-production environments
- Audit all PII access

## Network Security

### Network Segmentation

```
┌─────────────────────────────────────────────────────────┐
│                   Internet (Public)                      │
└────────────────────────┬────────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────────┐
│              Application Gateway (WAF)                   │
│  - OWASP Top 10 protection                              │
│  - DDoS protection                                      │
│  - TLS termination                                       │
└────────────────────────┬────────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────────┐
│            App Service Subnet (10.0.1.0/24)             │
│  - App Services & Container Apps                        │
│  - Outbound traffic routed through VNet                 │
└────────────────────────┬────────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────────┐
│       Private Endpoints Subnet (10.0.3.0/24)            │
│  - SQL Server private endpoint                          │
│  - Key Vault private endpoint                           │
│  - Storage private endpoint                             │
└─────────────────────────────────────────────────────────┘
```

### Firewall Rules

**Azure SQL Server**:
- Public access: Disabled
- Private endpoints only
- Firewall rules: Azure services allowed (for deployment)
- VNet service endpoints from app subnet

**Key Vault**:
- Public access: Disabled
- Private endpoints only
- Firewall exceptions: None (all via private network)

**Storage Accounts**:
- Public blob access: Disabled
- HTTPS only: Required
- Minimum TLS: 1.2
- Network rules: VNet integration required

### Network Security Groups (NSGs)

**App Service Subnet NSG**:
```
Priority 100: Allow HTTPS (443) from Application Gateway
Priority 110: Allow HTTP (80) from Application Gateway
Priority 200: Deny all other inbound
Priority 300: Allow outbound to Private Endpoint subnet
Priority 400: Allow outbound to Azure services
```

**Private Endpoint Subnet NSG**:
```
Priority 100: Allow inbound from VNet
Priority 200: Deny all other inbound
Priority 300: Allow outbound to VNet
```

## Application Security

### Secure Coding Practices

**Input Validation**:
- Validate all user inputs
- Sanitize data before database queries (use parameterized queries)
- Reject unexpected input formats
- Length limits on all string inputs

**SQL Injection Prevention**:
```csharp
// ✅ CORRECT: Parameterized query
var command = new SqlCommand(
    "SELECT * FROM Users WHERE UserId = @userId", connection);
command.Parameters.AddWithValue("@userId", userId);

// ❌ WRONG: String concatenation
var query = $"SELECT * FROM Users WHERE UserId = {userId}";
```

**XSS Prevention**:
- Encode all output
- Use Content Security Policy headers
- Sanitize user-generated content
- Use anti-forgery tokens

**Authentication & Authorization**:
- Never trust client-side validation
- Verify permissions on every API call
- Use secure session management
- Implement rate limiting

### Security Headers

Required HTTP headers for all responses:
```
Strict-Transport-Security: max-age=31536000; includeSubDomains
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
X-XSS-Protection: 1; mode=block
Content-Security-Policy: default-src 'self'
Referrer-Policy: strict-origin-when-cross-origin
Permissions-Policy: geolocation=(), microphone=(), camera=()
```

### Dependency Management

**Package Security**:
- Automated dependency scanning (Dependabot, Snyk)
- Update vulnerable packages within 48 hours (critical), 7 days (high)
- Lock file for reproducible builds
- Use only verified packages from official registries

**Container Security**:
- Scan all container images for vulnerabilities
- Use minimal base images (Alpine, Distroless)
- Run as non-root user
- Regular base image updates

## Data Protection

### Encryption Standards

**At Rest**:
- Azure Storage: Microsoft-managed keys (256-bit AES)
- SQL Database: Transparent Data Encryption (TDE) enabled
- Backups: Encrypted with same keys as source
- Key Vault: HSM-backed keys for production

**In Transit**:
- TLS 1.2 minimum (TLS 1.3 preferred)
- Perfect Forward Secrecy (PFS) enabled
- Strong cipher suites only
- Certificate pinning for mobile apps

### Data Classification

| Classification | Examples | Protection Level |
|----------------|----------|------------------|
| Public | Marketing materials | None required |
| Internal | Business docs, code | Access control |
| Confidential | User PII, transaction data | Encryption + access control |
| Restricted | Payment tokens, credentials | HSM encryption + strict RBAC |

### Backup & Recovery

**Backup Strategy**:
- Automated daily backups (3 AM UTC)
- Point-in-time restore (7-day window for dev, 35-day for prod)
- Geo-redundant backups for production
- Quarterly restore drills

**Backup Security**:
- Backups encrypted at rest
- Separate access controls (backup operator role)
- Immutable backups (cannot be deleted for 30 days)
- Audit all backup access

## Compliance & Auditing

### Compliance Frameworks

**PCI DSS**:
- Level: SAQ-A (no card data storage)
- Annual assessment required
- Quarterly vulnerability scans
- Penetration testing annually

**SOC 2**:
- Type II audit annually
- Security, availability, confidentiality criteria
- Continuous control monitoring

**GDPR**:
- Data residency: US (with EU options planned)
- Right to erasure implemented
- Data breach notification (72 hours)
- Privacy by design

### Audit Logging

**What to Log**:
- All authentication attempts (success/failure)
- Authorization failures
- Database schema changes
- Secret access (Key Vault)
- Configuration changes
- Administrative actions

**Log Retention**:
- Security logs: 365 days (hot) + 7 years (archive)
- Audit logs: 7 years
- Application logs: 90 days

**Log Protection**:
- Append-only storage
- Tamper detection
- Separate access controls
- Regular log review

### Security Monitoring

**SIEM Integration**:
- Azure Sentinel for security events
- Real-time threat detection
- Anomaly detection (ML-based)
- Automated response playbooks

**Security Alerts**:
- Failed authentication attempts (5+ in 5 min)
- Privilege escalation attempts
- Unusual data access patterns
- Vulnerability scan findings
- Certificate expiration warnings

## Incident Response

### Security Incident Classification

| Severity | Examples | Response Time |
|----------|----------|---------------|
| Critical | Data breach, active attack | Immediate (< 15 min) |
| High | Vulnerability exploitation, unauthorized access | 1 hour |
| Medium | Failed attack attempt, suspicious activity | 4 hours |
| Low | Policy violation, minor misconfiguration | 24 hours |

### Incident Response Plan

1. **Detection**: Automated alerts, manual reporting
2. **Triage**: Assess severity and impact
3. **Containment**: Isolate affected systems
4. **Eradication**: Remove threat, patch vulnerabilities
5. **Recovery**: Restore normal operations
6. **Lessons Learned**: Post-incident review

### Breach Notification

- **Internal**: Immediate notification to security team and leadership
- **Customers**: Within 72 hours if PII impacted
- **Regulators**: As required by law (GDPR, state laws)
- **Public**: If required by regulation

## Vulnerability Management

### Vulnerability Scanning

**Frequency**:
- Infrastructure: Weekly automated scans
- Applications: On every deployment + weekly
- Dependencies: Daily (automated)
- Penetration testing: Annually + after major changes

**Tools**:
- Azure Security Center
- Dependency scanners (Dependabot, Snyk)
- Container scanners (Trivy, Aqua)
- DAST tools (OWASP ZAP)

### Remediation SLAs

| Severity | SLA | Process |
|----------|-----|---------|
| Critical | 48 hours | Hotfix deployment, emergency change |
| High | 7 days | Regular deployment cycle |
| Medium | 30 days | Planned in sprint |
| Low | 90 days | Backlog prioritization |

## DevOps Security (DevSecOps)

### CI/CD Security

**Pipeline Security**:
- Secrets via Azure Key Vault (OIDC auth)
- Separate service principals per environment
- Code signing for deployments
- Approval gates for production

**Security Gates**:
1. Static code analysis (SonarQube)
2. Dependency vulnerability scan
3. Container image scan
4. Infrastructure as Code security (Checkov)
5. Unit/integration test pass rate > 95%

**Supply Chain Security**:
- Verified base images only
- Package signature verification
- Build reproducibility
- SBOM (Software Bill of Materials) generation

### Deployment Security

**Pre-Deployment**:
- Manual approval required (production)
- Security checklist completion
- Rollback plan documented

**Post-Deployment**:
- Automated smoke tests
- Security regression tests
- Monitoring alert verification

## Security Training

**Required Training**:
- Security awareness: All employees (annually)
- Secure coding: All developers (annually)
- Incident response: DevOps team (semi-annually)
- Compliance: Leadership (annually)

**Simulations**:
- Phishing simulations (quarterly)
- Tabletop exercises (semi-annually)
- Red team exercises (annually)

## Third-Party Security

### Vendor Assessment

**Before Engagement**:
- Security questionnaire
- SOC 2 report review
- Data processing agreement
- SLA verification

**Ongoing Monitoring**:
- Quarterly security reviews
- Incident notification requirements
- Annual recertification

## Security Contacts

- **Security Team**: security@tesoro-xp.com
- **Incident Reporting**: incidents@tesoro-xp.com
- **Bug Bounty**: security-bounty@tesoro-xp.com (coming soon)

## References

- [Azure Security Best Practices](https://learn.microsoft.com/azure/security/fundamentals/best-practices-and-patterns)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [PCI DSS Requirements](https://www.pcisecuritystandards.org/)
- [NIST Cybersecurity Framework](https://www.nist.gov/cyberframework)
