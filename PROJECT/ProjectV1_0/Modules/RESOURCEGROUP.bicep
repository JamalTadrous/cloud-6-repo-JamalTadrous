// ========== Resource Group & Storageaccounts =============================

targetScope = 'subscription'

param location string = 'westeurope'

var resourceGroupName = 'JamsProjectV1'

resource resoGroup 'Microsoft.Resources/resourceGroups@2021-04-01'= {
  name: resourceGroupName
  location: location
}

output resoGroup string = resoGroup.id
output resourceGroupName string = resoGroup.name
