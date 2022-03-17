module networkModule 'modules/network.bicep' = {
  scope: resourceGroup('f0750bbe-ea75-4ae5-b24d-a92ca601da2c','ToyNetworking')
  name: 'networkModule'
}

resource networkInterface 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: 'production-nic'
  location: resourceGroup().location
  properties: {
    ipConfigurations: [
      {
        name: 'toy-subnet-ip-configuration'
        properties: {
          subnet: {
            id: networkModule.outputs.subnetResourceId
          }
        }
      }
    ]
  }
}
