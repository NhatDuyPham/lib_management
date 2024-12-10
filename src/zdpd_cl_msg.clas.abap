CLASS zdpd_cl_msg DEFINITION
  PUBLIC
  INHERITING FROM cx_static_check
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_abap_behv_message .
    INTERFACES if_t100_dyn_msg .
    INTERFACES if_t100_message .

    CONSTANTS:
      gc_msgid TYPE symsgid VALUE 'ZDPD_MSG_BOOK',

      BEGIN OF user_unkown,
        msgid TYPE symsgid VALUE gc_msgid,
        msgno TYPE symsgno VALUE '001',
        attr1 TYPE scx_attrname VALUE 'MV_USER_ID',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF user_unkown,

      BEGIN OF user_null,
        msgid TYPE symsgid VALUE gc_msgid,
        msgno TYPE symsgno VALUE '019',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF user_null,

      BEGIN OF status_unkown,
        msgid TYPE symsgid VALUE gc_msgid,
        msgno TYPE symsgno VALUE '002',
        attr1 TYPE scx_attrname VALUE 'MV_STATUS_ID',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF status_unkown,

      BEGIN OF status_null,
        msgid TYPE symsgid VALUE gc_msgid,
        msgno TYPE symsgno VALUE '012',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF status_null,

      BEGIN OF genre_unkown,
        msgid TYPE symsgid VALUE gc_msgid,
        msgno TYPE symsgno VALUE '003',
        attr1 TYPE scx_attrname VALUE 'MV_GENRE_ID',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF genre_unkown,

      BEGIN OF genre_null,
        msgid TYPE symsgid VALUE gc_msgid,
        msgno TYPE symsgno VALUE '013',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF genre_null,

      BEGIN OF quantity_minus,
        msgid TYPE symsgid VALUE gc_msgid,
        msgno TYPE symsgno VALUE '004',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF quantity_minus,

      BEGIN OF quantity_threshold,
        msgid TYPE symsgid VALUE gc_msgid,
        msgno TYPE symsgno VALUE '020',
        attr1 TYPE scx_attrname VALUE 'MV_QUANTITY',
        attr2 TYPE scx_attrname VALUE 'MV_BORROWED_QUANTITY',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF quantity_threshold,

      BEGIN OF isbn_duplicate,
        msgid TYPE symsgid VALUE gc_msgid,
        msgno TYPE symsgno VALUE '005',
        attr1 TYPE scx_attrname VALUE 'MV_ISBN',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF isbn_duplicate,

      BEGIN OF publisher_unkown,
        msgid TYPE symsgid VALUE gc_msgid,
        msgno TYPE symsgno VALUE '006',
        attr1 TYPE scx_attrname VALUE 'MV_PUBLISHER_ID',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF publisher_unkown,

      BEGIN OF author_unkown,
        msgid TYPE symsgid VALUE gc_msgid,
        msgno TYPE symsgno VALUE '007',
        attr1 TYPE scx_attrname VALUE 'MV_AUTHOR_ID',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF author_unkown,

      BEGIN OF borrow_date_bef_return_date,
        msgid TYPE symsgid VALUE gc_msgid,
        msgno TYPE symsgno VALUE '008',
        attr1 TYPE scx_attrname VALUE 'MV_BORROW_DATE',
        attr2 TYPE scx_attrname VALUE 'MV_RETURN_DATE',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF borrow_date_bef_return_date,

      BEGIN OF borrow_date_on_or_af_sysdate,
        msgid TYPE symsgid VALUE gc_msgid,
        msgno TYPE symsgno VALUE '009',
        attr1 TYPE scx_attrname VALUE 'MV_BORROW_DATE',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF borrow_date_on_or_af_sysdate,

      BEGIN OF publish_date_on_or_bef_sysdate,
        msgid TYPE symsgid VALUE gc_msgid,
        msgno TYPE symsgno VALUE '018',
        attr1 TYPE scx_attrname VALUE 'MV_PUBLISH_DATE',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF publish_date_on_or_bef_sysdate,

      BEGIN OF borrowdate_null,
        msgid TYPE symsgid VALUE gc_msgid,
        msgno TYPE symsgno VALUE '010',
        attr1 TYPE scx_attrname VALUE 'MV_BORROW_DATE',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF borrowdate_null,

      BEGIN OF returndate_null,
        msgid TYPE symsgid VALUE gc_msgid,
        msgno TYPE symsgno VALUE '011',
        attr1 TYPE scx_attrname VALUE 'MV_RETURN_DATE',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF returndate_null,

      BEGIN OF title_null,
        msgid TYPE symsgid VALUE gc_msgid,
        msgno TYPE symsgno VALUE '014',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF title_null,

      BEGIN OF isbn_null,
        msgid TYPE symsgid VALUE gc_msgid,
        msgno TYPE symsgno VALUE '015',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF isbn_null,

      BEGIN OF publisher_null,
        msgid TYPE symsgid VALUE gc_msgid,
        msgno TYPE symsgno VALUE '016',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF publisher_null,

      BEGIN OF author_null,
        msgid TYPE symsgid VALUE gc_msgid,
        msgno TYPE symsgno VALUE '017',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF author_null,

       BEGIN OF Rating_invalid,
        msgid TYPE symsgid VALUE gc_msgid,
        msgno TYPE symsgno VALUE '021',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF Rating_invalid.

    METHODS constructor
      IMPORTING
        textid            LIKE if_t100_message=>t100key OPTIONAL
        attr1             TYPE string OPTIONAL
        attr2             TYPE string OPTIONAL
        attr3             TYPE string OPTIONAL
        attr4             TYPE string OPTIONAL
        previous          LIKE previous OPTIONAL
        user_id           TYPE zdp_t_user-user_id OPTIONAL
        status            TYPE zdp_tb_status-status OPTIONAL
        genre             TYPE zdp_tb_book-genre OPTIONAL
        quantity          TYPE zdp_tb_book-quantity OPTIONAL
        borrowed_quantity TYPE zdp_tb_book-quantity OPTIONAL
        isbn              TYPE zdp_tb_book-isbn OPTIONAL
        publisher_id      TYPE zdp_tb_publisher-publisher_id OPTIONAL
        auhtor_id         TYPE zdp_tb_author-author_id OPTIONAL
        borrow_date       TYPE zdp_tb_borrowed-borrow_date OPTIONAL
        return_date       TYPE zdp_tb_borrowed-return_date OPTIONAL
        title             TYPE zdp_tb_book-title OPTIONAL
        publish_date      TYPE zdp_tb_book-publication_date OPTIONAL
        severity          TYPE if_abap_behv_message=>t_severity OPTIONAL
        uname             TYPE syuname OPTIONAL.

    DATA:
      mv_attr1             TYPE string,
      mv_attr2             TYPE string,
      mv_attr3             TYPE string,
      mv_attr4             TYPE string,
      mv_user_id           TYPE zdp_t_user-user_id,
      mv_status_id         TYPE zdp_tb_status,
      mv_genre_id          TYPE zdp_tb_book-genre,
      mv_isbn              TYPE zdp_tb_book-isbn,
      mv_publisher_id      TYPE zdp_tb_publisher-publisher_id,
      mv_author_id         TYPE zdp_tb_author-author_id,
      mv_borrow_date       TYPE zdp_tb_borrowed-borrow_date,
      mv_return_date       TYPE zdp_tb_borrowed-return_date,
      mv_publish_date      TYPE zdp_tb_book-publication_date,
      mv_quantity          TYPE zdp_tb_book-quantity,
      mv_borrowed_quantity TYPE zdp_tb_book-quantity,
      mv_uname             TYPE syuname.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZDPD_CL_MSG IMPLEMENTATION.


  METHOD constructor ##ADT_SUPPRESS_GENERATION.

    super->constructor(  previous = previous ).

    me->mv_attr1             = attr1.
    me->mv_attr2             = attr2.
    me->mv_attr3             = attr3.
    me->mv_attr4             = attr4.
    me->mv_user_id           = user_id.
    me->mv_status_id         = status.
    me->mv_genre_id          = genre.
    me->mv_isbn              = isbn.
    me->mv_publisher_id      = publisher_id.
    me->mv_author_id         = auhtor_id.
    me->mv_borrow_date       = borrow_date.
    me->mv_return_date       = return_date.
    me->mv_publish_date      = publish_date.
    me->mv_quantity          = quantity.
    me->mv_uname             = uname.


    if_abap_behv_message~m_severity = severity.

    CLEAR me->textid.
    IF textid IS INITIAL.
      if_t100_message~t100key = if_t100_message=>default_textid.
    ELSE.
      if_t100_message~t100key = textid.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
