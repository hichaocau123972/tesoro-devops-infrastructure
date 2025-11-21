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
  sku: environment == 'production' ? {
    name: 'HS_Gen5_4'
    tier: 'Hyperscale'
    family: 'Gen5'
    capacity: 4
  } : {
    name: 'GP_S_Gen5_2'
    tier: 'GeneralPurpose'
    family: 'Gen5'
    capacity: 2
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    catalogCollation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: environment == 'production' ? 1099511627776 : 32212254720 // 1TB for prod, 30GB for dev/staging
    zoneRedundant: environment == 'production' ? true : false
    readScale: environment == 'production' ? 'Enabled' : 'Disabled'
    requestedBackupStorageRedundancy: environment == 'production' ? 'Geo' : 'Local'
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
  sku: environment == 'production' ? {
    name: 'Standard_D4s_v3'
    tier: 'GeneralPurpose'
  } : {
    name: 'Standard_B2s'
    tier: 'Burstable'
  }
  properties: {
    administratorLogin: 'pgadmin'
    administratorLoginPassword: postgresAdminPassword
    version: '15'
    storage: {
      storageSizeGB: environment == 'production' ? 512 : 128
      autoGrow: 'Enabled'
    }
    backup: {
      backupRetentionDays: environment == 'production' ? 35 : 7
      geoRedundantBackup: environment == 'production' ? 'Enabled' : 'Disabled'
    }
    highAvailability: environment == 'production' ? {
      mode: 'ZoneRedundant'
    } : {
      mode: 'Disabled'
    }
    network: {
      publicNetworkAccess: 'Disabled'
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

// PostgreSQL Private Endpoint
resource postgresPrivateEndpoint 'Microsoft.Network/privateEndpoints@2023-05-01' = {
  name: '${postgresServerName}-pe'
  location: location
  tags: tags
  properties: {
    subnet: {
      id: privateEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: '${postgresServerName}-connection'
        properties: {
          privateLinkServiceId: postgresServer.id
          groupIds: [
            'postgresqlServer'
          ]
        }
      }
    ]
  }
}

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
