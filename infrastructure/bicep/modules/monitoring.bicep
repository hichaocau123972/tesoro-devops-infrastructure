// Monitoring Module - Log Analytics, Dashboards (Simplified for initial deployment)

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

// Log Analytics Workspace
var logAnalyticsName = '${appName}-${environment}-law'

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: logAnalyticsName
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: environment == 'production' ? 90 : 30
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
    workspaceCapping: {
      dailyQuotaGb: environment == 'dev' ? 1 : -1
    }
  }
}

// Action Group for alerts
var actionGroupName = '${appName}-${environment}-ag'

resource actionGroup 'Microsoft.Insights/actionGroups@2023-01-01' = {
  name: actionGroupName
  location: 'global'
  tags: tags
  properties: {
    groupShortName: take('${appName}-${environment}', 12)
    enabled: true
    emailReceivers: [
      {
        name: 'DevOps Team'
        emailAddress: 'devops@tesoro-xp.com'
        useCommonAlertSchema: true
      }
    ]
    smsReceivers: environment == 'production' ? [
      {
        name: 'On-Call Engineer'
        countryCode: '1'
        phoneNumber: '5555551234'
      }
    ] : []
  }
}

// Workbook for monitoring dashboard
resource monitoringWorkbook 'Microsoft.Insights/workbooks@2022-04-01' = {
  name: guid('${appName}-${environment}-workbook')
  location: location
  tags: tags
  kind: 'shared'
  properties: {
    displayName: '${appName} ${environment} - Monitoring Dashboard'
    serializedData: '{"version":"Notebook/1.0","items":[{"type":1,"content":{"json":"## Tesoro XP - ${environment} Monitoring Dashboard\\n\\nReal-time metrics and insights"},"name":"text - 0"}],"fallbackResourceIds":[]}'
    category: 'workbook'
    sourceId: logAnalyticsWorkspace.id
  }
}

// Log Analytics Queries (saved searches)
resource savedSearches 'Microsoft.OperationalInsights/workspaces/savedSearches@2020-08-01' = {
  parent: logAnalyticsWorkspace
  name: 'failed-transactions'
  properties: {
    category: 'Application'
    displayName: 'Failed Transactions'
    query: 'AppTraces | where severityLevel >= 3 | where message contains "transaction" | project timestamp, severityLevel, message, customDimensions'
    version: 2
  }
}

// Outputs
output logAnalyticsWorkspaceId string = logAnalyticsWorkspace.id
output logAnalyticsWorkspaceName string = logAnalyticsWorkspace.name
output logAnalyticsCustomerId string = logAnalyticsWorkspace.properties.customerId
output actionGroupId string = actionGroup.id
output workbookId string = monitoringWorkbook.id
