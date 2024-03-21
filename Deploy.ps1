<#
    .SYNOPSIS
    Is the controll script that runs all deployments

    .DESCRIPTION
    This script is needed when you work through my bicep tutorial.
    Start here when you want to start deployments.
    This script is not intended to be executed completely from start to end. 
    Iterate though the step you're working on.

    .LINK
    Online version: https://dev.azure.com/e5testtenant/BicepTutorial

#>


##############################
#       Preperations         #
##############################

$SubscriptionID = <Your Subscription ID> 
$TenantID = <Yout tenant ID> #This is needed in step 6
$AppID = <Yout App ID> #This is needed in step 6


# Connect your Powershell session to Azure to deploy al the bicep files
Connect-AzAccount

# Select the subscription where the reources should be deployed
Select-AzSubscription -Subscription $SubscriptionID


##############################
#      Deploy Step 1         #
##############################
$rgNameStep1 = "Step-1-Storage-Bicep-XYZ"
$location = "West Europe"

# Create a resource group for the deployment 
New-AzResourceGroup -Name $rgNameStep1 -Location $location

# Send the script to Azure and start a deployment in that resource group 
New-AzResourceGroupDeployment `
  -ResourceGroupName  $rgNameStep1 `
  -Name "Step-1-Bicep-Deployment" `
  -TemplateFile "./Step_1/main.bicep" `
  -location $location

##############################
#      Deploy Step 2         #
##############################
# Send the script to Azure and start a deployment in a subscription
# This deployment is scoped to a subscription because the script need to deploy a resources to two scopes
# First the resource group is a resource that need to be deployed to a subscription
# Second the resources need to be deployed to this newly created resource group
New-AzSubscriptionDeployment `
  -Name "Step-2-Bicep-Deployment" `
  -TemplateFile './Step_2/main.bicep' `
  -rlocation $location `
  -DeploymentDebugLogLevel All `
  -Location $location


##############################
#      Deploy Step 3         #
##############################
# 
New-AzSubscriptionDeployment `
  -Name "Step-3-Bicep-Deployment" `
  -TemplateFile './Step_3/main.bicep' `
  -rlocation $location `
  -DeploymentDebugLogLevel All `
  -Location $location

##############################
#      Deploy Step 4         #
##############################
New-AzSubscriptionDeployment `
  -Name "Step-4-Bicep-Deployment" `
  -TemplateFile './Step_4/main.bicep' `
  -rlocation $location `
  -DeploymentDebugLogLevel All `
  -Location $location

##############################
#      Deploy Step 5         #
##############################
# Will be deployed by a Azure DevOps Pipeline!


##############################
#      Deploy Step 6         #
##############################
# Finally we want to upload data from a directory to that storage acount. 
# This PS module has two funtions. 
# 1. Register a server to the AAD tenant as a secure origin
# 2. Upload data 
# Execute this step on your server that needs to be connected to our Azure storage solution.

cd c:\
git clone "https://e5testtenant@dev.azure.com/e5testtenant/BicepTutorial/_git/BicepTutorial"
mkdir "c:\Sync"
Import-Module c:\BicepTutorial\Step_6\SyncerModule.psm1
Start-SyncerSetup -SubscriptionID $SubscriptionID
New-SyncerRun `
-Directory "C:\sync\*" `
-Container "blobcontainer" `
-TenantID $TenantID `
-AppID $AppID `
-StorageAccountName "Step-1-Storage-Bicep-XYZ"