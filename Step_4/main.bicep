targetScope = 'subscription'


/*
  This is a dictionary object. Dictionary objects are own data structures that can be created accordingly to our requirements.
  We need different configurations for our customers. 
  Every customer can decide for stages. Every customer is accountable for the costs. And every customer can opt-in for specific date movement policy. 
  Our object looks like this
  
  Tenant = The customer
  Owner = Tags on the resources
  stages = Required stages
  tiering = on or off

  We will use this object to configure every step in our deployment chain.
*/
param configs object = {
  Tenant1: {
    rgname: 'Step-4-Storage-Bicep-1'
    owner: 'Henrik'
    stages: [
      {
        name: 'dev'
        tiering: true
      }
      {
        name: 'test'
        tiering: false 
      }
    ]
  }
  Tenant2: {
    rgname: 'Step-4-Storage-Bicep-2'
    owner: 'Peter'
    stages: [
      {
        name: 'dev'
        tiering: true
      }
      {
        name: 'test'
        tiering: false 
      }
      {
        name: 'prod'
        tiering: true 
      }
    ]
  }
  Tenant3: {
    rgname: 'Step-4-Storage-Bicep-3'
    owner: 'Andreas'
    stages: [
      {
        name: 'dev'
        tiering: true
      }
      {
        name: 'qa'
        tiering: false 
      }
      {
        name: 'prod'
        tiering: true 
      }
    ]
  }
  Tenant4: {
    rgname: 'Step-4-Storage-Firma-XYZ'
    owner: 'Bill Gates'
    stages: [
      {
        name: 'dev'
        tiering: true
      }
      {
        name: 'test'
        tiering: false 
      }
      {
        name: 'qa'
        tiering: false 
      }
      {
        name: 'prod'
        tiering: false 
      }
    ]
  }
  Tenant5: {
    rgname: 'Step-4-Storage-Firma-123'
    owner: 'Steve Ballmer'
    stages: [
      {
        name: 'dev'
        tiering: true
      }
    ]
  }
}
param storagePrefix string = 'step4'
param rlocation string = 'West Europe'


/* 
  This loop iterates though our config object. "name" is one instance out of "configs". 
  The function item converts an object to an array. 
  Accessing the different properties is possible by using standard JSON object literals.
*/
module resourceGroup 'rg.bicep' = [for name in items(configs): {
  /*  Accessing the different properties is possible by using standard JSON object literals.*/
  name: name.value.rgname
  params: {
    storagePrefix: storagePrefix
    rlocation: rlocation
    /* Every array value is transfered into this parameter */
    resourceGroupName: name.value.rgname
    tags: {owner: name.value.owner}
    /* Here we transfer not only one value to the module but another array  */
    stages: name.value.stages
  }
}]


