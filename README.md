# This turorial is a step-by-step beginners guide for bicep

Learn the core principles of bicep in a step-by-step tutorial based on a real world scenario. By working through the steps the requirements will advance. 

## Requirements / Real world scenario

Contoso has a internal IT department that wants to develop a storage solution on Azure to relieve the internal storage systems. The internal IT provider wants to offer this to different departments within the company. And will allocate the costs of the Azure resources to the concerning department. For data protections purposes and safe deployment principles the deployment and the storage accounts need to be separated. Production  must not be affected by testing or development activities. It is not an one time deployment it could be that more and more internal departments are using this solution. The solution need to be as cost effective as possible. The data path needs to be encrypted. Onboarding new customers has to be automated 100%. The script need to be as short as possible to avoid errors. And the scripts need to be reusable as much as possible. Multiple employees are working in the internal IT department on serving customer requests. Onprem integration is needed as well, therefore processes that running onprem needed to be secured as much as possible. 

## High Level Solution design

1. IaC with bicep
2. Azure Storage Account (As the team expects lots of writes the cool tier for the storage account is most price effective. See Azure price calculator)
3. Transfer data over plain internet
4. Encryption of the data path
5. Segregation of the stages by using multiple storage account 
6. Segregation of the departments by using multiple resource groups
7. A storage movement policy per department should move data to more price effective storage tiers
8. For Deployment Azure DevOps
9. AAD certificate based authentication for the local running processes

## Instructions
Every folder represents a step towards the solution to the problem. The Deploy.ps1 is the central controlling script to roll out every step.

## Step 1 - Deploy a storage account in an existing resouce group
The PowerShell script logs into Azure, selects the subscription and creates a resource group. Then it deploys the bicep script. The bicep creates a storage account and a container into this resource group.

This step implements the basics of a single bicep file deployment that deploys resources. We will use parameters, resources, outputs and PowerShell.

## Step 2 - Implement multi-stages
Because we need to separate accounts to different stages it makes sense to create a storage account per stage. In our case we have a dev, test, QA, prod stage. Because we need to produce highly reusable code it makes sense to create a bicep module that deploys the storage accounts multiple times.

This step shows the advantages of modules, loops, arrays and different deployment scopes.

## Step 3 - Implement multi tenancy
The requirements are to implement a multi-tenant solution. Multiple customers needed to be onboarded to separate environments. That means that separation into resource groups makes sense. Therefore, we develop a new bicep module that deploys multiple resource groups. And we reuse the storage module. 

This step implements module nesting. A main module controls the creation of the resource groups. The nested resource group script controls the creation of the storage accounts. IN this step we use a different approach to handle loops.

## Step 4 - Implement changes at scale and configure the resources indiviually 
We want to add more meta data to the environment to allocate the costs to the right department. Therefore, we need tags added to the resources. These tags are different to each department. And we want to implement conditional deployments because not all departments need a movement policy. And we want to deploy only the stages that are needed by departments. 

This step implements dictionary objects and conditions to configure our environments. We create a data structure that is handled by the bicep. And we change the array loop handling accordingly.

## Step 5 - Implement save deployment practises
Because we want to work efficiently and safe, we need to create a Azure DevOps Pipeline to roll out the deployments. Also, when many developers are working on the same environment it is a good idea to coordinate work in Azure DevOps. 

This step implements an Azure pipeline for bicep deployment and deploys the code that is located in folder Step 4. We need to manually configure some parts of Azure DevOps. 

https://learn.microsoft.com/de-de/azure/azure-resource-manager/bicep/add-template-to-azure-pipelines?tabs=CLI

## Step 6 - Upload data
In the preceding step we created the Azure infrastructure. Now we need to upload new data automatically to the new blob container into the customer storage account. When a new customer wants to upload data from its server to the storage account a process need to run on the server and copy the data. The experience should be as easy as possible for the customer. We want to create a Sync-Process that is configured upfront. The server needs to be registered upfront. Never ever a secret should be stored in cleartext nor on the server neither in the source code.

This step builds a PS-Script that is delivered to the customer. That script should include a registering step that registers the customer to our environment.

https://learn.microsoft.com/en-us/azure/active-directory/develop/howto-authenticate-service-principal-powershell


