$templateFile = 'main.bicep'
$deploymentName = "jamalprojexv1"
$Location = 'westeurope'

New-AzSubscriptionDeployment `
-ResourceGroupName JamsProjectV1RG `
-Name $deploymentName `
-Location $Location `
-TemplateFile $templateFile

///////////////////////////////////////////////

$templateFile = 'main.bicep'
$today = Get-Date -Format 'MM-dd-yyyy'
$deploymentName = "sub-scope-$today"
$virtualNetworkName = 'management_prd_vnet'
$virtualNetworkAddressPrefix = '10.10.10.0/24'

New-AzSubscriptionDeployment `
  -Name $deploymentName `
  -Location westeurope `
  -TemplateFile $templateFile `
  -virtualNetworkName $virtualNetworkName `
  -virtualNetworkAddressPrefix $virtualNetworkAddressPrefix


// after deployment, use:

$fileUri = (Get-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -Name $deploymentName).Outputs.fileUri.Value
Invoke-RestMethod $fileUri

&
Get-AzDeploymentScriptLog -ResourceGroupName $resourceGroupName -Name CopyConfigScript

Remove-AzResourceGroup -Name $resourceGroupName

_________________ remove the policy resources + resourceGroup_____________________________

$subscriptionId = (Get-AzContext).Subscription.Id

Remove-AzPolicyAssignment -Name 'DenyFandGSeriesVMs' -Scope "/subscriptions/$subscriptionId"
Remove-AzPolicyDefinition -Name 'DenyFandGSeriesVMs' -SubscriptionId $subscriptionId
Remove-AzResourceGroup -Name ToyNetworking


_________________ remove resourceGroup_____________________________

Remove-AzResourceGroup -Name MyResourceGroup -Verbose

