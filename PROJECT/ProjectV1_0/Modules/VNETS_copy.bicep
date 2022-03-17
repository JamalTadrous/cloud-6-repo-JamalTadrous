@description('Location of the resources')
param location string = resourceGroup().location

@description('Name for vNet 1')
param vnet1Name string = 'app-prod-vnet'

@description('Name for vNet 2')
param vnet2Name string = 'management-prd-vnet'

var vnet1Config = {
  addressSpacePrefix: '10.10.10.0/24'
  subnetName: 'admsub1'
  subnetPrefix: '10.10.10.0/24'
}
var vnet2Config = {
  addressSpacePrefix: '10.20.20.0/24'
  subnetName: 'websub1'
  subnetPrefix: '10.20.20.0/24'
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
    subnets: [
      {
        name: vnet1Config.subnetName
        properties: {
          addressPrefix: vnet1Config.subnetPrefix
          networkSecurityGroup: {
            properties: {
              securityRules: [
                {
                  properties: {
                    direction: 'Inbound'
                    protocol: '*'
                    access: 'Allow'
                  }
                }
                {
                  properties: {
                    direction: 'Outbound'
                    protocol: '*'
                    access: 'Allow'
                  }
                }
              ]
            }
          }
        }
      }
    ]
  }
}

resource VnetPeering1 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-05-01' = {
  parent: vnet1
  name: '${vnet1Name}-${vnet2Name}'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: false
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: vnet2.id
    }
  }
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
    subnets: [
      {
        name: vnet2Config.subnetName
        properties: {
          addressPrefix: vnet2Config.subnetPrefix
          networkSecurityGroup: {
            properties: {
              securityRules: [
                {
                  properties: {
                    direction: 'Inbound'
                    protocol: '*'
                    access: 'Allow'
                  }
                }
                {
                  properties: {
                    direction: 'Outbound'
                    protocol: '*'
                    access: 'Allow'
                  }
                }
              ]
            }
          }
        }
      }
    ]
  }
}

resource vnetPeering2 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-05-01' = {
  parent: vnet2
  name: '${vnet2Name}-${vnet1Name}'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: false
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: vnet1.id
    }
  }
}




////////////////////////////////////////////////////////////////////////////////////////////////

// @description('Location of the resources')
// param location string = resourceGroup().location

// @description('Name for vNet 1')
// param vnet1Name string = 'app-prod-vnet'

// @description('Name for vNet 2')
// param vnet2Name string = 'management-prd-vnet'

// var vnet1Config = {
//   addressSpacePrefix: '10.10.10.0/24'
//   subnetName: 'admsubnet'
//   // subnetPrefix: '10.10.10.0/24'
// }
// var vnet2Config = {
//   addressSpacePrefix: '10.20.20.0/24'
//   subnetName: 'websubnet'
//   // subnetPrefix: '10.20.20.0/24'
// }

// resource vnet1 'Microsoft.Network/virtualNetworks@2020-05-01' = {
//   name: vnet1Name
//   location: location
//   properties: {
//     addressSpace: {
//       addressPrefixes: [
//         vnet1Config.addressSpacePrefix
//       ]
//     }
//     // subnets: [
//     //   {
//     //     name: vnet1Config
//     //     properties: {
//     //       addressPrefix: vnet1Config
//     //     }
//     //   }
//     // ]
//   }
// }

// resource subnet1 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' = {
//   name: vnet1Config.subnetName
//   properties: {
//     addressPrefix: vnet1Config.addressSpacePrefix
//   }
//   parent: vnet1
// }


// resource vnet2 'Microsoft.Network/virtualNetworks@2020-05-01' = {
//   name: vnet2Name
//   location: location
//   properties: {
//     addressSpace: {
//       addressPrefixes: [
//         vnet2Config.addressSpacePrefix
//       ]
//     }
//     // subnets: [
//     //   {
//     //     name: vnet2Config.subnetName
//     //     properties: {
//     //       addressPrefix: vnet2Config.subnetPrefix
//     //     }
//     //   }
//     // ]
//   }
// }

// resource subnet2 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' = {
//   name: vnet2Config.subnetName
//   properties: {
//     addressPrefix: vnet2Config.addressSpacePrefix
//   }
//   parent: vnet2
// }



// resource VnetPeering1 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-05-01' = {
//   parent: vnet1
//   name: '${vnet1Name}-${vnet2Name}'
//   properties: {
//     allowVirtualNetworkAccess: true
//     allowForwardedTraffic: false
//     allowGatewayTransit: false
//     useRemoteGateways: false
//     remoteVirtualNetwork: {
//       id: vnet2.id
//     }
//   }
// }
// resource vnetPeering2 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-05-01' = {
//   parent: vnet2
//   name: '${vnet2Name}-${vnet1Name}'
//   properties: {
//     allowVirtualNetworkAccess: true
//     allowForwardedTraffic: false
//     allowGatewayTransit: false
//     useRemoteGateways: false
//     remoteVirtualNetwork: {
//       id: vnet1.id
//     }
//   }
// }

output vnet1id string = vnet1.id
output vnet2id string = vnet2.id
output subnetId1 string = '${vnet1.id}/subnets/subnet1'
output subnetId2 string = '${vnet2.id}/subnets/subnet2'
