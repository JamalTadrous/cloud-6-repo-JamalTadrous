// ========== storage.bicep ==========

targetScope = 'resourceGroup'



//////////////STORAGE ACCOUNT //////////

//PARAMETERS
param storageAccountName string = 'jamalv1storageaccount'
param location string = resourceGroup().location

//RESOURCE
resource stg 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Cool'
  }
}

//////////////CONTAINER////////////////////////////////

//PARAMETERS
param containerName string = 'logs'

//RESOURCE
resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2019-06-01' = {
  name: '${stg.name}/default/${containerName}'
  
}






// //////////////DISC + DISCENCRYPTIONSET//////////////
// resource disc 'Microsoft.Compute/disks@2021-08-01' = {
//   name: '${stg.name}'
//   location: location
//   properties: {
//     creationData: {
//       createOption: 'Empty'
//     }
//     diskSizeGB: 1024
//     networkAccessPolicy: 'AllowAll'
//   }
//   resourceId: 
// }


// resource discencryptionset 'Microsoft.Compute/diskEncryptionSets@2021-08-01' = {
//   name: 'encryption${stg.name}'
//   location: location
//   properties: {
//     encryptionType: 'EncryptionAtRestWithCustomerKey'
//   }
//   dependsOn: [
//     disc
//   ]
// }


// output disc string = disc.id
// output discencryptionset string = discencryptionset.id


















/////////////DEPLOYMENT SCRIPT/////////////////////////

// //PARAMETERS
// param scriptToExecute string = 'date' // will print current date & time on container
// param subId string = subscription().id // defaults to current sub
// // param rgName string = resourceGroup().name // defaults to current rg
// // param uamiName string = 'projexadmin'

// param currentTime string = utcNow()

// //VARIABLES
// var uamiId = uniqueString(subId, 'Microsoft.ManagedIdentity/userAssignedIdentities')

// //RESOURCE
// resource dScript 'Microsoft.Resources/deploymentScripts@2019-10-01-preview' = {
//   name: 'scriptWithStorage'
//   location: location
//   kind: 'AzureCLI'
//   identity: {
//     type: 'UserAssigned'
//     userAssignedIdentities: {
//       '${uamiId}': {}
//     }
//   }
//   properties: {
//     azCliVersion: '2.0.80'
//     storageAccountSettings: {
//       storageAccountName: stg.name
//       storageAccountKey: stg.listKeys().keys[0].value
//     }
//     scriptContent: scriptToExecute
//     cleanupPreference: 'OnSuccess'
//     retentionInterval: 'P1D'
//     forceUpdateTag: currentTime // ensures script will run every time
//   }
// }


// //OUTPUTS
// // print logs from script after template is finished deploying
// output scriptLogs string = reference('${dScript.id}/logs/default', dScript.apiVersion, 'Full').properties.log


