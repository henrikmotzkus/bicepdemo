targetScope = 'subscription'


/*
  We introduce a new layer in out resouce design.
  We need resource groups to separate the customers from each other.
  Therefore we create a a new array that takes the names of the resource groups.
  */
param resourceGroupNames array = ['Step-3-Storage-Bicep-1', 'Step-3-Storage-Bicep-2', 'Step-3-Storage-Bicep-3']
param storagePrefix string = 'step3'
param rlocation string


/*
  Good coding pratise is to reuse code. Therefore we nest the storage account module into the resource group module. 
  Here we're looping the module not within the module. This is another approach. Compare to with step 2.
  */
module resourceGroup 'rg.bicep' = [for name in resourceGroupNames: {
  name: '${name}'
  params: {
    storagePrefix: storagePrefix
    rlocation: rlocation
    resourceGroupName: '${name}'
  }
}]
