# Tesoro XP - Azure Infrastructure

**Production-grade Azure infrastructure for a loyalty rewards platform, built with Infrastructure as Code (Bicep).**

[![Azure](https://img.shields.io/badge/Azure-0078D4?style=for-the-badge&logo=microsoft-azure&logoColor=white)](https://azure.microsoft.com/)
[![Bicep](https://img.shields.io/badge/Bicep-0078D4?style=for-the-badge&logo=microsoft-azure&logoColor=white)](https://learn.microsoft.com/azure/azure-resource-manager/bicep/)
[![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-2088FF?style=for-the-badge&logo=github-actions&logoColor=white)](https://github.com/features/actions)

---

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Infrastructure Components](#infrastructure-components)
- [Getting Started](#getting-started)
- [Deployment](#deployment)
- [Cost Optimization](#cost-optimization)
- [Security](#security)
- [Monitoring](#monitoring)
- [Documentation](#documentation)

---

## 🎯 Overview

This repository contains the complete Azure infrastructure for **Tesoro XP**, a modern loyalty rewards platform. The infrastructure is defined using **Azure Bicep** (Infrastructure as Code) and follows cloud-native best practices for security, scalability, and observability.

### Key Features

✅ **Infrastructure as Code**: Complete environment reproducible in 20 minutes
✅ **Multi-Environment**: Parameterized for dev, staging, and production
✅ **Security First**: Private endpoints, Managed Identities, Key Vault integration
✅ **Highly Available**: Auto-scaling, deployment slots, geo-replication
✅ **Cost Optimized**: Right-sized SKUs, budget alerts, auto-shutdown scripts
✅ **Fully Monitored**: Log Analytics, Application Insights, custom alerts
✅ **CI/CD Ready**: GitHub Actions workflows for automated deployments

### Technology Stack

| Layer | Technology | Purpose |
|-------|------------|---------|
| **IaC** | Azure Bicep | Infrastructure definitions |
| **Compute** | Azure App Service (Linux) | .NET 8.0 web application |
| **Database** | Azure SQL Database, PostgreSQL | Transactional and analytics data |
| **Cache** | Azure Redis Cache | Session storage, performance optimization |
| **Storage** | Azure Blob Storage | User uploads, static files |
| **Networking** | Virtual Network, Private Endpoints | Secure, isolated network |
| **Security** | Key Vault, Managed Identities | Secrets management, passwordless auth |
| **Monitoring** | Log Analytics, Application Insights | Logging, metrics, distributed tracing |
| **CI/CD** | GitHub Actions | Automated deployments |

---

## 🏗️ Architecture

### High-Level Architecture

```
┌──────────┐
│  Users   │
└────┬─────┘
     │ HTTPS
     ▼
┌─────────────────┐
│ App Gateway     │  Layer 7 Load Balancer + WAF
│ (WAF)           │  SSL Termination
└────┬────────────┘
     │ Private IP
     ▼
┌──────────────────────────────────────────┐
│          Virtual Network                 │
│                                          │
│  ┌──────────────────┐                   │
│  │  App Service     │                   │
│  │  (.NET 8.0)      │                   │
│  │  Auto-scaling    │                   │
│  └────┬────────┬────┘                   │
│       │        │                         │
│  ┌────▼─────┐  ┌─────────▼──┐  ┌──────▼───┐
│  │ SQL DB   │  │PostgreSQL  │  │  Redis   │
│  │(Private) │  │ (Private)  │  │ (Cache)  │
│  └──────────┘  └────────────┘  └──────────┘
│                                          │
└──────────────────────────────────────────┘

       ┌─────────────┐
       │  Key Vault  │  Secrets Management
       └─────────────┘

       ┌──────────────────┐
       │  Log Analytics   │  Monitoring
       │  App Insights    │  & Alerts
       └──────────────────┘
```

**[View Detailed Architecture Diagram →](docs/ARCHITECTURE-DIAGRAM.md)**

---

## 🧩 Infrastructure Components

### Networking
- **Virtual Network** (10.0.0.0/16): Private network with 4 subnets
- **Network Security Groups**: Firewall rules enforcing least privilege access
- **Private Endpoints**: Secure connectivity to data services (no internet exposure)
- **Application Gateway**: Layer 7 load balancer with WAF (OWASP Top 10 protection)

### Compute
- **App Service Plan**: Linux-based, Standard S1 (dev) to Premium P2v3 (production)
- **App Service**: .NET 8.0 web application with auto-scaling and deployment slots

### Data
- **Azure SQL Database**: Transactional data (Basic for dev, Hyperscale for prod)
- **PostgreSQL Flexible Server**: Analytics and reporting data
- **Redis Cache**: Session storage, caching layer (80% database load reduction)

### Security
- **Azure Key Vault**: Centralized secrets management
- **Managed Identities**: Passwordless authentication to Azure services
- **RBAC**: Role-based access control for all resources

### Monitoring
- **Log Analytics Workspace**: Centralized logging for all services
- **Application Insights**: APM, distributed tracing, exception tracking
- **Metric Alerts**: CPU, memory, error rate, response time monitoring

---

## 🚀 Getting Started

### Prerequisites

- **Azure Account**: [Create free account](https://azure.microsoft.com/free/)
- **Azure CLI**: [Install Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli)
- **Git**: For cloning the repository

### Quick Start

```bash
# Clone the repository
git clone https://github.com/sdrandr/tesoro-devops-infrastructure.git
cd tesoro-devops-infrastructure

# Login to Azure
az login

# Deploy to dev environment
az deployment sub create \
  --location eastus \
  --template-file infrastructure/bicep/main.bicep \
  --parameters environment=dev appName=tesoro
```

**Note**: Some Azure services (SQL Database, PostgreSQL) may require quota increases. See [Quota Increase Guide](docs/azure-quota-increase-guide.md).

---

## 📦 Deployment

### Validate Template

```bash
az deployment sub validate \
  --location eastus \
  --template-file infrastructure/bicep/main.bicep \
  --parameters environment=dev
```

### Preview Changes

```bash
az deployment sub what-if \
  --location eastus \
  --template-file infrastructure/bicep/main.bicep \
  --parameters environment=dev
```

### Deploy

```bash
az deployment sub create \
  --location eastus \
  --template-file infrastructure/bicep/main.bicep \
  --parameters environment=dev
```

---

## 💰 Cost Optimization

### Estimated Monthly Costs (US East)

| Environment | Monthly Cost | Key Resources |
|-------------|--------------|---------------|
| **dev** | ~$100 | S1 App Service, Basic SQL, Standard Redis |
| **staging** | ~$500 | P1v3 App Service, Standard SQL |
| **production** | ~$2,000 | P2v3 App Service, Hyperscale SQL |

### Cost Management Features

- Budget alerts at $50, $75, $90 spending
- Auto-scaling to reduce costs during off-hours
- Resource tagging for cost allocation
- Log Analytics daily ingestion cap

**[View Full Cost Analysis →](docs/cost-estimate.md)**

---

## 🔒 Security

### Security Features

✅ Private Endpoints (no internet exposure for databases)
✅ Managed Identities (no passwords in code)
✅ Key Vault (centralized secrets management)
✅ Network Segmentation (NSG firewall rules)
✅ WAF (OWASP Top 10 protection)
✅ TLS 1.2+ (all connections encrypted)
✅ TDE (database encryption at rest)
✅ Audit Logging (all access tracked)

**[View Security Best Practices →](docs/security/best-practices.md)**

---

## 📊 Monitoring

### Monitoring Stack

- **Log Analytics**: Centralized logging (30-day retention)
- **Application Insights**: APM and distributed tracing
- **Metric Alerts**: Proactive monitoring of CPU, memory, errors
- **Workbooks**: Custom dashboards

### Key Metrics

- CPU Usage > 80% → Auto-scale + Email alert
- HTTP 5xx Errors > 10/min → SMS alert
- Response Time > 5s → Email alert
- Database DTU > 80% → Dashboard warning

**[View Monitoring Guide →](docs/monitoring/overview.md)**

---

## 📚 Documentation

### Quick Links

- **[Learning Guide](docs/LEARNING-GUIDE.md)**: Comprehensive explanation of every Azure resource
- **[Architecture Diagram](docs/ARCHITECTURE-DIAGRAM.md)**: Detailed visual architecture
- **[Interview Prep Checklist](docs/INTERVIEW-PREP-CHECKLIST.md)**: Practice questions and answers
- **[Cost Estimate](docs/cost-estimate.md)**: Detailed cost breakdown
- **[Quota Increase Guide](docs/azure-quota-increase-guide.md)**: How to request Azure quotas
- **[Deployment Status](DEPLOYMENT-STATUS.md)**: Current project status

---

## 📝 Project Highlights

### What Makes This Project Stand Out

✅ **Production-Ready**: Implements real-world best practices
✅ **Comprehensive Documentation**: Every decision explained
✅ **Security-First**: Private endpoints, Managed Identities, defense in depth
✅ **Cost-Conscious**: Budget alerts, right-sized resources
✅ **Fully Monitored**: Log Analytics, Application Insights, custom alerts
✅ **Interview-Ready**: Complete with architecture diagrams and talking points

### Skills Demonstrated

- Azure infrastructure design and implementation
- Infrastructure as Code (Bicep)
- Networking (VNets, NSGs, Private Endpoints)
- Security (Key Vault, Managed Identities, RBAC)
- Monitoring (Log Analytics, Application Insights, KQL)
- Cost optimization and budget management
- CI/CD pipeline design
- Documentation and communication

---

## 🎓 About This Project

This project was created as a portfolio demonstration of Azure DevOps engineering skills. It showcases end-to-end infrastructure design, implementation, and documentation required for a Senior DevOps Engineer role.

### Learning Journey

- Navigating Azure quota restrictions
- Implementing security best practices
- Designing cost-optimized infrastructure
- Creating comprehensive documentation

---

## 📫 Contact

**Dennis Brady**
Email: dennis.brady@skyeluxtechnology.com
LinkedIn: [Dennis Brady LinkedIn](https://www.linkedin.com/in/dennis-brady-0aa8761/)

---

## 📄 License

This project is licensed under the MIT License.

---

## ⭐ Star This Repository

If you found this project helpful, please consider giving it a star! ⭐

---

**Built with ❤️ using Azure Bicep**

Last Updated: 2025-11-22
