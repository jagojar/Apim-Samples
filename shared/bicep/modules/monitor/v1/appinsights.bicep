/**
 * @module appinsights-v1
 * @description This module defines the Azure Application Insights (AppInsights) resources using Bicep.
 */


// ------------------------------
//    PARAMETERS
// ------------------------------

@description('Location to be used for resources. Defaults to the resource group location')
param location string = resourceGroup().location

@description('The unique suffix to append. Defaults to a unique string based on subscription and resource group IDs.')
param resourceSuffix string = uniqueString(subscription().id, resourceGroup().id)

@description('Name of the Application Insights resource. Defaults to "appi-<resourceSuffix>".')
param applicationInsightsName string = 'appi-${resourceSuffix}'

@description('Location of the Application Insights resource')
param applicationInsightsLocation string = resourceGroup().location

@description('The custom metrics opted in type. Default is Off')
@allowed([
  'WithDimensions'
  'NoDimensions'
  'NoMeasurements'
  'Off'
])
param customMetricsOptedInType string = 'Off'

@description('Indicate whether workbook is used. Default is false')
param useWorkbook bool = false

@description('Name for the Workbook. Defaults to "OpenAIUsageAnalysis".')
param workbookName string = 'OpenAIUsageAnalysis'

@description('Location for the Workbook')
param workbookLocation string = resourceGroup().location

@description('Display Name for the Workbook. Defaults to "OpenAI Usage Analysis".')
param workbookDisplayName string = 'OpenAI Usage Analysis'

@description('JSON string for the Workbook')
param workbookJson string = ''

@description('Log Analytics Workspace Id')
param lawId string


// ------------------------------
//    RESOURCES
// ------------------------------

// https://learn.microsoft.com/azure/templates/microsoft.insights/components
resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsName
  location: applicationInsightsLocation
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: lawId
    // BCP037: Not yet added to latest API: https://github.com/Azure/bicep-types-az/issues/2048
    #disable-next-line BCP037
    CustomMetricsOptedInType: customMetricsOptedInType
  }
}

// https://learn.microsoft.com/azure/templates/microsoft.insights/workbooks
resource workbook 'Microsoft.Insights/workbooks@2023-06-01' = if (useWorkbook) {
  name: guid(resourceGroup().id, workbookName)
  location: workbookLocation
  kind: 'shared'
  properties: {
    displayName: workbookDisplayName
    serializedData: workbookJson
    sourceId: applicationInsights.id
    category: 'ApimSamples'
  }
}


// ------------------------------
//    OUTPUTS
// ------------------------------

output id string = applicationInsights.id
output instrumentationKey string = applicationInsights.properties.InstrumentationKey
output appId string = applicationInsights.properties.AppId
output applicationInsightsName string = applicationInsightsName
