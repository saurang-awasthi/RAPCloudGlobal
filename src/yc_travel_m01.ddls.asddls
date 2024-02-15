@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection View for Travel'

@UI:{ headerInfo:{ typeName: 'Travel', typeNamePlural: 'Travels',
                   title:{ type: #STANDARD, value: 'TravelID' },
                   description:{ type: #STANDARD, value: 'Description' } },
      presentationVariant: [{ sortOrder: [{ by: 'TravelID', direction: #ASC }],
                              visualizations: [{ type: #AS_LINEITEM }] }] }
@Search.searchable: true

define root view entity YC_TRAVEL_M01
  provider contract transactional_query
  as projection on YI_TRAVEL_M01
{
      @UI.facet: [{ id: 'Travel', purpose: #STANDARD, type: #IDENTIFICATION_REFERENCE, label: 'Travel', position: 10 }]

      @UI:{
        lineItem: [{ position: 10, importance: #HIGH, label: 'Travel ID' }],
        identification: [{ position: 10, label: 'Travel ID' }]
      }
      @EndUserText.label: 'Travel ID'
      @Search.defaultSearchElement: true
  key travel_id          as TravelID,

      @UI:{
        lineItem: [{ position: 20, importance: #HIGH, label: 'Agency ID' }],
        identification: [{ position: 20, label: 'Agency ID' }],
        selectionField: [{ position: 20 }]
      }
      @EndUserText.label: 'Agency ID'
      @Consumption.valueHelpDefinition: [{ entity:{ name: '/DMO/I_Agency', element: 'AgencyID' } }]
      @ObjectModel.text.element: [ 'AgencyName' ]
      @Search.defaultSearchElement: true
      agency_id          as AgencyID,
      @EndUserText.label: 'Agency Name'
      _Agency.Name       as AgencyName,

      @UI:{
        lineItem: [{ position: 30, importance: #HIGH, label: 'Customer ID' }],
        identification: [{ position: 30, label: 'Customer ID' }],
        selectionField: [{ position: 30 }]
      }
      @EndUserText.label: 'Customer ID'
      @Consumption.valueHelpDefinition: [{ entity:{ name: '/DMO/I_Customer', element: 'CustomerID' } }]
      @ObjectModel.text.element: [ 'CustomerName' ]
      @Search.defaultSearchElement: true
      customer_id        as CustomerID,
      @UI.hidden: true
      @EndUserText.label: 'Customer Name'
      _Customer.LastName as CustomerName,

      @UI:{
        lineItem: [{ position: 40, importance: #MEDIUM }],
        identification: [{ position: 40 }]
      }
      @EndUserText.label: 'Begin Date'
      begin_date         as BeginDate,

      @UI:{
        lineItem: [{ position: 45, importance: #MEDIUM }],
        identification: [{ position: 45 }]
      }
      @EndUserText.label: 'End Date'
      end_date           as EndDate,

      @UI:{
        lineItem: [{ position: 50, importance: #MEDIUM }],
        identification: [{ position: 50, label: 'Total Price' }]
      }
      @EndUserText.label: 'Total Price'
      @Semantics.amount.currencyCode: 'CurrencyCode'
      total_price        as TotalPrice,

      @Consumption.valueHelpDefinition: [{ entity:{ name: 'I_Currency', element: 'Currency' } }]
      @EndUserText.label: 'Currency Code'
      currency_code      as CurrencyCode,

      @UI:{
        lineItem: [{ position: 60, importance: #HIGH },
                   { type: #FOR_ACTION, dataAction: 'acceptTravel', label: 'Accept Travel' }],
        identification: [{ position: 60, label: 'Status' }]
      }
      @EndUserText.label: 'Status'
      status             as TravelStatus,

      @UI.identification: [{ position: 70, label: 'Remarks' }]
      @EndUserText.label: 'Remarks'
      description        as Description,

      @UI:{ identification: [{ position: 80, label: 'Attachment' , importance: #HIGH }] }
      @EndUserText.label: 'Attachment'
      _Agency.Attachment as Attachment,

      @EndUserText.label: 'Mime Type'
      @UI.hidden: true
      _Agency.MimeType   as MimeType,

      @EndUserText.label: 'File Name'
      @UI.hidden: true
      _Agency.Filename   as FileName,

      @UI.hidden: true
      lastchangedat      as LastChangedAt
}
