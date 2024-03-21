/*
  The target scope defines the scope of the deployment. Azure has a hierachical deployment system. 
  On the top you have the AAD tenant,
                            |
                            -> Then a Management Group
                                      |
                                      -> Then a subscription
                                              |
                                              -> Then a resource group
  Every deployment need to be deployed to a scope. 
  In this deployment the resource group need to be deployed to the subscription scope.
  The storage account module will be deployed to the resource group. Bicep will handle deploying to a different scope. 
  */
targetScope = 'subscription'

/*
  For ease of the tutorial we will define our params directly in the bicep. 
  Don't get me wrong better coding principle is to outsource the data into a separate file
  */
param resourceGroupName string = 'Step-2-Storage-Bicep'

/*
  Every storage account need a unique name that will be generated of multiple strings
  */
param storagePrefix string = 'step2'

/*
  The resource deployment need to be in a Azure region 
  */
param rlocation string

/*
  We ned to deploy multiple stages for our customers. They need to be separated. This is in general good Azure resource design.
  */
param storageAccountsNames array = ['dev', 'test', 'prod', 'qa']

/*
  The resource group is the conteiner of all Azure resources. Please group resources with the same lifecycle in the same resource group
  */
resource newRG 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: resourceGroupName
  location: rlocation
}

/*
  We want to deploy multiple stages. Good coding practise is to reuse code. A module is reusable. 
  We feed the array param to the module and the module will take care of the looping though that array.
  In a later step you will find another approach.
  'storage.bicep' points to the bicep file in the same folder
  */
module firstStorageAcct 'storage.bicep' = {
  name: 'storageAccount'
  /* Here the module will automatically handle the deplyoment to a different deployment scope */
  scope: newRG
  params: {
    storagePrefix: storagePrefix
    rlocation: rlocation
    storageAccountNames: storageAccountsNames
  }
}
