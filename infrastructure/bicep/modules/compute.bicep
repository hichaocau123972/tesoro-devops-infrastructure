// Compute Module - App Services, Container Apps, Function Apps

@description('Environment name')
param environment string

@description('Location for resources')
param location string

@description('Application name')
param appName string

@description('Unique suffix for global resources')
param uniqueSuffix string

@description('VNet ID')
param vnetId string

@description('App Service subnet ID')
param appServiceSubnetId string

@description('Key Vault name for secrets')
param keyVaultName string

@description('Resource tags')
param tags object

// App Service Plan
var appServicePlanName = '${appName}-${environment}-asp'

resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: appServicePlanName
  location: location
  tags: tags
  sku: environment == 'production' ? {
    name: 'P2v3'
    tier: 'PremiumV3'
    capacity: 3
  } : (environment == 'staging' ? {
    name: 'P1v3'
    tier: 'PremiumV3'
    capacity: 2
  } : {
    name: 'S1'
    tier: 'Standard'
    capacity: 1
  })
  kind: 'linux'
  properties: {
    reserved: true
    zoneRedundant: environment == 'production' ? true : false
  }
}

// App Service
var appServiceName = '${appName}-${environment}-app-${uniqueSuffix}'

resource appService 'Microsoft.Web/sites@2023-01-01' = {
  name: appServiceName
  location: location
  tags: tags
  kind: 'app,linux'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    clientAffinityEnabled: false
    virtualNetworkSubnetId: appServiceSubnetId
    siteConfig: {
      linuxFxVersion: 'DOTNETCORE|8.0'
      alwaysOn: true
      http20Enabled: true
      minTlsVersion: '1.2'
      ftpsState: 'Disabled'
      healthCheckPath: '/health'
      vnetRouteAllEnabled: true
      appSettings: [
        {
          name: 'ASPNETCORE_ENVIRONMENT'
          value: environment == 'production' ? 'Production' : (environment == 'staging' ? 'Staging' : 'Development')
        }
        {
          name: 'KeyVault__VaultUri'
          value: 'https://${keyVaultName}${az.environment().suffixes.keyvaultDns}'
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsights.properties.ConnectionString
        }
      ]
    }
  }
}

// Auto-scaling for App Service
resource autoScaleSettings 'Microsoft.Insights/autoscalesettings@2022-10-01' = if (environment == 'production' || environment == 'staging') {
  name: '${appServicePlanName}-autoscale'
  location: location
  tags: tags
  properties: {
    enabled: true
    targetResourceUri: appServicePlan.id
    profiles: [
      {
        name: 'Auto scale based on metrics'
        capacity: {
          minimum: environment == 'production' ? '3' : '2'
          maximum: environment == 'production' ? '10' : '5'
          default: environment == 'production' ? '3' : '2'
        }
        rules: [
          {
            metricTrigger: {
              metricName: 'CpuPercentage'
              metricResourceUri: appServicePlan.id
              timeGrain: 'PT1M'
              statistic: 'Average'
              timeWindow: 'PT5M'
              timeAggregation: 'Average'
              operator: 'GreaterThan'
              threshold: 70
            }
            scaleAction: {
              direction: 'Increase'
              type: 'ChangeCount'
              value: '1'
              cooldown: 'PT5M'
            }
          }
          {
            metricTrigger: {
              metricName: 'CpuPercentage'
              metricResourceUri: appServicePlan.id
              timeGrain: 'PT1M'
              statistic: 'Average'
              timeWindow: 'PT10M'
              timeAggregation: 'Average'
              operator: 'LessThan'
              threshold: 30
            }
            scaleAction: {
              direction: 'Decrease'
              type: 'ChangeCount'
              value: '1'
              cooldown: 'PT10M'
            }
          }
        ]
      }
    ]
  }
}

// Container App Environment
var containerAppEnvName = '${appName}-${environment}-cae'

resource containerAppEnvironment 'Microsoft.App/managedEnvironments@2023-05-01' = {
  name: containerAppEnvName
  location: location
  tags: tags
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalyticsWorkspace.properties.customerId
        sharedKey: logAnalyticsWorkspace.listKeys().primarySharedKey
      }
    }
    zoneRedundant: environment == 'production' ? true : false
  }
}

// Sample Container App
var containerAppName = '${appName}-${environment}-ca'

resource containerApp 'Microsoft.App/containerApps@2023-05-01' = {
  name: containerAppName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    managedEnvironmentId: containerAppEnvironment.id
    configuration: {
      ingress: {
        external: true
        targetPort: 8080
        transport: 'auto'
        allowInsecure: false
      }
      secrets: []
    }
    template: {
      containers: [
        {
          name: 'rewards-api'
          image: 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'
          resources: {
            cpu: json('0.5')
            memory: '1Gi'
          }
        }
      ]
      scale: {
        minReplicas: environment == 'production' ? 3 : 1
        maxReplicas: environment == 'production' ? 10 : 3
        rules: [
          {
            name: 'http-rule'
            http: {
              metadata: {
                concurrentRequests: '100'
              }
            }
          }
        ]
      }
    }
  }
}

// Function App for event processing
var functionAppName = '${appName}-${environment}-func-${uniqueSuffix}'
var functionStorageAccountName = toLower('${appName}${environment}funcst${take(uniqueSuffix, 6)}')

resource functionStorageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: functionStorageAccountName
  location: location
  tags: tags
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
  }
}

resource functionApp 'Microsoft.Web/sites@2023-01-01' = {
  name: functionAppName
  location: location
  tags: tags
  kind: 'functionapp,linux'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    virtualNetworkSubnetId: appServiceSubnetId
    siteConfig: {
      linuxFxVersion: 'DOTNET-ISOLATED|8.0'
      alwaysOn: environment != 'dev'
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${functionStorageAccount.name};AccountKey=${functionStorageAccount.listKeys().keys[0].value};EndpointSuffix=${az.environment().suffixes.storage}'
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet-isolated'
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsights.properties.ConnectionString
        }
      ]
    }
  }
}

// Application Insights
var appInsightsName = '${appName}-${environment}-ai'

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: '${appName}-${environment}-law'
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: environment == 'production' ? 90 : 30
  }
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  tags: tags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
}

// Outputs
output appServicePlanId string = appServicePlan.id
output appServicePlanName string = appServicePlan.name
output appServiceId string = appService.id
output appServiceName string = appService.name
output appServiceUrl string = 'https://${appService.properties.defaultHostName}'
output containerAppEnvironmentId string = containerAppEnvironment.id
output containerAppId string = containerApp.id
output containerAppUrl string = 'https://${containerApp.properties.configuration.ingress.fqdn}'
output functionAppId string = functionApp.id
output functionAppName string = functionApp.name
output appInsightsId string = appInsights.id
output appInsightsInstrumentationKey string = appInsights.properties.InstrumentationKey
output appInsightsConnectionString string = appInsights.properties.ConnectionString
