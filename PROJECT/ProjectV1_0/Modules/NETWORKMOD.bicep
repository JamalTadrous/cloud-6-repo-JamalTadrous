//NETWORK

//____________________PARAMETERS___________________//

@description('Username for the Virtual Machine.')
param adminUsername1 string

@description('Password for the Virtual Machine.')
@minLength(6)
@maxLength(24)
@secure()
param adminPassword1 string

@description('Unique DNS Name for the Public IP used to access the Virtual Machine.')
param dnsLabelPrefix1 string = toLower('${vmName1}-${uniqueString(resourceGroup().id, vmName1)}')

@description('Name for the Public IP used to access the Virtual Machine.')
param publicIpName string = 'myPublicIP'

@description('Allocation method for the Public IP used to access the Virtual Machine.')
@allowed([
  'Dynamic'
  'Static'
])
param publicIPAllocationMethod string = 'Dynamic'

@description('SKU for the Public IP used to access the Virtual Machine.')
@allowed([
  'Basic'
  'Standard'
])
param publicIpSku string = 'Basic'

@description('The Windows version for the VM. This will pick a fully patched image of this given Windows version.')
@allowed([
  '2019-Datacenter'

])
param OSVersion string = '2019-Datacenter'

@description('Size of the virtual machine.')
param vmSize1 string = 'Standard_B1s'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Name of the virtual machine.')
param vmName1 string = 'adminManage-vm'



//____________________VARIABLES_____________________//


//STORAGE ACCOUNT
var storageAccountName = 'jamalsmngmntstorage'

//NIC1
var nicName1 = 'myVMNic'

//VNET1
var addressPrefix1 = '10.10.10.0/24'
var virtualNetworkName1 = 'management-prd-vnet1'

//SUBNET1
var subnetName1 = 'mngmntsub1'
var subnetPrefix1 = '10.10.10.0/24'

//NSG1
var networkSecurityGroupName1 = 'default-NSG'

//VNET1 & VNET2
var vNet1Name = 'management-prd-vnet1'
var vNet2Name = 'app-prd-vnet2'


//____________________RESOURCES___VNET1__________________//
// STORAGE ACCOUNT 
// PUBLIC IP
// NETWORK SECURITY GROUP
// VNET
// SUBNET
// NETWORK INTERFACE CONTROLLER
// VM (WINDOWS)



//STORAGE ACCOUNT 
resource stg 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'Storage'
  
}


// PUBLIC IP
resource pip 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
  name: publicIpName
  location: location
  sku: {
    name: publicIpSku
  }
  properties: {
    publicIPAllocationMethod: publicIPAllocationMethod
    dnsSettings: {
      domainNameLabel: dnsLabelPrefix1
    }
  }
}


// NETWORK SECURITY GROUP
resource securityGroup 'Microsoft.Network/networkSecurityGroups@2021-02-01' = {
  name: networkSecurityGroupName1
  location: location
  properties: {
    securityRules: [
      {
        name: 'default-allow-3389'
        properties: {
          priority: 1000
          access: 'Allow'
          direction: 'Inbound'
          destinationPortRange: '3389'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}


// VNET
resource VNET1 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: virtualNetworkName1
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix1
      ]
    }
  }
}


// SUBNET
resource SUBNET1 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' = {
  parent: VNET1
  name: subnetName1
  properties: {
    addressPrefix: subnetPrefix1
    networkSecurityGroup: {
      id: securityGroup.id
    }
  }
}


// NETWORK INTERFACE CONTROLLER
resource NIC1 'Microsoft.Network/networkInterfaces@2021-02-01' = {
  name: nicName1
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: pip.id
          }
          subnet: {
            id: SUBNET1.id
          }
        }
      }
    ]
  }
}


// VM (WINDOWS)
resource VM1 'Microsoft.Compute/virtualMachines@2021-03-01' = {
  name: vmName1
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize1
    }
    osProfile: {
      computerName: vmName1
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
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
      }
      dataDisks: [
        {
          diskSizeGB: 1023
          lun: 0
          createOption: 'Empty'
        }
      ]
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: NIC1.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
        storageUri: stg.properties.primaryEndpoints.blob
      }
    }
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



//VNET2___WEBSERVER


//______________________PARAMETERS___________________//

@description('The name of you Virtual Machine.')
param vmName2 string = 'webserv'

@description('Username for the Virtual Machine.')
param adminUsername2 string

@description('Type of authentication to use on the Virtual Machine. SSH key is recommended.')
@allowed([
  'sshPublicKey'
  'password'
])
param authenticationType string = 'password'

@description('SSH Key or password for the Virtual Machine. SSH key is recommended.')
@secure()
param adminPasswordOrKey string

@description('Unique DNS Name for the Public IP used to access the Virtual Machine.')
param dnsLabelPrefix string = toLower('simplelinuxvm-${uniqueString(resourceGroup().id)}')

@description('The Ubuntu version for the VM. This will pick a fully patched image of this given Ubuntu version.')
@allowed([
  '18.04-LTS'
])
param ubuntuOSVersion string = '18.04-LTS'

@description('The size of the VM')
param vmSize2 string = 'Standard_B1s'


// @description('Name of the subnet in the virtual network')
// param subnetName2 string = 'Subnet'

// @description('Name of the Network Security Group')
// param nsgName string = 'webNSG'




//______________________VARIABLES___________________//

//PIP
var publicIPAddressName = '${vmName2}PublicIP'
var osDiskType = 'Standard_LRS'
var linuxConfiguration = {
  disablePasswordAuthentication: true
  ssh: {
    publicKeys: [
      {
        path: '/home/${adminUsername2}/.ssh/authorized_keys'
        keyData: adminPasswordOrKey
      }
    ]
  }
}

// //STORAGE ACCOUNT
// var storageAccountName = 'jamalswebstorage'

//NIC2
var nicName = 'webnic1'

//VNET2
var addressPrefix2 = '10.20.20.0/24'
var virtualNetworkName2 = 'app-prd-vnet2'

//SUBNET2
var subnetName2 = 'websub1'
var subnetPrefix2 = '10.20.20.0/24'

//NSG2
var nsgName = 'webNSG'


//______________________RESOURCES___________________//



// STORAGE ACCOUNT 
// resource stg 'Microsoft.Storage/storageAccounts@2021-04-01' = {
//   name: storageAccountName
//   location: location
//   sku: {
//     name: 'Standard_LRS'
//   }
//   kind: 'Storage'
// }


//NETWORK SECURITY GROUP
resource NSG2 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
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




// VNET
resource VNET2 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: virtualNetworkName2
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix2
      ]
    }
  }
}


// SUBNET
resource SUBNET2 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' = {
  parent: VNET2
  name: subnetName2
  properties: {
    addressPrefix: subnetPrefix2
    networkSecurityGroup: {
      id: NSG2.id
    }
  }
}


//NETWORK INTERFACE CONTROLLER
resource NIC2 'Microsoft.Network/networkInterfaces@2020-06-01' = {
  name: nicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig2'
        properties: {
          subnet: {
            id: SUBNET2.id
          }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIP.id
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: NSG2.id
    }
  }
}

//VM (LINUX)
resource VM2 'Microsoft.Compute/virtualMachines@2020-06-01' = {
  name: vmName2
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize2
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: osDiskType
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
          id: NIC2.id
        }
      ]
    }
    osProfile: {
      computerName: vmName2
      adminUsername: adminUsername2
      adminPassword: adminPasswordOrKey
      linuxConfiguration: ((authenticationType == 'password') ? null : linuxConfiguration)
    }
  }
}



//______________________OUTPUTS___________________//

//OUTPUTS
output adminUsername string = adminUsername2
output hostname string = publicIP.properties.dnsSettings.fqdn
output sshCommand string = 'ssh ${adminUsername2}@${publicIP.properties.dnsSettings.fqdn}'
















//_____________________VIRTUAL NETWORK PEERING_______________//


//VNET PEERING

resource VnetPeering1 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-05-01' = {
  parent: VNET1
  name: '${vNet1Name}-${vNet2Name}'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: false
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: VNET2.id
    }
  }
}

resource vnetPeering2 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-05-01' = {
  parent: VNET2
  name: '${vNet2Name}-${vNet1Name}'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: false
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: VNET1.id
    }
  }
}










