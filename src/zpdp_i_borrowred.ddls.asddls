@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BorrowedBook - Interface view'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zpdp_i_borrowred
  as select from zdp_tb_borrowed
  association        to parent zpdp_i_book      as _Book   on $projection.BookId = _Book.BookId

  association [0..1] to zpdp_i_user             as _User   on $projection.UserId = _User.UserId
  association [1..1] to ZPDP_borrowed_STATUS_VH as _Status on $projection.Status = _Status.Status

{
  key borrowed_book_id       as BorrowedBookId,
  key book_id                as BookId,
      user_id                as UserId,
      _User.Name             as UserName,
      _User.MembershipNumber as UserMembership,
      borrow_date            as BorrowDate,
      return_date            as ReturnDate,
      quantity               as Quantity,
      actual_return_date     as ActualReturnDate,
      borrowed_status        as Status,
      @Semantics.user.createdBy: true
      created_by             as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_on             as CreatedOn,
      @Semantics.user.lastChangedBy: true
      changed_by             as ChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      changed_on             as ChangedOn,

      // Associaion
      _User,
      _Book,
      _Status
}
