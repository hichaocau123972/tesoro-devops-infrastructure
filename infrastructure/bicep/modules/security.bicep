// Security Module - Key Vault, Managed Identities

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

// Key Vault (name must be 3-24 chars, so use shorter suffix)
var keyVaultName = '${appName}${environment}kv${take(uniqueSuffix, 8)}'

resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name: keyVaultName
  location: location
  tags: tags
  properties: {
    sku: {
      family: 'A'
      name: environment == 'production' ? 'premium' : 'standard'
    }
    tenantId: subscription().tenantId
    enabledForDeployment: true
    enabledForTemplateDeployment: true
    enabledForDiskEncryption: false
    enableRbacAuthorization: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    enablePurgeProtection: environment == 'production' ? true : null
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
      ipRules: []
      virtualNetworkRules: []
    }
    publicNetworkAccess: 'Disabled'
  }
}

// Managed Identity for App Services
resource appServiceIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: '${appName}-${environment}-app-identity'
  location: location
  tags: tags
}

// Managed Identity for Container Apps
resource containerAppsIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: '${appName}-${environment}-container-identity'
  location: location
  tags: tags
}

// Managed Identity for Database Access
resource databaseIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: '${appName}-${environment}-db-identity'
  location: location
  tags: tags
}

// Role Assignments for Key Vault
resource appServiceKvSecretsUser 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: keyVault
  name: guid(keyVault.id, appServiceIdentity.id, 'secrets-user')
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4633458b-17de-408a-b874-0445c86b69e6') // Key Vault Secrets User
    principalId: appServiceIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

resource containerAppsKvSecretsUser 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: keyVault
  name: guid(keyVault.id, containerAppsIdentity.id, 'secrets-user')
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4633458b-17de-408a-b874-0445c86b69e6') // Key Vault Secrets User
    principalId: containerAppsIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

// Diagnostic Settings for Key Vault - removed for initial deployment simplicity

// Sample secrets (placeholder - actual values should be set via deployment pipeline)
resource sqlConnectionStringSecret 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  parent: keyVault
  name: 'sql-connection-string'
  properties: {
    value: 'PLACEHOLDER-SET-VIA-PIPELINE'
    contentType: 'text/plain'
  }
}

resource postgresConnectionStringSecret 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  parent: keyVault
  name: 'postgres-connection-string'
  properties: {
    value: 'PLACEHOLDER-SET-VIA-PIPELINE'
    contentType: 'text/plain'
  }
}

resource redisConnectionStringSecret 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  parent: keyVault
  name: 'redis-connection-string'
  properties: {
    value: 'PLACEHOLDER-SET-VIA-PIPELINE'
    contentType: 'text/plain'
  }
}

// Outputs
output keyVaultId string = keyVault.id
output keyVaultName string = keyVault.name
output keyVaultUri string = keyVault.properties.vaultUri
output appServiceIdentityId string = appServiceIdentity.id
output appServiceIdentityPrincipalId string = appServiceIdentity.properties.principalId
output containerAppsIdentityId string = containerAppsIdentity.id
output containerAppsIdentityPrincipalId string = containerAppsIdentity.properties.principalId
output databaseIdentityId string = databaseIdentity.id
output databaseIdentityPrincipalId string = databaseIdentity.properties.principalId
