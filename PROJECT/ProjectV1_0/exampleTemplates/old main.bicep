//___________________ main.bicep __________________________//


targetScope = 'subscription'
@minLength(6)
@maxLength(24)

//____________________PARAMETERS __________________________//

//RESOURCE GROUP
param location string = 'westeurope'
param resourceGroupName string = 'JamsProjectV1RG'

//VIRTUAL NETWORK
// Username & Password for the Virtual Machine.
param adminUsername string
@secure()
param adminPassword string
param dskEncrKey string
// param clientVar object
// param subId1 string
// param subId2 string

//___________________ VARIABLES __________________________//

// var resourceGroupName = 'JamsProjectV1RG'

var vNet1Name = 'management-prd-vnet1'
var vNet2Name = 'app-prd-vnet2'


/////////////////////RESOURCES////////////////////////////


//__________________RESOURCE GROUP_________________________//


//RESOURCE GROUP
module rg './resourcegroup.bicep' = {
  name: resourceGroupName
  params: {
    location: location
  }
}


// STORAGE ACCOUNT - MAIN
//___________________STORAGE ACCOUNT_______________________//
module stg './storageAccount.bicep' = {
  name: 'jamalv1storageaccount'
  params: {
    storageAccountName: 'jamalv1storageaccount'
    location: location
  }
  dependsOn: [
    rg
  ]
  scope: resourceGroup('JamsProjectV1RG')
}

//____________________KeyVault___________________________//

module keyVault 'KeyVault.bicep' = {
  name: 'projexkeyvault'
  dependsOn: [
    rg
    stg

  ]
  scope: resourceGroup('JamsProjectV1RG')
  params:{
    location: location
    secretValue: 'yourValue'
    secretName: 'yourSecret'
    // clientVar: clientVar
    // subId1: subId1
    // subId2: subId2
  }
}




//_______________________NETWORK___________________________//

//________________"management_prd_vnet"____________________//

// STORAGE ACCOUNT1 
// PUBLIC IP1
// NETWORK SECURITY GROUP1
// VNET1
// SUBNET1
// NETWORK INTERFACE CONTROLLER1
// VM1 (WINDOWS)

module vNet1 './NETWORKMOD.bicep' = {
  name: vNet1Name
  scope: resourceGroup('JamsProjectV1RG')
  dependsOn: [
    stg
    rg
    
  ]
  params: {
  adminUsername1: adminUsername
  adminPassword1: adminPassword
  adminUsername2: adminUsername
  adminPasswordOrKey: adminPassword
  location: location
  }
}


//____________________"app-prod-vnet"__________________//


// STORAGE ACCOUNT2 
// PUBLIC IP2
// NETWORK SECURITY GROUP2
// VNET2
// SUBNET2
// NETWORK INTERFACE CONTROLLER2
// VM2 (LINUX)

module WEBSERVER 'WEBSERVER.bicep' = {
  name: vNet2Name
  scope: resourceGroup('JamsProjectV1RG')
  dependsOn:[
    stg
    rg
    vNet1
  ]
  params: {
    adminUsername: adminUsername
    adminPasswordOrKey: dskEncrKey
    location: location
    dskEncrKey: dskEncrKey
  }
}




//____________________RECOVERY SERVICE VAULT_______________//



//----------------------DEPLOYMENT SCRIPTS----------------------//

