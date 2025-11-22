// Minimal Key Vault Module - Free Tier Compatible

@description('Environment name')
param environment string

@description('Location for resources')
param location string

@description('Application name')
param appName string

@description('Unique suffix for global resources')
param uniqueSuffix string

@description('Resource tags')
param tags object

// Key Vault (name must be 3-24 chars)
var keyVaultName = '${appName}${environment}kv${take(uniqueSuffix, 8)}'

resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name: keyVaultName
  location: location
  tags: tags
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    enabledForDeployment: true
    enabledForTemplateDeployment: true
    enableRbacAuthorization: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 7
  }
}

// Sample secret
resource sampleSecret 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  parent: keyVault
  name: 'demo-secret'
  properties: {
    value: 'This is a demo secret - replace with actual values'
    contentType: 'text/plain'
  }
}

// Outputs
output keyVaultId string = keyVault.id
output keyVaultName string = keyVault.name
output keyVaultUri string = keyVault.properties.vaultUri
