# Tesoro DevOps Infrastructure Project

This project documents and implements all DevOps tasks for the Tesoro XP loyalty infrastructure platform.

## Project Overview

Tesoro XP is a standalone loyalty infrastructure that enables real-time cashback and rewards for any app or developer. This repository contains all infrastructure code, documentation, and operational procedures for running the platform on Azure.

## Key Technologies

- **Cloud Platform**: Microsoft Azure
- **Infrastructure as Code**: Bicep (primary), Terraform (alternative)
- **CI/CD**: GitHub Actions
- **Databases**: SQL Server, PostgreSQL
- **Scripting**: PowerShell, Bash, Python
- **Monitoring**: Azure Monitor, Application Insights, Log Analytics

## Repository Structure

```
├── infrastructure/          # Infrastructure as Code
│   ├── bicep/              # Bicep templates
│   ├── terraform/          # Terraform configurations (alternative)
│   └── environments/       # Environment-specific configs
├── .github/                # CI/CD pipelines
│   └── workflows/          # GitHub Actions workflows
├── scripts/                # Automation scripts
│   ├── powershell/        # PowerShell scripts
│   ├── bash/              # Bash scripts
│   └── python/            # Python automation
├── docs/                   # Documentation
│   ├── architecture/      # Architecture diagrams and ADRs
│   ├── runbooks/          # Operational runbooks
│   ├── security/          # Security practices
│   └── monitoring/        # Monitoring and alerting guides
├── environments/           # Environment configurations
│   ├── dev/               # Development environment
│   ├── staging/           # Staging environment
│   ├── production/        # Production environment
│   └── ephemeral/         # Preview/ephemeral environments
└── tests/                 # Infrastructure tests

```

## Quick Start

See [Getting Started Guide](docs/getting-started.md) for setup instructions.

## Documentation

- [Architecture Overview](docs/architecture/overview.md)
- [Infrastructure Setup](docs/infrastructure-setup.md)
- [CI/CD Pipelines](docs/cicd-pipelines.md)
- [Monitoring & Alerting](docs/monitoring/overview.md)
- [Security Best Practices](docs/security/best-practices.md)
- [Runbooks](docs/runbooks/README.md)

## Environments

- **Development**: Auto-deployed on merge to `develop` branch
- **Staging**: Auto-deployed on merge to `main` branch
- **Production**: Manual approval required
- **Ephemeral**: Created on-demand for PR previews

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for development workflow and standards.

## License

Proprietary - Tesoro XP
