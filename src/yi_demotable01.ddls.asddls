@EndUserText.label: 'Demo Table 01'
@AccessControl.authorizationCheck: #CHECK
define view entity YI_DemoTable01
  as select from YTDEMO01
  association to parent YI_DemoTable01_S as _DemoTable01All on $projection.SingletonID = _DemoTable01All.SingletonID
  composition [0..*] of YI_DemoTable01Text as _DemoTable01Text
{
  key DTCODE as Dtcode,
  @Semantics.systemDateTime.lastChangedAt: true
  LAST_CHANGED_AT as LastChangedAt,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  LOCAL_LAST_CHANGED_AT as LocalLastChangedAt,
  1 as SingletonID,
  _DemoTable01All,
  _DemoTable01Text
  
}
