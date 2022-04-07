//////////RECOVERY MODULE

///////////////////////___PARAMETERS__///////////////////////////
param RecoveryVaultName string = 'RecoVault'
param BackupPolicyName string = 'BackupPolicy'
param location string = resourceGroup().location

//VARIABLES
var backupFabric = 'Azure'
var protectionContainer = 'iaasvmcontainer;iaasvmcontainerv2;${resourceGroup().name};${admVm.name}'
var protectedItem = 'vm;iaasvmcontainerv2;${resourceGroup().name};${admVm.name}'
var protectionContainer2 = 'iaasvmcontainer;iaasvmcontainerv2;${resourceGroup().name};${WebVMss.name}'
var protectedItem2 = 'vm;iaasvmcontainerv2;${resourceGroup().name};${WebVMss.name}'


/////////////////////__EXISTING RESOURCE__//////////////////////////

resource mngId 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
  name:  'ZenTIAadmin'
}

resource admVm 'Microsoft.Compute/virtualMachines@2021-03-01' existing = {
  name: 'adminserv'
}
resource WebVMss 'Microsoft.Compute/virtualMachineScaleSets@2021-11-01' existing = {
  name: 'WebVMss'
}

////////////////////////////////////////////////////////////////////
////////______________________RESOURCES_________________________////
////////////////////////////////////////////////////////////////////

//RECOVERYVAULT
resource recoveryVault 'Microsoft.RecoveryServices/vaults@2020-10-01' = {
  name: RecoveryVaultName
  location: location
  sku: {
    name: 'RS0'
    tier: 'Standard'
  }
  identity:{
    type: 'UserAssigned'
    userAssignedIdentities:{
      '${mngId.id}' : {}
    }
  }
  tags: {
    'ZenTIA': 'jamaltadrous'
  }
}

//BACKUP_POLICY
resource backupPolicy 'Microsoft.RecoveryServices/vaults/backupPolicies@2016-06-01' = {
  parent: recoveryVault
  name: BackupPolicyName
  location: location
  properties: {
    backupManagementType: 'AzureIaasVM'
    schedulePolicy: {
      scheduleRunFrequency: 'Daily'
      schedulePolicyType: 'SimpleSchedulePolicy'
      scheduleRunTimes: [
        '2022-03-10T00:30:00Z'
      ]
      scheduleWeeklyFrequency: 0
    }
    retentionPolicy: {
      retentionPolicyType: 'LongTermRetentionPolicy'
      dailySchedule: {
        retentionTimes: [
          '2022-03-17T00:30:00.000Z'
        ]
        retentionDuration: {
          count: 7
          durationType: 'Days'
        }
      }
    }
    // instantRpRetentionRangeInDays: 3
    // timeZone: 'W. Europe Standard Time'
  }
  // tags: {
  //   'projectv1': 'jamaltadrous'
  // }
}


//BACKUP FOR ADMIN
resource backupAdmin 'Microsoft.RecoveryServices/vaults/backupFabrics/protectionContainers/protectedItems@2021-12-01' = {
  name: '${recoveryVault.name}/${backupFabric}/${protectionContainer}/${protectedItem}'
  tags: {
    'ZenTIA': 'jamaltadrous'
  }
  properties: {
    protectedItemType: 'Microsoft.Compute/virtualMachines'
    policyId: backupPolicy.id
    sourceResourceId: admVm.id
  }
  dependsOn:[
  backupWeb
  ]
} 

//BACKUP FOR WEBSERVER
resource backupWeb 'Microsoft.RecoveryServices/vaults/backupFabrics/protectionContainers/protectedItems@2021-12-01' = {
  name: '${RecoveryVaultName}/${backupFabric}/${protectionContainer2}/${protectedItem2}'
  tags: {
    'ZenTIA': 'jamaltadrous'
  }
  properties: {
    protectedItemType: 'Microsoft.Compute/virtualMachines'
    policyId: backupPolicy.id
    sourceResourceId: WebVMss.id
  }
}

