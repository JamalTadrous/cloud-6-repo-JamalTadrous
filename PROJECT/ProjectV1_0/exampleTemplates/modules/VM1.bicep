resource hostVm 'Microsoft.Compute/virtualMachines@2019-03-01' = {
  name: HostVirtualMachineName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: HostVirtualMachineSize
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2016-Datacenter'
        version: 'latest'
      }
      osDisk: {
        name: '${HostVirtualMachineName}OsDisk'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
        caching: 'ReadWrite'
      }
      dataDisks: [
        {
          lun: 0
          name: '${HostVirtualMachineName}DataDisk1'
          createOption: 'Empty'
          diskSizeGB: 1024
          caching: 'ReadOnly'
          managedDisk: {
            storageAccountType: 'Premium_LRS'
          }
        }
      ]
    }
    osProfile: {
      computerName: HostVirtualMachineName
      adminUsername: HostAdminUsername
      adminPassword: HostAdminPassword
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: createNic1.outputs.nicId
          properties: {
            primary: true
          }
        }
        {
          id: createNic2.outputs.nicId
          properties: {
            primary: false
          }
        }
      ]
    }
  }
}

resource vmExtension 'Microsoft.Compute/virtualMachines/extensions@2019-03-01' = {
  name: '${hostVm.name}/InstallWindowsFeatures'
  location: location
  properties: {
    publisher: 'Microsoft.Powershell'
    type: 'DSC'
    typeHandlerVersion: '2.77'
    autoUpgradeMinorVersion: true
    settings: {
      wmfVersion: 'latest'
      configuration: {
        url: DSCInstallWindowsFeaturesUri
        script: 'DSCInstallWindowsFeatures.ps1'
        function: 'InstallWindowsFeatures'
      }
    }
  }
}

resource hostVmSetupExtension 'Microsoft.Compute/virtualMachines/extensions@2019-03-01' = {
  name: '${hostVm.name}/HVHOSTSetup'
  location: location
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.9'
    autoUpgradeMinorVersion: true
    settings: {
      fileUris: [
        HVHostSetupScriptUri
      ]
      commandToExecute: 'powershell -ExecutionPolicy Unrestricted -File HVHostSetup.ps1 -NIC1IPAddress ${createNic1.outputs.assignedIp} -NIC2IPAddress ${createNic2.outputs.assignedIp} -GhostedSubnetPrefix ${ghostedSubnetPrefix} -VirtualNetworkPrefix ${virtualNetworkAddressPrefix}'
    }
  }
}
