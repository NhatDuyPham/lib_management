@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Author'
//@Metadata.ignorePropagatedAnnotations: true
define root view entity ZPDP_C_AUTHOR
  as projection on zpdp_i_author
{
  key AuthorId,
      Name,
      Country,
      CreatedBy,
      CreatedOn,
      ChangedBy,
      ChangedOn
}
