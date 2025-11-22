// Alerts Module - Add monitoring alerts after infrastructure is deployed
// Run this separately after main deployment completes

@description('Environment name')
param environment string

@description('Application name')
param appName string

@description('App Service Plan resource ID')
param appServicePlanId string

@description('App Service resource ID')
param appServiceId string

@description('SQL Database resource ID')
param sqlDatabaseId string

@description('Action Group ID')
param actionGroupId string

@description('Resource tags')
param tags object

// High CPU Alert
resource cpuAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: '${appName}-${environment}-cpu-alert'
  location: 'global'
  tags: tags
  properties: {
    description: 'Alert when CPU usage exceeds 80%'
    severity: 2
    enabled: true
    scopes: [
      appServicePlanId
    ]
    evaluationFrequency: 'PT5M'
    windowSize: 'PT15M'
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
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
        actionGroupId: actionGroupId
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
    scopes: [
      appServicePlanId
    ]
    evaluationFrequency: 'PT5M'
    windowSize: 'PT15M'
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
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
        actionGroupId: actionGroupId
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
    scopes: [
      appServiceId
    ]
    evaluationFrequency: 'PT1M'
    windowSize: 'PT5M'
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
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
        actionGroupId: actionGroupId
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
    scopes: [
      appServiceId
    ]
    evaluationFrequency: 'PT5M'
    windowSize: 'PT15M'
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
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
        actionGroupId: actionGroupId
      }
    ]
  }
}

// Database DTU Alert (for non-production with DTU-based tiers)
resource dtuAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = if (environment != 'production') {
  name: '${appName}-${environment}-dtu-alert'
  location: 'global'
  tags: tags
  properties: {
    description: 'Alert when database DTU exceeds 80%'
    severity: 2
    enabled: true
    scopes: [
      sqlDatabaseId
    ]
    evaluationFrequency: 'PT5M'
    windowSize: 'PT15M'
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
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
        actionGroupId: actionGroupId
      }
    ]
  }
}

// Outputs
output cpuAlertId string = cpuAlert.id
output memoryAlertId string = memoryAlert.id
output http5xxAlertId string = http5xxAlert.id
output responseTimeAlertId string = responseTimeAlert.id
