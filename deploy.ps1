# Change this for your web app name and resource group
$AppName = 'my-foundry-app'
$ResourceGroupName = 'my-resource-group'

New-AzResourceGroup $ResourceGroupName -Location 'West Europe'

$DeployParams = @{
    Name                     = "$AppName-Deployment"
    ResourceGroupName        = $ResourceGroupName
    TemplateFile             = '.\foundry.bicep'
    Mode                     = 'Complete' # This deletes everything else in the resource group!
    Force                    = $true
    Confirm                  = $false
    ErrorAction              = 'Stop'
    Verbose                  = $true
    appName                  = $AppName
    dockerComposeFileContent = (Get-Content '.\docker-compose.yml' -Raw) -replace '<hostname>',"$AppName.azurewebsites.net"
}

$Deployment = New-AzResourceGroupDeployment @DeployParams
$Deployment