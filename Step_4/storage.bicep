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
param storageAccountName string
/* 
  This is the additional paramater that we need to deploy accordingly to conditions. Is tiering needed by the customer? 
  */
param tiering bool

resource stg 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: '${storageAccountName}${storagePrefix}${uniqueString(resourceGroup().id)}'
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
  /* 
    Here we deploy the additional tag strategy to allocate the costs to the right department.
    Bicep can look at the resource group level and inherit it to the underlying reource
    */
  tags: {
    Owner: resourceGroup().tags['owner']
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

/* 
  If tiering es requested from the customer we will deploy this. 
  the bicep function "if" does that for us.
  The storage account activates a tiering policy that moves blobs to the archive tier after 90 days of inactivity.
  */
resource tieringpolicy 'Microsoft.Storage/storageAccounts/managementPolicies@2022-09-01' = if(tiering){
  name: 'default'
  parent: stg
  properties: {
    policy: {
      rules: [
       {
          enabled: true
          name: 'archive-rule'
          type: 'Lifecycle'
          definition: {
            actions: {
              version: {
                delete: {
                  daysAfterCreationGreaterThan: 90
                }
              }
              baseBlob: {
                tierToArchive: {
                  daysAfterModificationGreaterThan: 90
                  daysAfterLastTierChangeGreaterThan: 7
                }
              }
            }
            filters: {
              blobTypes: [
                'blockBlob'
              ]
            }
          }
        }
      ]
    }
  }
}
