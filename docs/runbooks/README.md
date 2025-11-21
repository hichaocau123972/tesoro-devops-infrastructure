# Operational Runbooks

This directory contains operational procedures and runbooks for managing the Tesoro XP infrastructure.

## Quick Reference

### Emergency Runbooks
- [Service Down](./emergency/service-down.md) - Critical service outage response
- [Database Failure](./emergency/database-failure.md) - Database connectivity or corruption issues
- [Security Incident](./emergency/security-incident.md) - Security breach or attack response
- [Data Loss](./emergency/data-loss.md) - Data recovery procedures

### Deployment Runbooks
- [Production Deployment](./deployment/production-deployment.md) - Step-by-step production deployment
- [Rollback Procedure](./deployment/rollback.md) - How to rollback a failed deployment
- [Database Migration](./deployment/database-migration.md) - Safe database schema changes
- [Blue-Green Deployment](./deployment/blue-green.md) - Zero-downtime deployment strategy

### Maintenance Runbooks
- [Scaling Operations](./maintenance/scaling.md) - Manual and auto-scaling procedures
- [Certificate Renewal](./maintenance/certificate-renewal.md) - TLS certificate management
- [Secret Rotation](./maintenance/secret-rotation.md) - Rotating credentials and API keys
- [Backup & Restore](./maintenance/backup-restore.md) - Backup verification and restore procedures
- [Performance Tuning](./maintenance/performance-tuning.md) - Optimize resource usage

### Troubleshooting Runbooks
- [High CPU Usage](./troubleshooting/high-cpu.md) - Diagnose and resolve CPU spikes
- [Memory Leaks](./troubleshooting/memory-leaks.md) - Identify and fix memory issues
- [Slow Queries](./troubleshooting/slow-queries.md) - Database performance optimization
- [Failed Jobs](./troubleshooting/failed-jobs.md) - Background job failure investigation
- [Network Issues](./troubleshooting/network-issues.md) - Connectivity and latency problems

### Monitoring Runbooks
- [Alert Response](./monitoring/alert-response.md) - How to respond to common alerts
- [Dashboard Creation](./monitoring/dashboard-creation.md) - Creating custom dashboards
- [Log Analysis](./monitoring/log-analysis.md) - Analyzing logs for insights
- [SLO Tracking](./monitoring/slo-tracking.md) - Monitor and report on SLOs

## Runbook Template

All runbooks should follow this structure:

```markdown
# [Runbook Title]

## Overview
Brief description of the scenario this runbook addresses.

## Severity
[Critical | High | Medium | Low]

## Symptoms
- List of observable symptoms
- How you know this issue is occurring

## Prerequisites
- Required access/permissions
- Tools needed
- Knowledge requirements

## Diagnostic Steps
1. Step-by-step investigation
2. What to check
3. Expected vs actual behavior

## Resolution Steps
1. Detailed remediation steps
2. Commands to run
3. Verification steps

## Rollback Plan
How to undo changes if resolution doesn't work

## Prevention
How to prevent this issue in the future

## Related Alerts
Links to related monitoring alerts

## Escalation
When and how to escalate if unable to resolve

## References
- Related documentation
- External resources
```

## On-Call Responsibilities

### Primary On-Call Engineer
- Monitor alerts 24/7 during rotation
- Respond to P0/P1 incidents within SLA
- Execute runbooks for known issues
- Escalate when necessary
- Document incidents in post-mortem

### Secondary On-Call Engineer
- Backup for primary
- Respond if primary unavailable (15 min timeout)
- Assist with complex incidents

### Escalation Contacts
- **DevOps Lead**: +1-555-0101
- **Infrastructure Manager**: +1-555-0102
- **VP Engineering**: +1-555-0103

## Incident Response SLAs

| Severity | Initial Response | Resolution Target |
|----------|------------------|-------------------|
| P0 (Critical) | 15 minutes | 4 hours |
| P1 (High) | 1 hour | 8 hours |
| P2 (Medium) | 4 hours | 24 hours |
| P3 (Low) | 24 hours | 72 hours |

## Post-Incident Process

After resolving any P0/P1 incident:

1. **Immediate (within 24h)**:
   - Update incident ticket with resolution
   - Notify stakeholders of resolution
   - Create follow-up tasks if needed

2. **Post-Mortem (within 5 days)**:
   - Schedule blameless post-mortem meeting
   - Document timeline, root cause, resolution
   - Identify action items to prevent recurrence
   - Update runbooks based on learnings

3. **Follow-Through (within 30 days)**:
   - Complete all action items
   - Verify preventive measures effective
   - Share learnings with broader team

## Runbook Maintenance

- **Monthly Review**: Verify runbooks are up-to-date
- **After Incidents**: Update based on actual incident response
- **Quarterly Audit**: Remove outdated procedures, add new ones
- **Version Control**: All runbooks in Git, track changes

## Tools & Access

### Required Tools
- Azure CLI (`az`)
- kubectl (for Container Apps)
- SQL Server Management Studio / Azure Data Studio
- PowerShell / Bash
- Git

### Access Requirements
- Azure Portal access (Reader minimum)
- Key Vault Secrets User role
- Azure DevOps access for deployments
- PagerDuty / OpsGenie for on-call
- Slack for communication

## Training

New on-call engineers must:
1. Shadow experienced engineer for 1 rotation
2. Review all emergency runbooks
3. Complete incident response simulation
4. Demonstrate proficiency in common scenarios

## Contact Information

- **DevOps Team**: devops-team@tesoro-xp.com
- **PagerDuty**: https://tesoro.pagerduty.com
- **Slack**: #devops-oncall
- **Status Page**: https://status.tesoro-xp.com
