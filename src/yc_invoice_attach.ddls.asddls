@EndUserText.label: 'Invoice Attachment Demo'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define root view entity YC_INVOICE_ATTACH
//  provider contract transactional_query
  as projection on YI_Invoice_Attach
{
  key Invoice,
      Remark,
      Attachment,
      Mimetype,
      Filename,
      LocalLastChangedAt
}
