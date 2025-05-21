/**
 * @module containerapp-v1
 * @description This module defines the Azure Container App resources using Bicep.
 */


// ------------------------------
//    PARAMETERS
// ------------------------------

@description('Location to be used for resources. Defaults to the resource group location')
param location string = resourceGroup().location

@description('The unique suffix to append. Defaults to a unique string based on subscription and resource group IDs.')
param resourceSuffix string = uniqueString(subscription().id, resourceGroup().id)

@description('Name of the Container App. Defaults to "ca-<resourceSuffix>".')
param name string = 'ca-${resourceSuffix}'

@description('Container image to deploy')
param containerImage string

@description('Container app environment resource id')
param environmentId string

@description('Container app CPU (vCPU)')
param cpu string = '0.25'

@description('Container app memory (GiB), e.g. "0.5Gi"')
param memory string = '0.5Gi'

@description('Ingress external port')
param ingressPort int = 8080

@description('Enable public ingress')
param ingressExternal bool = true


// ------------------------------
//    RESOURCES
// ------------------------------

// https://learn.microsoft.com/azure/templates/microsoft.app/containerapps
#disable-next-line BCP081
resource containerApp 'Microsoft.App/containerApps@2025-01-01' = {
  name: name
  location: location
  properties: {
    managedEnvironmentId: environmentId
    configuration: {
      ingress: {
        external: ingressExternal
        targetPort: ingressPort
        transport: 'auto'
        allowInsecure: false
      }
      registries: [] // No ACR needed
    }
    template: {
      containers: [
        {
          name: name
          image: containerImage
          resources: {
            cpu: json(cpu)  // Convert string to JSON, which is bizarre, but required for this "int"
            memory: memory
          }
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 3
      }
    }
  }
}


// ------------------------------
//    OUTPUTS
// ------------------------------

output containerAppName string = containerApp.name
output containerAppFqdn string = containerApp.properties.configuration.ingress.fqdn
