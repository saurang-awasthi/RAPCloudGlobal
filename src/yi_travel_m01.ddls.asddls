@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Data Model for Travel 01'
define root view entity YI_TRAVEL_M01
  as select from /dmo/travel as Travel
  /* Assocications */
  association [0..1] to /DMO/I_Agency   as _Agency   on $projection.agency_id = _Agency.AgencyID
  association [0..1] to /DMO/I_Customer as _Customer on $projection.customer_id = _Customer.CustomerID
  association [0..1] to I_Currency      as _Currency on $projection.currency_code = _Currency.Currency
{

  key travel_id,
      agency_id,
      customer_id,
      begin_date,
      end_date,
      @Semantics.amount.currencyCode: 'currency_code'
      booking_fee,
      @Semantics.amount.currencyCode: 'currency_code'
      total_price,
      currency_code,
      status,
      description,

      /* Admin Data */
      @Semantics.user.createdBy: true
      createdby,
      @Semantics.systemDateTime.createdAt: true
      createdat,
      @Semantics.user.lastChangedBy: true
      lastchangedby,
      @Semantics.systemDateTime.lastChangedAt: true
      lastchangedat,
      @Semantics.largeObject:{ fileName: '_Agency.Filename', mimeType: '_Agency.MimeType',
                               contentDispositionPreference: #INLINE }
      _Agency.Attachment,
      @Semantics.mimeType: true
      _Agency.MimeType,      
      _Agency.Filename,

      /* Public Assocications */
      _Agency,
      _Customer,
      _Currency
}
