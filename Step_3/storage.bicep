/* 
  Nothing new here in comparation to step 2
  */

  
@minLength(3)
@maxLength(11)
param storagePrefix string

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
param rlocation string
param storageAccountNames array

resource stg 'Microsoft.Storage/storageAccounts@2023-01-01' = [for name in storageAccountNames: {
  name: '${name}${storagePrefix}${uniqueString(resourceGroup().id)}'
  location: rlocation
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
}]

resource blobservice 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' = [for i in range(0, length(storageAccountNames)): {
  parent: stg[i]
  name: 'default'
}]

resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = [for i in range(0, length(storageAccountNames)):{
  parent: blobservice[i]
  name: 'blobcontainer'
  properties:{
    publicAccess: 'None'
  }
}]
