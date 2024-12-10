@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Publisher - Interface view'
@Metadata.ignorePropagatedAnnotations: false
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zpdp_i_publisher
  as select from zdp_tb_publisher
{
  key publisher_id as PublisherId,
      name         as Name,
      address      as Address,
      @Semantics.user.createdBy: true
      created_by   as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_on   as CreatedOn,
      @Semantics.user.lastChangedBy: true
      changed_by   as ChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      changed_on   as ChangedOn
}
