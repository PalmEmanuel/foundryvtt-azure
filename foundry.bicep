@secure()
@description('The password to the admin view of FoundryVTT')
param adminKey string
@description('The username of the FoundryVTT account for license retrieval')
param foundryUsername string
@secure()
@description('The password of the FoundryVTT account for license retrieval')
param foundryPassword string

@description('The name of the web app')
param appName string
@description('The hostname of FoundryVTT, defaults to app name')
param hostname string = '${appName}.azurewebsites.net'
@description('The location of the web app')
param location string = resourceGroup().location
@description('The content of the docker compose file')
param dockerComposeFileContent string

@allowed([
  'S1'
  'P1v2'
])
@description('The sku of the app service plan')
param appPlanSku string = 'S1'

resource appPlan 'Microsoft.Web/serverfarms@2021-02-01' = {
  name: '${appName}-plan'
  location: location
  kind: 'linux'
  sku: {
    name: appPlanSku
  }
  properties: {
    reserved: true
  }
}

resource webApp 'Microsoft.Web/sites@2021-02-01' = {
  name: appName
  location: location
  kind: 'app,linux,container'
  properties: {
    reserved: true
    httpsOnly: true
    serverFarmId: appPlan.id
    siteConfig: {
      linuxFxVersion: 'COMPOSE|${base64(dockerComposeFileContent)}'
      alwaysOn: true
      appSettings: [
        {
          name: 'WEBSITES_PORT'
          value: '30000'
        }
        {
          name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
          value: 'true'
        }
        {
          name: 'FOUNDRY_MINIFY_STATIC_FILES'
          value: 'true'
        }
        {
          name: 'FOUNDRY_HOSTNAME'
          value: hostname
        }
        {
          name: 'FOUNDRY_ADMIN_KEY'
          value: adminKey
        }
        {
          name: 'FOUNDRY_USERNAME'
          value: foundryUsername
        }
        {
          name: 'FOUNDRY_PASSWORD'
          value: foundryPassword
        }
      ]
    }
  }
}

output webAppOutput object = webApp
