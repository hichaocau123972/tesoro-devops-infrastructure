// Tesoro XP - Minimal Infrastructure Template (Free Tier Compatible)
// This deploys basic infrastructure without quota restrictions

targetScope = 'subscription'

@description('Environment name (dev, staging, production)')
@allowed([
  'dev'
  'staging'
  'production'
])
param environment string

@description('Primary Azure region')
param location string = 'eastus'

@description('Application name prefix')
param appName string = 'tesoro'

@description('Tags to apply to all resources')
param tags object = {
  application: 'tesoro-xp'
  managedBy: 'bicep'
  costCenter: 'engineering'
  tier: 'minimal-free'
}

// Resource naming convention
var resourceGroupName = '${appName}-${environment}-rg'
var uniqueSuffix = uniqueString(subscription().id, environment)

// Create resource group
resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
  tags: union(tags, {
    environment: environment
  })
}

// Deploy storage (always works on free tier)
module storage 'modules/storage-minimal.bicep' = {
  scope: resourceGroup
  name: 'storage-deployment'
  params: {
    environment: environment
    location: location
    appName: appName
    uniqueSuffix: uniqueSuffix
    tags: tags
  }
}

// Deploy Key Vault (works on free tier)
module keyVault 'modules/keyvault-minimal.bicep' = {
  scope: resourceGroup
  name: 'keyvault-deployment'
  params: {
    environment: environment
    location: location
    appName: appName
    uniqueSuffix: uniqueSuffix
    tags: tags
  }
}

// Deploy networking (no quota issues)
module networking 'modules/networking-minimal.bicep' = {
  scope: resourceGroup
  name: 'networking-deployment'
  params: {
    environment: environment
    location: location
    appName: appName
    tags: tags
  }
}

// Deploy Log Analytics (free tier available)
module monitoring 'modules/monitoring-minimal.bicep' = {
  scope: resourceGroup
  name: 'monitoring-deployment'
  params: {
    environment: environment
    location: location
    appName: appName
    uniqueSuffix: uniqueSuffix
    tags: tags
  }
}

// Outputs
output resourceGroupName string = resourceGroup.name
output storageAccountName string = storage.outputs.storageAccountName
output keyVaultName string = keyVault.outputs.keyVaultName
output vnetName string = networking.outputs.vnetName
output logAnalyticsWorkspaceName string = monitoring.outputs.logAnalyticsWorkspaceName
