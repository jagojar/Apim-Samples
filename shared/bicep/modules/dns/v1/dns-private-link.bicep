/**
 * @module dns-private-link-v1
 * @description This module defines Azure Private Link resources using Bicep.
 * It includes configurations for creating and managing private links.
 */


// ------------------------------
//    PARAMETERS
// ------------------------------

@description('The location to be used. Defaults to the resource group location.')
param location string = resourceGroup().location

@description('The suffix to append . Defaults to a unique string based on subscription and resource group IDs.')
param resourceSuffix string = uniqueString(subscription().id, resourceGroup().id)

@description('The name of the private DNS zone (e.g., privatelink.azure-api.net).')
param dnsZoneName string

@description('The resource ID of the virtual network to link.')
param vnetId string

@description('The name of the virtual network link resource.')
param vnetLinkName string = 'link-default'

@description('Whether to create a DNS zone group for a private endpoint.')
param enableDnsZoneGroup bool = true

@description('The resource ID of the private endpoint to associate with the DNS zone group (required if enableDnsZoneGroup is true).')
param privateEndpointId string = ''

@description('The name of the DNS zone group resource.')
param dnsZoneGroupName string = 'dnsZoneGroup-default'

@description('The name of the DNS zone config for the group.')
param dnsZoneConfigName string = 'config-default'


// ------------------------------
//    RESOURCES
// ------------------------------

// https://learn.microsoft.com/azure/templates/microsoft.network/privateDnsZones
resource privateDnsZone 'Microsoft.Network/privateDnsZones@2024-06-01' = {
  name: dnsZoneName
  location: 'global'
}

// https://learn.microsoft.com/azure/templates/microsoft.network/privateDnsZones/virtualNetworkLinks
resource privateDnsZoneVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01' = {
  name: vnetLinkName
  location: 'global'
  parent: privateDnsZone
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

// https://learn.microsoft.com/azure/templates/microsoft.network/privateEndpoints
// resource privateEndpoint 'Microsoft.Network/privateEndpoints@2024-05-01' existing = {
//   name: last(split(privateEndpointId, '/'))
// }

// TODO: Fix the resource name error for the private DNS zone group
// https://learn.microsoft.com/azure/templates/microsoft.network/privateEndpoints/privateDnsZoneGroups
// resource privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-05-01' = if (enableDnsZoneGroup) {
//   name: dnsZoneGroupName
//   parent: privateEndpoint
//   properties: {
//     privateDnsZoneConfigs: [
//       {
//         name: dnsZoneConfigName
//         properties: {
//           privateDnsZoneId: privateDnsZone.id
//         }
//       }
//     ]
//   }
// }


// ------------------------------
//    OUTPUTS
// ------------------------------

output privateDnsZoneId string = privateDnsZone.id
//output privateDnsZoneVnetLinkId string = privateDnsZoneVnetLink.id
//output privateDnsZoneGroupId string = enableDnsZoneGroup ? privateDnsZoneGroup.id : ''
