resource myFirstDeploymentScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'myFirstDeploymentScript'
  location: resourceGroup().location
  kind: 'AzurePowerShell'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '/subscriptions/01234567-89AB-CDEF-0123-456789ABCDEF/resourcegroups/deploymenttest/providers/Microsoft.ManagedIdentity/userAssignedIdentities/myscriptingid': {}
    }
  }
  properties: {
    azPowerShellVersion: '3.0'
    scriptContent: '''
      $output = 'Hello Learner!'
      Write-Output $output
      $DeploymentScriptOutputs = @{}
      $DeploymentScriptOutputs['text'] = $output
    '''
    retentionInterval: 'P1D' //, the results are removed after you run the script.
  }
}

output scriptResult string = myFirstDeploymentScript.properties.outputs.text


// Let's say you have a PowerShell file 
// named myscript.ps1 in the same folder as your Bicep template. 
// You can tell Bicep to embed the file like this:

// properties: {
//   azPowerShellVersion: '3.0'
//   scriptContent: loadTextContent('myscript.ps1')
//   retentionInterval: 'P1D'
// }
