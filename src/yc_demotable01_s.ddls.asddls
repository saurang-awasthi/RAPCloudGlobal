@EndUserText.label: 'Maintain Demo Table 01 Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@ObjectModel.semanticKey: [ 'SingletonID' ]
define root view entity YC_DemoTable01_S
  provider contract transactional_query
  as projection on YI_DemoTable01_S
{
  key SingletonID,
  LastChangedAtMax,
  TransportRequestID,
  HideTransport,
  _DemoTable01 : redirected to composition child YC_DemoTable01
  
}
