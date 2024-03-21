targetScope = 'subscription'

param storagePrefix string
param rlocation string
param resourceGroupName string


/* Here we're receiving the tags as an onject */
param tags object

/* Here we receiving stages as an array
  THe object itself has two properties: name and a bool called tiering.
*/
param stages array

resource newRG 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: resourceGroupName
  location: rlocation
  tags: tags
}


/* This module is beeing deployed mutliple time because we get in param stages muutiple values */
module stg 'storage.bicep' = [for stage in stages:{
  /* Here we access the propertie name of the object stage*/
  name: stage.name
  scope: newRG
  params: {
    storagePrefix: storagePrefix
    rlocation: rlocation
    storageAccountName: stage.name
    /* Here we access the bool "tiering" that consists of true or false of the object "stage"*/
    tiering: stage.tiering
  }
}]
