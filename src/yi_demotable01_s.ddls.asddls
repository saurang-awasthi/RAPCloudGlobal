@EndUserText.label: 'Demo Table 01 Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity YI_DemoTable01_S
  as select from I_Language
    left outer join YTDEMO01 on 0 = 0
  composition [0..*] of YI_DemoTable01 as _DemoTable01
{
  key 1 as SingletonID,
  _DemoTable01,
  max( YTDEMO01.LAST_CHANGED_AT ) as LastChangedAtMax,
  cast( '' as SXCO_TRANSPORT) as TransportRequestID,
  cast( 'X' as ABAP_BOOLEAN preserving type) as HideTransport
  
}
where I_Language.Language = $session.system_language
