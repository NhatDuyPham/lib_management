@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'User - Interface view'
@Metadata.ignorePropagatedAnnotations: false
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity zpdp_i_user
  as select from zdp_tb_user

  association [1..*] to zpdp_i_borrowred as _Borrowed on $projection.UserId = _Borrowed.UserId
{
  key user_id           as UserId,
      name              as Name,
      membership_number as MembershipNumber,
      @Semantics.user.createdBy: true
      created_by        as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_on        as CreatedOn,
      @Semantics.user.lastChangedBy: true
      changed_by        as ChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      changed_on        as ChangedOn,

      _Borrowed
}
