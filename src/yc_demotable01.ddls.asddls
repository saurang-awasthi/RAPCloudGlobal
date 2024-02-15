@EndUserText.label: 'Maintain Demo Table 01'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity YC_DemoTable01
  as projection on YI_DemoTable01
{
  key Dtcode,
  LastChangedAt,
  @Consumption.hidden: true
  LocalLastChangedAt,
  @Consumption.hidden: true
  SingletonID,
  _DemoTable01All : redirected to parent YC_DemoTable01_S,
  _DemoTable01Text : redirected to composition child YC_DemoTable01Text,
  _DemoTable01Text.Dtdesc : localized
  
}
