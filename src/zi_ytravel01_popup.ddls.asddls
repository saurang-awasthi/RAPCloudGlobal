@EndUserText.label: 'Popup Travel Detail'
@Metadata.allowExtensions: true
define abstract entity ZI_YTRAVEL01_POPUP
{

  TravelID      : /dmo/travel_id;
  AgencyID      : /dmo/agency_id;
  CustomerID    : /dmo/customer_id;
  BeginDate     : /dmo/begin_date;
  EndDate       : /dmo/end_date;
  @Semantics.amount.currencyCode : 'CurrencyCode'
  BookingFee    : /dmo/booking_fee;
  @Semantics.amount.currencyCode : 'CurrencyCode'
  TotalPrice    : /dmo/total_price;
  CurrencyCode  : /dmo/currency_code;
  Description   : /dmo/description;
  OverallStatus : /dmo/overall_status;

}
