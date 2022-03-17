//VNET2___WEBSERVER
targetScope = 'resourceGroup'

//______________________PARAMETERS___________________//

param location string = resourceGroup().location
param webvmName string = 'webserv'
param adminUsername2 string = 'jamaltadrous'
param adminPassword2 string = 'Techgr0und$'
// @allowed([
//   'sshPublicKey'
//   'sshPrivateKey'
// ])

// @secure()
// param sshPublicKey string = loadFileAsBase64('../misc/sshpk')
param customData string = loadFileAsBase64('../misc/webinstallscript.sh')

@description('Unique DNS Name for the Public IP used to access the Virtual Machine.')
param dnsLabelPrefix string = toLower('webservervm-${uniqueString(resourceGroup().id)}')

@description('The Ubuntu version for the VM.')
@allowed([
  '18.04-LTS'
])
param ubuntuOSVersion string = '18.04-LTS'
param vmSize string = 'Standard_B1s'
param dskEncrKey string

//______________________VARIABLES___________________//

//PIP
var publicIPAddressName = '${webvmName}PublicIP'
// var osDiskType = 'StandardSSD_LRS'

//NSG2
param nsgName string = 'webNSG'
// // param dskEncrKey string

@description('Name for vNet 2')
param vnet2Name string = 'app-prod-vnet'

var vnet2Config = {
  addressSpacePrefix: '10.20.20.0/24'
  subnetName: 'websubnet'
  subnetPrefix: '10.20.20.0/24'
}

resource vnet2 'Microsoft.Network/virtualNetworks@2020-05-01' = {
  name: vnet2Name
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnet2Config.addressSpacePrefix
      ]
    }
    // subnets: [
    //   {
    //     name: vnet2Config.subnetName
    //     properties: {
    //       addressPrefix: vnet2Config.subnetPrefix
    //     }
    //   }
    // ]
  }
}

resource websub2 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' = {
  name: vnet2Config.subnetName
  properties: {
    addressPrefix: vnet2Config.subnetPrefix
    networkSecurityGroup: {
      id: nsg2.id
    }
    serviceEndpoints: [
      { 
        service: 'Microsoft.KeyVault'
      }
      {  
        service: 'Microsoft.Storage'
      }
    ]
  }
  parent: vnet2
}


// //______________________RESOURCES___________________//


//NETWORK INTERFACE CONTROLLER
resource nic2 'Microsoft.Network/networkInterfaces@2020-06-01' = {
  name: 'webnic1'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig2'
        properties: {
          subnet: {
            id: websub2.id
          }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIP.id
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: nsg2.id
    }
  }
}



//NETWORK SECURITY GROUP
resource nsg2 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: nsgName
  location: location
  dependsOn: [
    
  ]
  properties: {
    securityRules: [
      {
        name: 'SSH'
        properties: {
          priority: 1000
          protocol: 'Tcp'
          access: 'Allow'
          direction: 'Inbound'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '22'
        }
      }
    ]
  }
}



//PUBLIC IP
resource publicIP 'Microsoft.Network/publicIPAddresses@2020-06-01' = {
  name: publicIPAddressName
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    publicIPAllocationMethod: 'Dynamic'
    publicIPAddressVersion: 'IPv4'
    dnsSettings: {
      domainNameLabel: dnsLabelPrefix
    }
    idleTimeoutInMinutes: 4
  }
}


//VM (LINUX)
resource webvm 'Microsoft.Compute/virtualMachines@2020-06-01' = {
  name: webvmName
  location: location
  // zones: [
  //   '2'
  // ]
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      osDisk: {
        name:  'webvmstorage'
        osType: 'Linux'
        caching: 'ReadWrite'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
          diskEncryptionSet: {
            id: dskEncrKey
          }
        }
      }
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: ubuntuOSVersion
        version: 'latest'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic2.id
        }
      ]
    }
    osProfile: {
      computerName: webvmName
      adminUsername: adminUsername2
      adminPassword: adminPassword2
      allowExtensionOperations: true
      customData: customData
      // linuxConfiguration: {
      //   disablePasswordAuthentication: true
      //   ssh: {
      //     publicKeys: [
      //       {
      //         keyData: loadFileAsBase64('../misc/sshpk.pub')
      //         path: '/home/${adminUsername}/.ssh/authorized_keys'
      //       }
      //     ]
      //   }
      // }
    }
  }
}


//______________________OUTPUTS___________________//

//OUTPUTS
output adminUsername1 string = adminUsername2
output hostname string = publicIP.properties.dnsSettings.fqdn
output sshCommand string = 'ssh ${adminUsername2}@${publicIP.properties.dnsSettings.fqdn}'
output webVmId string = webvm.id
output webDisk string = webvm.properties.storageProfile.osDisk.managedDisk.id
// output dskEncrKey string = dskEncrKey
output nsg2Id string = nsg2.id
output nic2Id string = nic2.id
// output sshPublicKey string = sshPublicKey
output vnet2 string = vnet2.id
output vnet2Name string = vnet2.name
output websubId2 string = websub2.id
output dskEncrKey string = dskEncrKey

// "tags": {
//   "projectv1": "jamaltadrous"
