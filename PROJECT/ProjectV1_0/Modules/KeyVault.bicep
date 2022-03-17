targetScope = 'resourceGroup'

param location string = resourceGroup().location
param enabledForDeployment bool = true
param enabledForTemplateDeployment bool = true
param enabledForDiskEncryption bool = true
param enableSoftDelete bool = true
param enablePurgeProtection bool = true
// param enableRbacAuthorization bool = false
param keyVaultName string = 'jamsKV2'
param tenantId string = subscription().tenantId
@description('Specifies the object ID of a user, service principal or security group in the Azure Active Directory tenant for the vault. The object ID must be unique for the list of access policies. Get it by using Get-AzADUser or Get-AzADServicePrincipal cmdlets.')
param objectId string = '214bb771-fd30-4f8e-9dfc-7195f7b165ff'

// param sub1 string



@description('Specifies whether the key vault is a standard vault or a premium vault.')
@allowed([
  'standard'
])
param skuName string = 'standard'

// param networkAcls object = {
//   ipRules: []
//   virtualNetworkRules: [
//     {
//       id: subscription().id
//     }
//   ]
// }


///////////////////////////////////////////////////////////////

resource keyvault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: keyVaultName
  location: location
  tags: {
    displayName: 'KeyVault'
  }
  properties: {
    enabledForDeployment: enabledForDeployment
    enabledForTemplateDeployment: enabledForTemplateDeployment
    enabledForDiskEncryption: enabledForDiskEncryption
    enableRbacAuthorization: false
    tenantId: tenantId
    enableSoftDelete: enableSoftDelete
    enablePurgeProtection: enablePurgeProtection
    softDeleteRetentionInDays: 7
    accessPolicies: [
      {
        objectId: objectId
        tenantId: tenantId
        permissions: {
          keys: [
            'all'
          ]
          secrets: [
            'all'
          ]
          certificates: [
            'all'
          ]
          storage: [
            'all'
          ]
        }
      }
    ]
    sku: {
      name: skuName
      family: 'A'
    }
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
      // virtualNetworkRules:[
      //   {
      //     id: sub1
      //   }
      // ]
    }
  }
}

resource mngId 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name:  'projectadmin'
  location: location
  dependsOn: [
    keyvault
  ]
}

// secret
resource secret 'Microsoft.KeyVault/vaults/secrets@2021-10-01' = {
  parent: keyvault
  name: 'ssh'
  properties: {
    value: loadTextContent('../misc/id_rsa.pub')
  }
}

// create key
resource RSAkey 'Microsoft.KeyVault/vaults/keys@2021-10-01' = {
  name: 'RSAKey'
  parent: keyvault
  properties: {
    kty: 'RSA' // key type
    keySize: 4096
    keyOps: [
      // key operations
      'encrypt'
      'decrypt'
      'sign'
      'unwrapKey'
      'verify'
      'wrapKey'
    ]
    attributes:{
      enabled: true
    }
  }
}


resource dskEncrKey 'Microsoft.Compute/diskEncryptionSets@2021-08-01' = {
  name: 'dskEncrKeyV1'
  location: location
  // tags:tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    rotationToLatestKeyVersionEnabled:true
    activeKey: {
      keyUrl: RSAkey.properties.keyUriWithVersion
      sourceVault: {
        id: keyvault.id
      }
    }
    encryptionType: 'EncryptionAtRestWithCustomerKey'
  }
}
resource kvPolicy 'Microsoft.KeyVault/vaults/accessPolicies@2021-10-01'= {
  name: 'add'
  parent: keyvault
  properties:{
    accessPolicies:[
      {
        tenantId: tenantId
        objectId: dskEncrKey.identity.principalId
        permissions:{
          keys:[
            'all'
          ]
          storage:[
            'all'
          ]
        }
        
      }
      {
        tenantId: tenantId
        objectId: mngId.properties.principalId
        permissions: {
          keys: [
            'all'
          ]
          secrets: [
            'all'
          ]
          certificates: [
            'all'
          ]
          storage: [
            'all'
          ]
        }    
      }
    ]
  }
}

output keyvaultId string = keyvault.id
output proxyKey object = RSAkey
output objectId string = objectId
output dskEncrKey string = dskEncrKey.id


