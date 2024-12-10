@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Book'
//@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZPDP_C_BOOK
  provider contract transactional_query
  as projection on zpdp_i_book
{
  key BookId,
      Title,
      Isbn,
      @ObjectModel.text.element: [ 'GenreName' ]
      @Consumption.valueHelpDefinition: [{
          entity.name: 'ZPDP_GENRE_VH',
          entity.element: 'GenreId'
      }]
      Genre,
      @Semantics.text: true
      _Genre.GenreDesc   as GenreName,
      @ObjectModel.text.element: [ 'AuthorName' ]
      @Consumption.valueHelpDefinition: [{
          entity.name: 'zpdp_i_author',
          entity.element: 'AuthorId'
      }]
      AuthorId,
      @Semantics.text: true
      AuthorName,
      AuthorCountry,
      @ObjectModel.text.element: [ 'PublisherName' ]
      @Consumption.valueHelpDefinition: [{
         entity.name: 'zpdp_i_publisher',
         entity.element: 'PublisherId'
     }]
      PublisherId,
      @Semantics.text: true
      PublisherName,
      PublicationDate,
      PublisherAddr,
      @ObjectModel.text.element: [ 'StatusName' ]
      @Consumption.valueHelpDefinition: [{
         entity.name: 'zpdp_Status_vh',
         entity.element: 'Status'
      }]
      Status,
      @Semantics.text: true
      _Status.StatusDesc as StatusName,
      Criticality,
      ImageUrl,
      
      @Semantics.imageUrl: true
      @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZPDP_CL_BOOK'
      virtual ImageUrl_list : abap.string(1000),
      Quantity,
      Rating,
      CreatedBy,
      CreatedOn,
      ChangedBy,
      ChangedOn,
      /* Associations */
      _Author,
      _Borrowed : redirected to composition child ZPDP_C_BORROWRED,
      _Genre,
      _Image    : redirected to composition child ZPDP_C_IMAGE,
      _Publisher,
      _Status
      
      
}
