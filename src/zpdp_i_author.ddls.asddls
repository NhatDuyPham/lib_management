@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Author - Interface view'
@Metadata.ignorePropagatedAnnotations: false
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity zpdp_i_author
  as select from zdp_tb_author
{
  key author_id  as AuthorId,
      name       as Name,
      country    as Country,
      @Semantics.user.createdBy: true
      created_by as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_on as CreatedOn,
      @Semantics.user.lastChangedBy: true
      changed_by as ChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      changed_on as ChangedOn
}
