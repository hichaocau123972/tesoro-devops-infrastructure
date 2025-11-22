// Database Module - SQL Server, PostgreSQL, Redis

@description('Environment name')
param environment string

@description('Location for resources')
param location string

@description('Application name')
param appName string

@description('Unique suffix for global resources')
param uniqueSuffix string

@description('VNet ID for private endpoints')
param vnetId string

@description('Private endpoint subnet ID')
param privateEndpointSubnetId string

@description('Resource tags')
param tags object

@secure()
@description('SQL Server admin password')
param sqlAdminPassword string = newGuid()

@secure()
@description('PostgreSQL admin password')
param postgresAdminPassword string = newGuid()

// SQL Server
var sqlServerName = '${appName}-${environment}-sql-${uniqueSuffix}'
var sqlDatabaseName = '${appName}-${environment}-db'

resource sqlServer 'Microsoft.Sql/servers@2023-05-01-preview' = {
  name: sqlServerName
  location: location
  tags: tags
  properties: {
    administratorLogin: 'sqladmin'
    administratorLoginPassword: sqlAdminPassword
    version: '12.0'
    minimalTlsVersion: '1.2'
    publicNetworkAccess: 'Disabled'
  }
  identity: {
    type: 'SystemAssigned'
  }
}

// SQL Database - Hyperscale for production
resource sqlDatabase 'Microsoft.Sql/servers/databases@2023-05-01-preview' = {
  parent: sqlServer
  name: sqlDatabaseName
  location: location
  tags: tags
  sku: {
    name: 'Basic'
    tier: 'Basic'
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    catalogCollation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 2147483648 // 2GB for Basic tier
  }
}

// SQL Server Private Endpoint
resource sqlPrivateEndpoint 'Microsoft.Network/privateEndpoints@2023-05-01' = {
  name: '${sqlServerName}-pe'
  location: location
  tags: tags
  properties: {
    subnet: {
      id: privateEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: '${sqlServerName}-connection'
        properties: {
          privateLinkServiceId: sqlServer.id
          groupIds: [
            'sqlServer'
          ]
        }
      }
    ]
  }
}

// PostgreSQL Flexible Server
var postgresServerName = '${appName}-${environment}-postgres-${uniqueSuffix}'
var postgresDatabaseName = '${appName}_${environment}_analytics'

resource postgresServer 'Microsoft.DBforPostgreSQL/flexibleServers@2023-03-01-preview' = {
  name: postgresServerName
  location: location
  tags: tags
  sku: {
    name: 'Standard_B1ms'
    tier: 'Burstable'
  }
  properties: {
    administratorLogin: 'pgadmin'
    administratorLoginPassword: postgresAdminPassword
    version: '15'
    storage: {
      storageSizeGB: 32
    }
    backup: {
      backupRetentionDays: 7
      geoRedundantBackup: 'Disabled'
    }
    highAvailability: {
      mode: 'Disabled'
    }
  }
}

resource postgresDatabase 'Microsoft.DBforPostgreSQL/flexibleServers/databases@2023-03-01-preview' = {
  parent: postgresServer
  name: postgresDatabaseName
  properties: {
    charset: 'UTF8'
    collation: 'en_US.utf8'
  }
}

// PostgreSQL Private Endpoint removed for simplicity on free tier

// Azure Cache for Redis
var redisName = '${appName}-${environment}-redis-${uniqueSuffix}'

resource redis 'Microsoft.Cache/redis@2023-08-01' = {
  name: redisName
  location: location
  tags: tags
  properties: {
    sku: environment == 'production' ? {
      name: 'Premium'
      family: 'P'
      capacity: 1
    } : {
      name: 'Standard'
      family: 'C'
      capacity: 1
    }
    enableNonSslPort: false
    minimumTlsVersion: '1.2'
    publicNetworkAccess: 'Disabled'
    redisConfiguration: {
      'maxmemory-policy': 'allkeys-lru'
    }
    redisVersion: '6'
  }
  zones: environment == 'production' ? [
    '1'
    '2'
    '3'
  ] : []
}

// Redis Private Endpoint
resource redisPrivateEndpoint 'Microsoft.Network/privateEndpoints@2023-05-01' = {
  name: '${redisName}-pe'
  location: location
  tags: tags
  properties: {
    subnet: {
      id: privateEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: '${redisName}-connection'
        properties: {
          privateLinkServiceId: redis.id
          groupIds: [
            'redisCache'
          ]
        }
      }
    ]
  }
}

// Outputs
output serverName string = sqlServer.name
output sqlServerId string = sqlServer.id
output sqlDatabaseName string = sqlDatabase.name
output sqlServerFqdn string = sqlServer.properties.fullyQualifiedDomainName
output postgresServerName string = postgresServer.name
output postgresServerId string = postgresServer.id
output postgresDatabaseName string = postgresDatabase.name
output postgresServerFqdn string = postgresServer.properties.fullyQualifiedDomainName
output redisName string = redis.name
output redisId string = redis.id
output redisHostName string = redis.properties.hostName
