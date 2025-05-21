/**
 * @module vnet-v1
 * @description This module defines the Virtual Network (VNet) resources using Bicep.
 * It includes configurations for creating and managing VNets, subnets, and network security groups.
 */


// ------------------------------
//    PARAMETERS
// ------------------------------

@description('Location to be used for resources. Defaults to the resource group location')
param location string = resourceGroup().location

@description('The unique suffix to append. Defaults to a unique string based on subscription and resource group IDs.')
param resourceSuffix string = uniqueString(subscription().id, resourceGroup().id)

param vnetName string = 'vnet-${resourceSuffix}'
param vnetAddressPrefixes array = ['10.0.0.0/16']
param subnets array = []


// ------------------------------
//    RESOURCES
// ------------------------------

// https://learn.microsoft.com/azure/templates/microsoft.network/virtualnetworks
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: vnetAddressPrefixes
    }
    subnets: subnets
  }
}


// ------------------------------
//    OUTPUTS
// ------------------------------

output vnetId string = virtualNetwork.id
