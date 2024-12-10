@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'User'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZPDP_C_USER
  provider contract transactional_query
  as projection on zpdp_i_user
{
  key UserId,
      Name,
      MembershipNumber,
      CreatedBy,
      CreatedOn,
      ChangedBy,
      ChangedOn,
      /* Associations */
      _Borrowed
}
