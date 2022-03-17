//___________________ main.bicep __________________________//


targetScope = 'subscription'


// ____________________PARAMETERS __________________________//

//RESOURCE GROUP
param location string = 'westeurope'
param resourceGroupName string = 'JamsProjectV1'


/////////////////////RESOURCES////////////////////////////


//__________________RESOURCE GROUP_________________________//


//RESOURCE GROUP
module rg './Modules/RESOURCEGROUP.bicep' = {
  name: resourceGroupName
  params: {
    location: location
  }
}



//___________________STORAGE ACCOUNT_______________________//

// STORAGE ACCOUNT
// DEPLOYMENT SCRIPT
module stg './Modules/STORAGEACCOUNT.bicep' = {
  name: 'jamalv1storageaccount'
  params: {
    storageAccountName: 'jamalv1storageaccount'
    location: location
  }
  dependsOn: [
    rg
  ]
  scope: resourceGroup('JamsProjectV1')
}



//____________________VIRTUAL MACHINES_____________________//
/////////////////////___ADMINSERVER___///////////////////////

param adminUsername1 string = 'jamaltadrous'
// @secure() 
param adminPassword1 string = 'Techgr0und$'

//______________________________________________________

//ADMINSERVER
module ADMINSERVER './Modules/ADMINSERVER.bicep' = {
  name: 'ADMINSERVER'
  scope: resourceGroup('JamsProjectV1')
  dependsOn: [
    stg
    rg
    // KEYVAULT
  ]
  params: {
    adminUsername1: adminUsername1
    adminPassword1: adminPassword1
    location: location

    // dskEncrKey: dskEncrKey
    // remoteVnetName: WEBSERVER.outputs.vnet2
    // subnetId1: VNETS.outputs.subnetId1
  }
}

////////////////////___WEBSERVER___///////////////////////


//VM credentials
param adminUsername2 string = 'jamaltadrous'

@description('Password for the Virtual Machine.')
// param sshPublicKey string = loadFileAsBase64('../misc/sshpk')
param adminPassword2 string = 'Techgr0und$'

//________________________________________________________

//WEBSERVER(Linux)
module WEBSERVER './Modules/WEBSERVER.bicep' = {
  name: 'WEBSERVER'
  scope: resourceGroup('JamsProjectV1')
  dependsOn:[
    stg
    rg
    
  ]
  params: {
    adminUsername2: adminUsername2
    adminPassword2: adminPassword2
    // sshPublicKey: sshPublicKey
    location: location
    dskEncrKey: KEYVAULT.outputs.dskEncrKey
    // subnetId2: VNETS.outputs.subnetId2
  }
}


//////////////////////___KeyVault___________________________//


//VAULT
//KEYS
//POLICIES
module KEYVAULT './Modules/KeyVault.bicep' = {
  name: 'projexkeyvault'
  dependsOn: [
    rg
    stg
  ]
  scope: resourceGroup('JamsProjectV1')
  params:{
    location: location
    // sub1: ADMINSERVER.outputs.admsubId1
  }
}




//____________________RECOVERY SERVICE VAULT_______________//







//_______________________NETWORK___________________________//
///////////"management_prd_vnet" & "app-prod-vnet"///////////

// module VNETS './VNETS.bicep' = {
//   name: 'VNETS'
//   scope: resourceGroup('JamsProjectV1')
//   dependsOn: [
//     stg
//     rg
    
//   ]
//   params: {
//     vnet1Name: 'WEBSERVER'
//     vnet2Name: 'ADMINSERVER'
//     location: location
//   }
// }




// output sshPublicKey string = sshPublicKey
