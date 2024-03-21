/*
  Bicep can handle parameter and define contraints.
  @ is a annotation that does that
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

/* We can off course define a default value for every parameter */
param storageSKU string = 'Standard_LRS'
param rlocation string

/*
  Here we take the array from the main.bicep
  */
param storageAccountNames array

/*
  Because we get an array of names from the main.bicep we need to iterate through that list with a for loop
  */
resource stg 'Microsoft.Storage/storageAccounts@2023-01-01' = [for name in storageAccountNames: {
  /* Every storage account needs worldwide unique name.
    Therefor we generate the name dynamically.
    */
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

/*
  A storage account needs an additional blobservice and a container
  Of course we need to iterate though the ingressed array of storage names
  */
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
