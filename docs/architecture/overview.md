# Tesoro XP - Architecture Overview

## Executive Summary

Tesoro XP is a loyalty infrastructure platform that enables real-time cashback and rewards processing through Visa/Mastercard transactions at brick-and-mortar merchants. The platform is designed for high availability, scalability, and real-time transaction processing.

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Azure Cloud Platform                     │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────┐      ┌──────────────┐      ┌───────────┐ │
│  │   Azure CDN  │──────│ App Services │──────│  Storage  │ │
│  │  Cloudflare  │      │ Container    │      │  Accounts │ │
│  └──────────────┘      │     Apps     │      └───────────┘ │
│                        └──────────────┘                      │
│                               │                              │
│                               │                              │
│                        ┌──────────────┐                      │
│                        │   Database   │                      │
│                        │  SQL Server  │                      │
│                        │  Hyperscale  │                      │
│                        │  PostgreSQL  │                      │
│                        └──────────────┘                      │
│                                                               │
│  ┌──────────────────────────────────────────────────────┐   │
│  │         Monitoring & Observability Layer             │   │
│  │  - Azure Monitor  - Application Insights             │   │
│  │  - Log Analytics  - Alerts & Notifications           │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

## Core Components

### 1. Compute Layer
- **Azure App Services**: Hosting API services and web applications
- **Azure Container Apps**: Containerized microservices for scalability
- **Function Apps**: Event-driven processing for transaction workflows

### 2. Data Layer
- **SQL Server Hyperscale**: Primary transactional database for rewards processing
- **PostgreSQL**: Analytics and reporting workloads
- **Azure Cosmos DB**: Session state and caching (optional)
- **Azure Cache for Redis**: Real-time caching layer

### 3. Networking
- **Virtual Networks (VNet)**: Isolated network environments per environment
- **Application Gateway**: Load balancing and WAF
- **Private Endpoints**: Secure database and storage access
- **Azure DNS**: Internal and external DNS management

### 4. Storage
- **Azure Blob Storage**: Document and file storage
- **Azure File Shares**: Shared configuration files
- **Azure Table Storage**: Logging and audit trails

### 5. Security
- **Azure Key Vault**: Secrets, keys, and certificate management
- **Managed Identities**: Service-to-service authentication
- **Azure AD**: Identity and access management
- **Network Security Groups (NSG)**: Network-level security rules

### 6. Observability
- **Azure Monitor**: Centralized monitoring platform
- **Application Insights**: APM and distributed tracing
- **Log Analytics**: Log aggregation and querying
- **Azure Alerts**: Proactive alerting and incident management

## Environment Strategy

### Development
- Purpose: Active development and feature testing
- Deployment: Automatic on merge to `develop`
- Database: Shared SQL Server instance with dev database
- Uptime SLA: None (can be recycled)

### Staging
- Purpose: Pre-production validation and integration testing
- Deployment: Automatic on merge to `main`
- Database: Production-like SQL Server Hyperscale
- Uptime SLA: 99.5%

### Production
- Purpose: Live customer-facing environment
- Deployment: Manual approval with deployment windows
- Database: SQL Server Hyperscale with geo-replication
- Uptime SLA: 99.99%

### Ephemeral/Preview
- Purpose: Pull request testing and experimentation
- Deployment: On-demand via GitHub Actions
- Database: Isolated lightweight instances
- Lifecycle: Auto-deleted after PR merge/close

## Deployment Strategy

### Blue-Green Deployment
- Zero-downtime deployments
- Quick rollback capability
- Production traffic switching via Azure Traffic Manager

### Canary Releases
- Gradual rollout to subset of users
- Monitoring-based promotion decisions
- Automatic rollback on error threshold breach

## Disaster Recovery

- **RPO (Recovery Point Objective)**: 1 hour
- **RTO (Recovery Time Objective)**: 4 hours
- **Backup Strategy**:
  - Automated daily backups with 30-day retention
  - Point-in-time restore capability
  - Cross-region geo-replication for production

## Scalability Considerations

### Horizontal Scaling
- Auto-scaling based on CPU, memory, and request metrics
- Min/max instance counts per environment
- Scale-out during peak transaction hours

### Vertical Scaling
- Database tier upgrades for compute-intensive workloads
- Storage tier optimization based on I/O patterns

## Cost Optimization

- **Right-sizing**: Regular review of resource utilization
- **Reserved Instances**: 1-year commitments for production workloads
- **Auto-shutdown**: Dev/staging environments during off-hours
- **Spot Instances**: For non-critical batch processing
- **Storage Tiering**: Hot/cool/archive based on access patterns

## Technology Decisions

See [Architecture Decision Records (ADRs)](./adrs/) for detailed technical decisions and rationale.

## Next Steps

1. Review and approve infrastructure design
2. Provision Azure subscriptions and resource groups
3. Implement infrastructure as code
4. Set up CI/CD pipelines
5. Configure monitoring and alerting
6. Conduct load testing and performance tuning
