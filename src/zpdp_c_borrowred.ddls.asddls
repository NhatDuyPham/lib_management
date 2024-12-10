@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Borrowed Book'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZPDP_C_BORROWRED
  as projection on zpdp_i_borrowred
{
  key     BorrowedBookId,
          @ObjectModel.text.element: [ 'Title' ]
  key     BookId,
          @Semantics.text: true
          _Book.Title        as Title,
          @ObjectModel.text.element: [ 'UserName' ]
          @Consumption.valueHelpDefinition: [{
             entity.name: 'zpdp_i_user',
             entity.element: 'UserId'
          }]
          UserId,
          @Semantics.text: true
          UserName,
          UserMembership,
          BorrowDate,
          ReturnDate,
          Quantity,
          ActualReturnDate,
          @ObjectModel.text.element: [ 'StatusName' ]
          //      @Consumption.valueHelpDefinition: [{
          //         entity.name: 'ZPDP_borrowed_STATUS_VH',
          //         entity.element: 'Status'
          //      }]
          Status,
          @Semantics.text: true
          _Status.StatusDesc as StatusName,
          CreatedBy,
          CreatedOn,
          ChangedBy,
          ChangedOn,

          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZPDP_CL_BORRWORED'
          @EndUserText.label: 'Current Status'
  virtual current_status : abap.char(20),
          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZPDP_CL_BORRWORED'
  virtual hidden_flag    : abap_boolean,

          /* Associations */
          _Book : redirected to parent ZPDP_C_BOOK,
          _User,
          _Status

}
