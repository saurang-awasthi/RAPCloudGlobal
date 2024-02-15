@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Invoice Attachment Demo'
define root view entity YI_Invoice_Attach
  as select from ytdemo02
{
  key invno                 as Invoice,
      remark                as Remark,
      @Semantics.largeObject:{ mimeType: 'Mimetype', fileName: 'Filename',
                               contentDispositionPreference: #INLINE }
      attachment            as Attachment,
      @Semantics.mimeType: true
      mimetype              as Mimetype,
      filename              as Filename,
      @Semantics.user.createdBy: true
      local_created_by      as LocalCreatedBy,
      @Semantics.systemDateTime.createdAt: true
      local_created_at      as LocalCreatedAt,
      @Semantics.user.lastChangedBy: true
      local_last_changed_by as LocalLastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      // Total Etag field
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt
}
