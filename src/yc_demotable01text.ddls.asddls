@EndUserText.label: 'Maintain Demo Table 01 Text'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity YC_DemoTable01Text
  as projection on YI_DemoTable01Text
{
  @ObjectModel.text.element: [ 'LanguageName' ]
  @Consumption.valueHelpDefinition: [ {
    entity: {
      name: 'I_Language', 
      element: 'Language'
    }
  } ]
  key Langu,
  key Dtcode,
  Dtdesc,
  @Consumption.hidden: true
  LocalLastChangedAt,
  @Consumption.hidden: true
  SingletonID,
  _LanguageText.LanguageName : localized,
  _DemoTable01 : redirected to parent YC_DemoTable01,
  _DemoTable01All : redirected to YC_DemoTable01_S
  
}
