
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


//MANAGEMENT VM

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






























//______________________PARAMETERS___________________//


param vmName2 string = 'webserv'
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




//WEBSERVER VM

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
