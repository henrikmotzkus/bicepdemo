<#
  .SYNOPSIS
  This module performs a data sync to a storage account

  .DESCRIPTION
  This module syncs the content of a directory to a blob container (Storage Accont) in Azure.
  And it registeres a AAD app to a tenant with certificate based authentication

  .INPUTS

  .OUTPUTS

  .EXAMPLE
  Import-Module c:\BicepTutorial\Step_6\SyncerModule.psm1

  .EXAMPLE
  Start-SyncerSetup -SubscriptionID $SubscriptionID
  
  .EXAMPLE
  New-SyncerRun `
  -Directory "C:\sync\*" `
  -Container "blobcontainer" `
  -TenantID $TenantID `
  -AppID $AppID `
  -StorageAccountName "Step-1-Storage-Bicep-XYZ"

#>

# Setup of the local Server
# Installs Powershell module
# And sets up a certificate based authentication.
# certificated base authentication is use when processes on servers needs to be authenticated.
# Thsi steps needs two roles: Local Administrator on the server. And App admin in AAD.
function Start-SyncerSetup {
  param (
      [sring[]]$SubscriptionID
    )
  $PSVersionTable.PSVersion 
  # Install Storage Module locally
  try {
    $module = "Az.Storage"
    Get-InstalledModule -Name $module -AllVersions -OutVariable AzVersions -ErrorAction Stop
  }
  catch  [System.Exception] {
    Install-Module -Name $module -Repository PSGallery -Force
  }
  # Create a SP in AAD with certificate based authentication
  try {
    Connect-AzAccount
    #$SubscriptionID = "0548f072-39c5-4986-864d-14d0395af3b7"
    Select-AzSubscription -Subscription $SubscriptionID
    $cert = New-SelfSignedCertificate -CertStoreLocation "cert:\CurrentUser\My" `
    -Subject "CN=SyncherPSModule" `
    -KeySpec KeyExchange
    $keyValue = [System.Convert]::ToBase64String($cert.GetRawCertData())
    $sp = New-AzADServicePrincipal -DisplayName "SyncherPSModule" `
      -CertValue $keyValue `
      -EndDate $cert.NotAfter `
      -StartDate $cert.NotBefore

    Sleep 20
    
    #New-AzRoleAssignment -RoleDefinitionName "Storage Blob Data Owner" -ServicePrincipalName "3b067c64-bf1e-4a65-8481-74f9462d0309"
    New-AzRoleAssignment -RoleDefinitionName "Storage Blob Data Owner" -ServicePrincipalName $sp.AppId
  } catch {
    Write-Error -Message "could not setup SP ..."
  }
}

# Syncs the current directory to the blob container
function New-SyncerRun {
  param (
    [string]$Directory,
    [string]$Container,
    [string]$TenantID,
    [string]$AppID,
    [string]$StorageAccountName
  )
  try {
    $Thumbprint = (Get-ChildItem cert:\CurrentUser\My\ | Where-Object {$_.Subject -eq "CN=SyncherPSModule" }).Thumbprint
    Connect-AzAccount -ServicePrincipal `
      -CertificateThumbprint $Thumbprint `
      -ApplicationId $AppID `
      -TenantId $TenantId
  } catch {
    Write-Error -Message "could not connect ..."
    $_
  }
  try {
    $Context =  New-AzStorageContext -StorageAccountName $StorageAccountName
    $Items = Get-ChildItem -File -Path $Directory 
    foreach ($i in $items) {
      try {
          Get-AzStorageBlob -Container $Container -Blob $i.name -Context $Context -ErrorAction Stop
      } catch [Microsoft.WindowsAzure.Commands.Storage.Common.ResourceNotFoundException] {
          Set-AzStorageBlobContent -Container $Container -Context $Context -Blob $i.name -File $i
      }
    }
  }
  catch {
    Write-Error -Message "could not upload ..."
    $_
  }
}

Export-ModuleMember -Function New-SyncerRun
Export-ModuleMember -Function Start-SyncerSetup
