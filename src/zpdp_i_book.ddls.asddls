@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Book - Interface view'
//@Metadata.ignorePropagatedAnnotations: true
define root view entity zpdp_i_book
  as select from zdp_tb_book
  composition [0..*] of zpdp_i_borrowred as _Borrowed
  composition [0..*] of zpdp_i_image     as _Image

  association [0..1] to zpdp_i_author    as _Author    on $projection.AuthorId = _Author.AuthorId
  association [0..1] to zpdp_i_publisher as _Publisher on $projection.PublisherId = _Publisher.PublisherId
  association [1..1] to zpdp_genre_vh    as _Genre     on $projection.Genre = _Genre.GenreId
  association [1..1] to zpdp_Status_vh   as _Status    on $projection.Status = _Status.Status
{

  key book_id            as BookId,
      title              as Title,
      isbn               as Isbn,
      genre              as Genre,
      author_id          as AuthorId,
      _Author.Name       as AuthorName,
      _Author.Country    as AuthorCountry,
      publisher_id       as PublisherId,
      publication_date   as PublicationDate,
      _Publisher.Address as PublisherAddr,
      _Publisher.Name    as PublisherName,
      status             as Status,
      image_url          as ImageUrl,
      quantity           as Quantity,
      rating             as Rating,
      @Semantics.user.createdBy: true
      created_by         as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_on         as CreatedOn,
      @Semantics.user.lastChangedBy: true
      changed_by         as ChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      changed_on         as ChangedOn,

      case status
          when 'O' then 3
          when 'X' then 1
          end            as Criticality,

      // Association
      _Author,
      _Borrowed,
      _Image,
      _Publisher,
      _Genre,
      _Status
}
