// Monitoring Module - Log Analytics, Alerts, Dashboards

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

// Metric Alerts

// High CPU Alert
resource cpuAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: '${appName}-${environment}-cpu-alert'
  location: 'global'
  tags: tags
  properties: {
    description: 'Alert when CPU usage exceeds 80%'
    severity: 2
    enabled: true
    scopes: []
    evaluationFrequency: 'PT5M'
    windowSize: 'PT15M'
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.MultipleResourceMultipleMetricCriteria'
      allOf: [
        {
          name: 'High CPU'
          criterionType: 'StaticThresholdCriterion'
          metricName: 'CpuPercentage'
          metricNamespace: 'Microsoft.Web/serverfarms'
          operator: 'GreaterThan'
          threshold: 80
          timeAggregation: 'Average'
        }
      ]
    }
    autoMitigate: true
    actions: [
      {
        actionGroupId: actionGroup.id
      }
    ]
  }
}

// High Memory Alert
resource memoryAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: '${appName}-${environment}-memory-alert'
  location: 'global'
  tags: tags
  properties: {
    description: 'Alert when memory usage exceeds 85%'
    severity: 2
    enabled: true
    scopes: []
    evaluationFrequency: 'PT5M'
    windowSize: 'PT15M'
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.MultipleResourceMultipleMetricCriteria'
      allOf: [
        {
          name: 'High Memory'
          criterionType: 'StaticThresholdCriterion'
          metricName: 'MemoryPercentage'
          metricNamespace: 'Microsoft.Web/serverfarms'
          operator: 'GreaterThan'
          threshold: 85
          timeAggregation: 'Average'
        }
      ]
    }
    autoMitigate: true
    actions: [
      {
        actionGroupId: actionGroup.id
      }
    ]
  }
}

// HTTP 5xx Errors Alert
resource http5xxAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: '${appName}-${environment}-http5xx-alert'
  location: 'global'
  tags: tags
  properties: {
    description: 'Alert when HTTP 5xx errors exceed threshold'
    severity: 1
    enabled: true
    scopes: []
    evaluationFrequency: 'PT1M'
    windowSize: 'PT5M'
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.MultipleResourceMultipleMetricCriteria'
      allOf: [
        {
          name: 'High 5xx Errors'
          criterionType: 'StaticThresholdCriterion'
          metricName: 'Http5xx'
          metricNamespace: 'Microsoft.Web/sites'
          operator: 'GreaterThan'
          threshold: 10
          timeAggregation: 'Total'
        }
      ]
    }
    autoMitigate: true
    actions: [
      {
        actionGroupId: actionGroup.id
      }
    ]
  }
}

// Response Time Alert
resource responseTimeAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: '${appName}-${environment}-response-time-alert'
  location: 'global'
  tags: tags
  properties: {
    description: 'Alert when response time exceeds 3 seconds'
    severity: 2
    enabled: true
    scopes: []
    evaluationFrequency: 'PT5M'
    windowSize: 'PT15M'
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.MultipleResourceMultipleMetricCriteria'
      allOf: [
        {
          name: 'High Response Time'
          criterionType: 'StaticThresholdCriterion'
          metricName: 'AverageResponseTime'
          metricNamespace: 'Microsoft.Web/sites'
          operator: 'GreaterThan'
          threshold: 3
          timeAggregation: 'Average'
        }
      ]
    }
    autoMitigate: true
    actions: [
      {
        actionGroupId: actionGroup.id
      }
    ]
  }
}

// Database DTU Alert (for SQL)
resource dtuAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = if (environment != 'production') {
  name: '${appName}-${environment}-dtu-alert'
  location: 'global'
  tags: tags
  properties: {
    description: 'Alert when database DTU exceeds 80%'
    severity: 2
    enabled: true
    scopes: []
    evaluationFrequency: 'PT5M'
    windowSize: 'PT15M'
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.MultipleResourceMultipleMetricCriteria'
      allOf: [
        {
          name: 'High DTU'
          criterionType: 'StaticThresholdCriterion'
          metricName: 'dtu_consumption_percent'
          metricNamespace: 'Microsoft.Sql/servers/databases'
          operator: 'GreaterThan'
          threshold: 80
          timeAggregation: 'Average'
        }
      ]
    }
    autoMitigate: true
    actions: [
      {
        actionGroupId: actionGroup.id
      }
    ]
  }
}

// Availability Alert
resource availabilityAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: '${appName}-${environment}-availability-alert'
  location: 'global'
  tags: tags
  properties: {
    description: 'Alert when availability drops below 99%'
    severity: 0
    enabled: environment == 'production'
    scopes: []
    evaluationFrequency: 'PT1M'
    windowSize: 'PT5M'
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.WebtestLocationAvailabilityCriteria'
      webTestId: availabilityTest.id
      componentId: ''
      failedLocationCount: 2
    }
    autoMitigate: false
    actions: [
      {
        actionGroupId: actionGroup.id
      }
    ]
  }
}

// Availability Test
resource availabilityTest 'Microsoft.Insights/webtests@2022-06-15' = {
  name: '${appName}-${environment}-availability-test'
  location: location
  tags: union(tags, {
    'hidden-link:': ''
  })
  kind: 'standard'
  properties: {
    syntheticMonitorId: '${appName}-${environment}-availability-test'
    name: '${appName}-${environment}-availability-test'
    enabled: environment == 'production'
    frequency: 300
    timeout: 30
    kind: 'standard'
    locations: [
      {
        id: 'us-ca-sjc-azr'
      }
      {
        id: 'us-tx-sn1-azr'
      }
      {
        id: 'us-il-ch1-azr'
      }
      {
        id: 'us-va-ash-azr'
      }
      {
        id: 'us-fl-mia-edge'
      }
    ]
    request: {
      requestUrl: 'https://tesoro-${environment}.azurewebsites.net/health'
      httpVerb: 'GET'
    }
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
    serializedData: '{"version":"Notebook/1.0","items":[{"type":1,"content":{"json":"## Tesoro XP - ${environment} Monitoring Dashboard\\n\\nReal-time metrics and insights"},"name":"text - 0"},{"type":10,"content":{"chartId":"workbookdb6e6f9e-8e9e-4b8a-8e9e-8e9e8e9e8e9e","version":"MetricsItem/2.0","size":0,"chartType":2,"resourceType":"microsoft.web/sites","metricScope":0,"resourceParameter":"AppService","metrics":[{"namespace":"microsoft.web/sites","metric":"microsoft.web/sites-Http Server Errors-Http5xx","aggregation":1,"splitBy":null}],"title":"HTTP 5xx Errors","gridSettings":{"rowLimit":10000}},"name":"HTTP 5xx Errors"},{"type":10,"content":{"chartId":"workbookdb6e6f9e-8e9e-4b8a-8e9e-8e9e8e9e8e9f","version":"MetricsItem/2.0","size":0,"chartType":2,"resourceType":"microsoft.web/sites","metricScope":0,"resourceParameter":"AppService","metrics":[{"namespace":"microsoft.web/sites","metric":"microsoft.web/sites-Performance-AverageResponseTime","aggregation":4,"splitBy":null}],"title":"Response Time","gridSettings":{"rowLimit":10000}},"name":"Response Time"}],"fallbackResourceIds":[],"fromTemplateId":"community-Workbooks/Azure Monitor - Getting Started/Resource Picker"}'
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
