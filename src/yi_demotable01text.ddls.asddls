@EndUserText.label: 'Demo Table 01 Text'
@AccessControl.authorizationCheck: #CHECK
@ObjectModel.dataCategory: #TEXT
define view entity YI_DemoTable01Text
  as select from YTDEMO01T
  association [1..1] to YI_DemoTable01_S as _DemoTable01All on $projection.SingletonID = _DemoTable01All.SingletonID
  association to parent YI_DemoTable01 as _DemoTable01 on $projection.Dtcode = _DemoTable01.Dtcode
  association [0..*] to I_LanguageText as _LanguageText on $projection.Langu = _LanguageText.LanguageCode
{
  @Semantics.language: true
  key LANGU as Langu,
  key DTCODE as Dtcode,
  @Semantics.text: true
  DTDESC as Dtdesc,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  LOCAL_LAST_CHANGED_AT as LocalLastChangedAt,
  1 as SingletonID,
  _DemoTable01All,
  _DemoTable01,
  _LanguageText
  
}
