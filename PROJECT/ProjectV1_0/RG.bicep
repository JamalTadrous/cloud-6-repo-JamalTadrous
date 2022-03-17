param location string = 'West Europe'

resource resourcegroup = 'M


@minLength(1)
@maxLength(24)
param storageAccountName string = 'jamalsprojectstorage'

resource ProjectStorage 'Microsoft.Storage/storageAccounts@2018-03-01-preview' = {
  dependsOn: [
    keyvault
  ]
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}
