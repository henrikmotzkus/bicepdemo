/*
  This is the new resource group module that reuses the storage module
  */


targetScope = 'subscription'

param storagePrefix string
param rlocation string
param storageAccountsNames array = ['dev', 'test', 'prod', 'qa']
param resourceGroupName string

resource newRG 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: resourceGroupName
  location: rlocation
}

module firstStorageAcct 'storage.bicep' = {
  name: 'storageAccount'
  scope: newRG
  params: {
    storagePrefix: storagePrefix
    rlocation: rlocation
    storageAccountNames: storageAccountsNames
  }
}
