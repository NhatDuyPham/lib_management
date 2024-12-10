@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Image'
@Metadata.ignorePropagatedAnnotations: false
@Metadata.allowExtensions: true
define view entity ZPDP_C_IMAGE
  as projection on zpdp_i_image
{
  key ImageId,
      @ObjectModel.text.element: [ 'Title' ]
  key BookId,
      @Semantics.text: true
      _Book.Title as Title,
      Attachment,
      Mimetype,
      Filename,
      CreatedBy,
      CreatedOn,
      ChangedBy,
      ChangedOn,
      /* Associations */
      _Book : redirected to parent ZPDP_C_BOOK
}
