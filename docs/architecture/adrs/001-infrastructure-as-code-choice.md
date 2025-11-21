# ADR 001: Infrastructure as Code - Bicep as Primary Tool

## Status
Accepted

## Context
We need to choose an Infrastructure as Code (IaC) tool to manage our Azure infrastructure across multiple environments. The main options are:
- Azure Bicep
- Terraform
- ARM Templates (JSON)
- Pulumi

## Decision
We will use **Azure Bicep** as our primary IaC tool, with **Terraform** maintained as a secondary option for specific use cases.

## Rationale

### Why Bicep?
1. **Azure-Native**: Built by Microsoft specifically for Azure, ensuring day-0 support for new Azure features
2. **Simpler Syntax**: Cleaner, more readable than ARM JSON templates
3. **Type Safety**: Strong typing reduces deployment errors
4. **Seamless Azure Integration**: Native support in Azure CLI, Azure DevOps, and GitHub Actions
5. **No State Management**: Unlike Terraform, no remote state files to manage
6. **Transpiles to ARM**: Mature, battle-tested underlying technology
7. **Smaller Learning Curve**: Team can focus on Azure rather than tool-specific concepts

### When to Use Terraform?
- Multi-cloud scenarios (if we expand beyond Azure)
- Third-party service provisioning (e.g., Cloudflare, DataDog)
- When existing Terraform modules provide significant value

### Why Not ARM Templates?
- Verbose JSON syntax leads to maintainability issues
- Harder to read and review
- Bicep provides all ARM benefits with better DX

### Why Not Pulumi?
- Requires programming language knowledge (adds complexity)
- Smaller community compared to Bicep/Terraform
- State management similar to Terraform

## Consequences

### Positive
- Faster Azure feature adoption
- Simplified deployment workflows
- Better developer experience with cleaner syntax
- No state file management overhead
- Strong IDE support (VS Code extension)

### Negative
- Azure-locked (mitigation: maintain Terraform option)
- Smaller community than Terraform
- Team needs to learn Bicep-specific patterns

### Neutral
- Need to maintain both Bicep and Terraform knowledge for hybrid scenarios
- Documentation requirements for both tools

## Implementation Plan
1. Start all new infrastructure with Bicep
2. Create Bicep modules for common patterns
3. Maintain Terraform for Cloudflare CDN configuration
4. Document module patterns and best practices
5. Set up automated testing for both tools

## References
- [Azure Bicep Documentation](https://learn.microsoft.com/azure/azure-resource-manager/bicep/)
- [Bicep vs Terraform Comparison](https://learn.microsoft.com/azure/azure-resource-manager/bicep/compare-template-syntax-terraform)
