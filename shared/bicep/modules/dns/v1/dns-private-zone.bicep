/**
 * @module dns-private-zone-v1
 * @description This module defines the Azure Private DNS Zone resources using Bicep.
 * It includes configurations for creating and managing an the Private DNZ Zone instance.
 */


// ------------------------------
//    PARAMETERS
// ------------------------------

@description('The name of the private DNS zone (e.g., privatelink.azure-api.net).')
param dnsZoneName string

@description('The resource ID of the virtual network to link.')
param vnetId string

@description('The name of the virtual network link resource.')
param vnetLinkName string = 'link-${dnsZoneName}'


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


// ------------------------------
//    OUTPUTS
// ------------------------------

output privateDnsZoneId string = privateDnsZone.id
output privateDnsZoneVnetLinkId string = privateDnsZoneVnetLink.id
