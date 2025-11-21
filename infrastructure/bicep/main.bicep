// Tesoro XP - Main Infrastructure Template
// This template orchestrates all infrastructure components

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

@description('Secondary region for geo-replication')
param secondaryLocation string = 'westus2'

@description('Application name prefix')
param appName string = 'tesoro'

@description('Tags to apply to all resources')
param tags object = {
  application: 'tesoro-xp'
  managedBy: 'bicep'
  costCenter: 'engineering'
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

// Deploy networking module
module networking './modules/networking.bicep' = {
  scope: resourceGroup
  name: 'networking-deployment'
  params: {
    environment: environment
    location: location
    appName: appName
    tags: tags
  }
}

// Deploy security module (Key Vault, Managed Identities)
module security './modules/security.bicep' = {
  scope: resourceGroup
  name: 'security-deployment'
  params: {
    environment: environment
    location: location
    appName: appName
    uniqueSuffix: uniqueSuffix
    tags: tags
  }
}

// Deploy database module
module database './modules/database.bicep' = {
  scope: resourceGroup
  name: 'database-deployment'
  params: {
    environment: environment
    location: location
    appName: appName
    uniqueSuffix: uniqueSuffix
    vnetId: networking.outputs.vnetId
    privateEndpointSubnetId: networking.outputs.privateEndpointSubnetId
    tags: tags
  }
  dependsOn: [
    networking
  ]
}

// Deploy storage module
module storage './modules/storage.bicep' = {
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

// Deploy compute module (App Services, Container Apps)
module compute './modules/compute.bicep' = {
  scope: resourceGroup
  name: 'compute-deployment'
  params: {
    environment: environment
    location: location
    appName: appName
    uniqueSuffix: uniqueSuffix
    vnetId: networking.outputs.vnetId
    appServiceSubnetId: networking.outputs.appServiceSubnetId
    keyVaultName: security.outputs.keyVaultName
    tags: tags
  }
  dependsOn: [
    networking
    security
  ]
}

// Deploy monitoring module
module monitoring './modules/monitoring.bicep' = {
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
output vnetId string = networking.outputs.vnetId
output keyVaultName string = security.outputs.keyVaultName
output appServiceName string = compute.outputs.appServiceName
output databaseServerName string = database.outputs.serverName
output logAnalyticsWorkspaceId string = monitoring.outputs.logAnalyticsWorkspaceId
