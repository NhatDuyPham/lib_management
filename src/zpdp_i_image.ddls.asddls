@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Image - Interface view'
@Metadata.ignorePropagatedAnnotations: false
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zpdp_i_image
  as select from zdp_tb_image
  association to parent zpdp_i_book as _Book on $projection.BookId = _Book.BookId
{
  key image_id   as ImageId,
  key book_id    as BookId,
      @Semantics.largeObject:{ 
                              mimeType: 'Mimetype',
                              fileName: 'Filename',
                              contentDispositionPreference: #INLINE,
                              acceptableMimeTypes: ['image/*']
                              }
      attachment as Attachment,
      @Semantics.mimeType: true
      mimetype   as Mimetype,
      filename   as Filename,
      @Semantics.user.createdBy: true
      created_by as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_on as CreatedOn,
      @Semantics.user.lastChangedBy: true
      changed_by as ChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      changed_on as ChangedOn,

      // Association
      _Book
}
