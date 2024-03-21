/*
  Storage Prefix that is concatenated to the resource name
  Location where all resources are located.
*/
param storagePrefix string = 'step1'
param location string



@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
  'Standard_ZRS'
  'Premium_LRS'
  'Premium_ZRS'
  'Standard_GZRS'
  'Standard_RAGZRS'
])
param storageSKU string = 'Standard_LRS'


resource stg 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: 'dev${storagePrefix}storage'
  location: location
  sku: {
    name: storageSKU
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Cool'
    allowBlobPublicAccess: false
    allowCrossTenantReplication: false
    minimumTlsVersion: 'TLS1_2'
    networkAcls: {
      bypass: 'None'
      defaultAction: 'Deny'
      ipRules: [
        {
          action: 'Allow'
          value: '0.0.0.0/0'
        }
      ]
    }
    publicNetworkAccess: 'Enabled'
    supportsHttpsTrafficOnly: true
  }
}

resource blobservice 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' = {
  parent: stg
  name: 'default'
}

resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  parent: blobservice
  name: 'blobcontainer'
  properties:{
    publicAccess: 'None'
  }
}

output storageendpoint string = stg.properties.primaryEndpoints.blob
