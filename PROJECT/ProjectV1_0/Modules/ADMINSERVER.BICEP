targetScope = 'resourceGroup'

////////////////////PARAMETERS//////////////////
param adminvmName string = 'adminserv'
param adminUsername1 string

@description('Password for the Virtual Machine.')
@minLength(6)
@secure()
param adminPassword1 string


@description('The Windows version for the VM. This will pick a fully patched image of this given Windows version.')
@allowed([
  '2019-Datacenter'
])

param OSVersion string = '2019-Datacenter'
param vmSize1 string = 'Standard_B1s'
param location string = resourceGroup().location
param dnsLabelPrefix1 string = toLower('adminManage-vm-${uniqueString(resourceGroup().id)}')

// param subnetId1 string

// param dskEncrKey string

////////////////////RESOURCES/////////////////////
// WITH THEIR VARIABLES CLOSE TO THEM
@description('Name for vNet 1')
param vnet1Name string = 'management-prd-vnet'

var vnet1Config = {
  addressSpacePrefix: '10.10.10.0/24'
  subnetName: 'admsubnet'
  subnetPrefix: '10.10.10.0/24'
}


resource vnet1 'Microsoft.Network/virtualNetworks@2020-05-01' = {
  name: vnet1Name
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnet1Config.addressSpacePrefix
      ]
    }
    // subnets: [
    //   {
    //     name: vnet1Config
    //     properties: {
    //       addressPrefix: vnet1Config
    //     }
    //   }
    // ]
  }
}

resource admsub1 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' = {
  name: vnet1Config.subnetName
  properties: {
    addressPrefix: vnet1Config.subnetPrefix
    networkSecurityGroup: {
      id: nsg1.id
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
  parent: vnet1
}

// NETWORK INTERFACE CONTROLLER
param nicName1 string = 'adminnic'


resource nic1 'Microsoft.Network/networkInterfaces@2021-02-01' = {
  name: nicName1
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIP.id
          }
          subnet: {
            id: admsub1.id
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: nsg1.id
    }
  }
}


//NETWORK SECURITY GROUP
var nsgName = 'adminNSG'

resource nsg1 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: nsgName
  location: location
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
var publicIPAddressName = 'AdminPublicIP'

resource publicIP 'Microsoft.Network/publicIPAddresses@2020-06-01' = {
  name: publicIPAddressName
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
    dnsSettings: {
      domainNameLabel: dnsLabelPrefix1
    }
    idleTimeoutInMinutes: 4
  }
}


// VM (WINDOWS)
resource admVm 'Microsoft.Compute/virtualMachines@2021-03-01' = {
  name: adminvmName
  location: location
  // zones: [
  //   '1'
  // ]
  properties: {
    hardwareProfile: {
      vmSize: vmSize1
    }
    osProfile: {
      computerName: adminvmName
      adminUsername: adminUsername1
      adminPassword: adminPassword1
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: OSVersion
        version: 'latest'
      }
      osDisk: {
        name:'adminvmstorage'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
          // diskEncryptionSet: {
          //   id: dskEncrKey
          // }
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic1.id
        }
      ]
    }
    // diagnosticsProfile: {
    //   bootDiagnostics: {
    //     enabled: true
    //     storageUri: stg.properties.primaryEndpoints.blob
    //   }
    // }
  }
}

output admVmId string = admVm.id
output admVmName string = admVm.name
output hostname string = publicIP.properties.dnsSettings.fqdn
output nic1 string = nic1.id
output nsg1 string = nsg1.id
output vnet1Name string = vnet1.name
output admsubId1 string = admsub1.id

// converted from: https://github.com/Azure/azure-quickstart-templates/tree/master/201-existing-vnet-to-vnet-peering

// param remoteVnetName string 


// resource peer 'microsoft.network/virtualNetworks/virtualNetworkPeerings@2020-05-01' = {
//   name: '${vnet1.name}/peering-to-remote-vnet'
//   properties: {
//     allowVirtualNetworkAccess: true
//     allowForwardedTraffic: false
//     allowGatewayTransit: false
//     useRemoteGateways: false
//     remoteVirtualNetwork: {
//       id: resourceId('Microsoft.Network/virtualNetworks', remoteVnetName)
//     }
//   }
// }



