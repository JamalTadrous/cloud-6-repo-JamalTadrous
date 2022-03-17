targetScope = 'resourceGroup'

param location string = 'westeurope'


// ------------------------------VNET 1-------------------------------

@description('Name for vNet 1')
param vnet1Name string = 'management-prd-vnet'

resource VnetPeering1 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-05-01' = {
  dependsOn: [
    management_prd_vnet
  ]
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

// -------------------------------VNET 2--------------------------------
@description('Name for vNet 2')
param vnet2Name string = 'app-prod-vnet'

resource vnetPeering2 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-05-01' = {
  dependsOn: [
    app-prod-vnet
  ]
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

