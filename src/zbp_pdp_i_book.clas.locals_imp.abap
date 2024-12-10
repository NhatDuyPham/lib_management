CLASS lsc_zpdp_i_book DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

ENDCLASS.

CLASS lsc_zpdp_i_book IMPLEMENTATION.

  METHOD save_modified.

*    IF create-borrowred IS NOT INITIAL.
*
*      DATA: lt_books TYPE TABLE FOR UPDATE zpdp_i_book\\Book.
*
*      READ ENTITIES OF zpdp_i_book IN LOCAL MODE
*          ENTITY Book
*          ALL FIELDS WITH CORRESPONDING #( create-borrowred )
*          RESULT DATA(lt_read_books).
*
*      LOOP AT lt_read_books ASSIGNING FIELD-SYMBOL(<lfs_read_books>) GROUP BY <lfs_read_books>-BookId.
*        LOOP AT create-borrowred INTO DATA(ls_borrwed) WHERE bookid = <lfs_read_books>-BookId.
*          <lfs_read_books>-Quantity -= ls_borrwed-Quantity.
*        ENDLOOP.
*
*        APPEND VALUE #( %tky  = <lfs_read_books>-%tky
*                        %data = CORRESPONDING #( <lfs_read_books> ) ) TO lt_books
*            ASSIGNING FIELD-SYMBOL(<lfs_book>).
*      ENDLOOP.


*      MODIFY ENTITIES OF zpdp_i_book IN LOCAL MODE
*    ENTITY Borrowred
*    UPDATE FIELDS ( Status ActualReturnDate )
*    WITH VALUE #( FOR ls_Borrow IN lt_Borrowred ( %tky          = ls_Borrow-%tky
*                                                 Status = 'L'
*                                                  ) )
*     FAILED failed
*     REPORTED reported.

*      MODIFY ENTITIES OF zpdp_i_book IN LOCAL MODE
*      ENTITY Book
*      UPDATE FIELDS ( Quantity )
*      WITH value #( for ls_books in lt_books ( %tky          = ls_books-%tky
*                                               Quantity = ls_books-Quantity ) )
*      MAPPED DATA(mapped_update)
*      FAILED DATA(failed)
*      REPORTED DATA(message).

*      CLEAR: lt_books.

*    ENDIF.


  ENDMETHOD.

ENDCLASS.

CLASS lhc_borrowred DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS validateBorrowed FOR VALIDATE ON SAVE
      IMPORTING keys FOR Borrowred~validateBorrowed.
    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Borrowred RESULT result.

    METHODS ReturnBook FOR MODIFY
      IMPORTING keys FOR ACTION Borrowred~ReturnBook RESULT result.
    METHODS Lost FOR MODIFY
      IMPORTING keys FOR ACTION Borrowred~Lost RESULT result.
    METHODS calculateQuantity FOR DETERMINE ON SAVE
      IMPORTING keys FOR Borrowred~calculateQuantity.
    METHODS get_user_data FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Borrowred~get_user_data.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Borrowred RESULT result.

ENDCLASS.

CLASS lhc_borrowred IMPLEMENTATION.

  METHOD validateBorrowed.
    DATA: lv_quan        TYPE zdp_tb_borrowed-quantity,
          lv_old_quan    TYPE zdp_tb_borrowed-quantity,
          lv_remain_quan TYPE zdp_tb_borrowed-quantity.

    READ ENTITIES OF zpdp_i_book IN LOCAL MODE
    ENTITY Borrowred
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_borrowed).

    CHECK lt_borrowed IS NOT INITIAL.

    SELECT quantity , book_id
    FROM zdp_tb_book
    FOR ALL ENTRIES IN @lt_borrowed
    WHERE book_id = @lt_borrowed-BookId
    INTO TABLE @DATA(lt_book).

    SELECT *
    FROM zdp_tb_user
    FOR ALL ENTRIES IN @lt_borrowed
    WHERE user_id = @lt_borrowed-UserId
    INTO TABLE @DATA(lt_users).

*    DATA(lt_borroweds) = lt_borrowed.
    READ ENTITIES OF zpdp_i_book IN LOCAL MODE
    ENTITY Book BY \_Borrowed
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_borroweds).

    SELECT t1~book_id
          ,SUM( t1~quantity ) AS quantity
    FROM zdp_tb_borrowed AS t1
        INNER JOIN @lt_borroweds AS t2
                ON t1~book_id          = t2~BookId
               AND t1~borrowed_book_id = t2~BorrowedBookId
    WHERE t1~borrowed_status NE 'R' AND borrowed_status NE 'L'
    GROUP BY t1~book_id
    INTO TABLE @DATA(lt_old_borrwed).

    DELETE lt_borroweds WHERE Status EQ 'R' OR ( Status NE space AND Status NE 'L' ).

    LOOP AT lt_borrowed ASSIGNING FIELD-SYMBOL(<lfs_borrowed>).
*      " Quantity
      APPEND VALUE #( %tky        = <lfs_borrowed>-%tky
                      %state_area = 'QUANTITY'
                         ) TO reported-borrowred.
      IF <lfs_borrowed>-Quantity <= 0.
        APPEND VALUE #( %tky = <lfs_borrowed>-%tky ) TO failed-borrowred.
        APPEND VALUE #( %tky = <lfs_borrowed>-%tky
                        %element-quantity = if_abap_behv=>mk-on
                        %state_area       = 'QUANTITY'
                        %path             = VALUE #(  book-bookid    = <lfs_borrowed>-BookId
                                                      book-%is_draft = <lfs_borrowed>-%is_draft  )
                        %msg = NEW zdpd_cl_msg(
                                      textid    = zdpd_cl_msg=>quantity_minus
                                      quantity  = <lfs_borrowed>-quantity
                                      severity  = if_abap_behv_message=>severity-error
                            )
                        ) TO reported-borrowred.

      ELSE.
        CLEAR: lv_old_quan,lv_quan, lv_remain_quan.
        READ TABLE lt_old_borrwed INTO DATA(ls_old_borrwed) WITH KEY book_id = <lfs_borrowed>-BookId.
        IF sy-subrc EQ 0.
          lv_old_quan = ls_old_borrwed-quantity.
        ENDIF.
        LOOP AT lt_borroweds INTO DATA(ls_borrowed) WHERE BookId = <lfs_borrowed>-BookId.
          lv_quan += ls_borrowed-Quantity.
        ENDLOOP.
        READ TABLE lt_book INTO DATA(ls_book) WITH KEY book_id = <lfs_borrowed>-BookId.
        IF sy-subrc EQ 0.
          lv_remain_quan = ls_book-quantity + lv_old_quan - lv_quan.
        ENDIF.

        IF lv_remain_quan < 0.
          APPEND VALUE #( %tky = <lfs_borrowed>-%tky ) TO failed-borrowred.
          APPEND VALUE #( %tky = <lfs_borrowed>-%tky
                          %element-quantity = if_abap_behv=>mk-on
                          %state_area       = 'QUANTITY'
                          %path             = VALUE #(  book-bookid    = <lfs_borrowed>-BookId
                                                        book-%is_draft = <lfs_borrowed>-%is_draft  )
                          %msg = NEW zdpd_cl_msg(
                                        textid    = zdpd_cl_msg=>quantity_threshold
                                        quantity  = abs( lv_remain_quan )
                                        severity  = if_abap_behv_message=>severity-error
                              )


                          ) TO reported-borrowred.
        ENDIF.
      ENDIF.

      " User
      APPEND VALUE #( %tky        = <lfs_borrowed>-%tky
                      %state_area = 'USERID'
                         ) TO reported-borrowred.
      IF <lfs_borrowed>-UserId IS INITIAL.
        APPEND VALUE #( %tky = <lfs_borrowed>-%tky ) TO failed-borrowred.
        APPEND VALUE #( %tky = <lfs_borrowed>-%tky
                        %element-UserId = if_abap_behv=>mk-on
                        %state_area     = 'USERID'
                        %path           = VALUE #(  book-bookid    = <lfs_borrowed>-BookId
                                                    book-%is_draft = <lfs_borrowed>-%is_draft  )
                        %msg = NEW zdpd_cl_msg(
                                      textid    = zdpd_cl_msg=>user_null
                                      user_id  = <lfs_borrowed>-UserId
                                      severity  = if_abap_behv_message=>severity-error
                            )
                        ) TO reported-borrowred.
      ELSE.

        IF ( NOT line_exists( lt_users[ user_id = <lfs_borrowed>-UserId ] ) ).
          APPEND VALUE #( %tky = <lfs_borrowed>-%tky ) TO failed-borrowred.
          APPEND VALUE #( %tky = <lfs_borrowed>-%tky
                          %element-UserId = if_abap_behv=>mk-on
                          %state_area     = 'USERID'
                          %path           = VALUE #(  book-bookid    = <lfs_borrowed>-BookId
                                                      book-%is_draft = <lfs_borrowed>-%is_draft  )
                          %msg = NEW zdpd_cl_msg(
                                        textid    = zdpd_cl_msg=>user_unkown
                                        user_id  = <lfs_borrowed>-UserId
                                        severity  = if_abap_behv_message=>severity-error
                              )
                          ) TO reported-borrowred.
        ENDIF.
      ENDIF.

      " Borrowed Date
      APPEND VALUE #( %tky        = <lfs_borrowed>-%tky
                      %state_area = 'BORROWEDDATE'
                         ) TO reported-borrowred.
      IF <lfs_borrowed>-BorrowDate IS INITIAL.
        APPEND VALUE #( %tky = <lfs_borrowed>-%tky ) TO failed-borrowred.
        APPEND VALUE #( %tky = <lfs_borrowed>-%tky
                        %element-BorrowDate = if_abap_behv=>mk-on
                        %state_area         = 'BORROWEDDATE'
                        %path               = VALUE #(  book-bookid    = <lfs_borrowed>-BookId
                                                        book-%is_draft = <lfs_borrowed>-%is_draft  )
                        %msg = NEW zdpd_cl_msg(
                                      textid    = zdpd_cl_msg=>borrowdate_null
                                      borrow_date  = <lfs_borrowed>-BorrowDate
                                      severity  = if_abap_behv_message=>severity-error
                            )
                        ) TO reported-borrowred.

      ELSE.
        IF <lfs_borrowed>-BorrowDate < cl_abap_context_info=>get_system_date(  ).
          APPEND VALUE #( %tky = <lfs_borrowed>-%tky ) TO failed-borrowred.
          APPEND VALUE #( %tky = <lfs_borrowed>-%tky
                          %element-BorrowDate = if_abap_behv=>mk-on
                          %state_area         = 'BORROWEDDATE'
                          %path               = VALUE #(  book-bookid    = <lfs_borrowed>-BookId
                                                          book-%is_draft = <lfs_borrowed>-%is_draft  )
                          %msg = NEW zdpd_cl_msg(
                                        textid    = zdpd_cl_msg=>borrow_date_on_or_af_sysdate
                                        borrow_date  = <lfs_borrowed>-BorrowDate
                                        severity  = if_abap_behv_message=>severity-error
                              )
                          ) TO reported-borrowred.
        ENDIF.
      ENDIF.

      IF <lfs_borrowed>-BorrowDate IS NOT INITIAL AND <lfs_borrowed>-ReturnDate IS NOT INITIAL.
        IF <lfs_borrowed>-BorrowDate > <lfs_borrowed>-ReturnDate.
          APPEND VALUE #( %tky = <lfs_borrowed>-%tky ) TO failed-borrowred.
          APPEND VALUE #( %tky = <lfs_borrowed>-%tky
                          %element-BorrowDate = if_abap_behv=>mk-on
                          %state_area         = 'BORROWEDDATE'
                          %path               = VALUE #(  book-bookid    = <lfs_borrowed>-BookId
                                                          book-%is_draft = <lfs_borrowed>-%is_draft  )
                          %msg = NEW zdpd_cl_msg(
                                        textid    = zdpd_cl_msg=>borrow_date_bef_return_date
                                        borrow_date  = <lfs_borrowed>-BorrowDate
                                        return_date = <lfs_borrowed>-ReturnDate
                                        severity  = if_abap_behv_message=>severity-error
                              )
                          ) TO reported-borrowred.
        ENDIF.
      ENDIF.

      " Return Date
      APPEND VALUE #( %tky        = <lfs_borrowed>-%tky
                      %state_area = 'RETURNDATE'
                         ) TO reported-borrowred.
      IF <lfs_borrowed>-ReturnDate IS INITIAL.
        APPEND VALUE #( %tky = <lfs_borrowed>-%tky ) TO failed-borrowred.
        APPEND VALUE #( %tky = <lfs_borrowed>-%tky
                        %element-ReturnDate = if_abap_behv=>mk-on
                        %state_area         = 'RETURNDATE'
                        %path               = VALUE #(  book-bookid    = <lfs_borrowed>-BookId
                                                        book-%is_draft = <lfs_borrowed>-%is_draft  )
                        %msg = NEW zdpd_cl_msg(
                                      textid    = zdpd_cl_msg=>returndate_null
                                      return_date  = <lfs_borrowed>-ReturnDate
                                      severity  = if_abap_behv_message=>severity-error
                            )
                        ) TO reported-borrowred.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD ReturnBook.

    READ ENTITIES OF zpdp_i_book IN LOCAL MODE
    ENTITY Borrowred
    ALL FIELDS
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_Borrowred).

    DELETE lt_Borrowred WHERE Status = 'R'.
    CHECK lt_Borrowred IS NOT INITIAL.

*   " modify travel instance
    MODIFY ENTITIES OF zpdp_i_book IN LOCAL MODE
    ENTITY Borrowred
    UPDATE FIELDS ( Status ActualReturnDate )
    WITH VALUE #( FOR ls_Borrow IN lt_Borrowred ( %tky  = ls_Borrow-%tky
                                                  %is_draft = ls_Borrow-%is_draft
                                                  Status = 'R'
                                                  ActualReturnDate = cl_abap_context_info=>get_system_date(  )
                                    ) )
     FAILED failed
     REPORTED reported.

    " read changed data for action result
    READ ENTITIES OF zpdp_i_book IN LOCAL MODE
    ENTITY Borrowred
    ALL FIELDS WITH
    CORRESPONDING #( keys )
    RESULT DATA(Borrowred).

    " set the action result parameter
    result = VALUE #( FOR ls_borrowred IN Borrowred ( %tky      = ls_borrowred-%tky
                                                      %is_draft = ls_borrowred-%is_draft
                                                      %param    = ls_borrowred ) ).


*UPDATE QUANTITY WHEN RETURN BOOK
*    DATA: lt_books       TYPE TABLE FOR UPDATE zpdp_i_book\\Book.
*    READ ENTITIES OF zpdp_i_book IN LOCAL MODE
*    ENTITY Book
*    ALL FIELDS WITH CORRESPONDING #( lt_Borrowred )
*    RESULT DATA(lt_read_books).
*
*    LOOP AT lt_read_books ASSIGNING FIELD-SYMBOL(<lfs_read_books>) GROUP BY <lfs_read_books>-BookId.
*      LOOP AT lt_borrowred INTO DATA(ls_borrwed) WHERE bookid = <lfs_read_books>-BookId.
*        <lfs_read_books>-Quantity += ls_borrwed-Quantity.
*      ENDLOOP.
*
*      APPEND VALUE #( %tky      = <lfs_read_books>-%tky
*                      %is_draft = <lfs_read_books>-%is_draft
*                      %data     = CORRESPONDING #( <lfs_read_books> ) ) TO lt_books
*          ASSIGNING FIELD-SYMBOL(<lfs_book>).
*
*    ENDLOOP.
*
*    MODIFY ENTITIES OF zpdp_i_book IN LOCAL MODE
*    ENTITY Book
*    UPDATE FIELDS ( Quantity )
*    WITH lt_books
*    MAPPED DATA(mapped_update)
*    FAILED failed
*    REPORTED reported.
*
*    mapped-book = mapped_update-book.

  ENDMETHOD.

  METHOD Lost.

    READ ENTITIES OF zpdp_i_book IN LOCAL MODE
      ENTITY Borrowred
      ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_Borrowred).

    DELETE lt_Borrowred WHERE Status = 'L' OR Status = 'R'.


*   " modify travel instance
    MODIFY ENTITIES OF zpdp_i_book IN LOCAL MODE
    ENTITY Borrowred
    UPDATE FIELDS ( Status ActualReturnDate )
    WITH VALUE #( FOR ls_Borrow IN lt_Borrowred ( %tky      = ls_Borrow-%tky
                                                  %is_draft = ls_Borrow-%is_draft
                                                  Status    = 'L'
                                                  ) )
     FAILED failed
     REPORTED reported.

    " read changed data for action result
    READ ENTITIES OF zpdp_i_book IN LOCAL MODE
    ENTITY Borrowred
    ALL FIELDS WITH
    CORRESPONDING #( keys )
    RESULT DATA(Borrowred).

    " set the action result parameter
    result = VALUE #( FOR ls_borrowred IN Borrowred ( %tky   = ls_borrowred-%tky
                                                      %is_draft = ls_borrowred-%is_draft
                                                      %param = ls_borrowred ) ).

  ENDMETHOD.

  METHOD calculateQuantity.
    DATA: lv_quan      TYPE zdp_tb_borrowed-quantity,
          lv_old_quan  TYPE zdp_tb_borrowed-quantity,
          lv_diff_quan TYPE zdp_tb_borrowed-quantity.

    READ ENTITIES OF zpdp_i_book IN LOCAL MODE
      ENTITY Book
      ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_books).

    READ ENTITIES OF zpdp_i_book IN LOCAL MODE
    ENTITY Borrowred
    FIELDS ( Quantity )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_borroweds).

    SELECT t1~book_id
          ,SUM( t1~quantity ) AS quantity
    FROM zdp_tb_borrowed AS t1
        INNER JOIN @lt_borroweds AS t2
                ON t1~book_id          = t2~BookId
               AND t1~borrowed_book_id = t2~BorrowedBookId
    WHERE t1~borrowed_status NE 'R' AND borrowed_status NE 'L'
    GROUP BY t1~book_id
    INTO TABLE @DATA(lt_old_borrwed).
*
    DELETE lt_borroweds WHERE Status EQ 'R' OR ( Status NE space AND Status NE 'L' ).

    LOOP AT lt_books ASSIGNING FIELD-SYMBOL(<lfs_book>) GROUP BY <lfs_book>-BookId.

      CLEAR: lv_old_quan.
      READ TABLE lt_old_borrwed INTO DATA(ls_old_borrwed) WITH KEY book_id = <lfs_book>-BookId.
      IF sy-subrc EQ 0.
        lv_old_quan = ls_old_borrwed-quantity.
      ENDIF.

      LOOP AT lt_borroweds INTO DATA(ls_borrowed) WHERE BookId = <lfs_book>-BookId.
        lv_quan += ls_borrowed-Quantity.
      ENDLOOP.

      CLEAR: lv_diff_quan.
      lv_diff_quan = lv_old_quan - lv_quan.
      <lfs_book>-Quantity = <lfs_book>-Quantity + lv_old_quan - lv_quan.
    ENDLOOP.

    MODIFY ENTITIES OF zpdp_i_book IN LOCAL MODE
    ENTITY Book
    UPDATE FIELDS ( Quantity )
    WITH CORRESPONDING #( lt_books ).

  ENDMETHOD.

  METHOD get_user_data.
    READ ENTITIES OF zpdp_i_book IN LOCAL MODE
     ENTITY Book
     BY \_Borrowed
     ALL FIELDS WITH CORRESPONDING #( keys )
     RESULT DATA(lt_borrowed).

    SELECT
    FROM zdp_tb_user AS t1
    INNER JOIN @lt_borrowed AS t2
      ON t1~user_id = t2~UserId
      FIELDS
      t1~user_id,
      t1~name,
      t1~membership_number
      INTO TABLE @DATA(lt_user).
    IF sy-subrc = 0.
      SORT lt_user BY user_id.
      LOOP AT lt_borrowed ASSIGNING FIELD-SYMBOL(<lfs_borrowed>).
        CLEAR: <lfs_borrowed>-UserMembership.
        READ TABLE lt_user INTO DATA(ls_user)
                           WITH KEY user_id = <lfs_borrowed>-UserId
                           BINARY SEARCH.
        IF sy-subrc = 0.
          <lfs_borrowed>-UserMembership = ls_user-membership_number.
        ENDIF.
      ENDLOOP.

      MODIFY ENTITIES OF zpdp_i_book IN LOCAL MODE
      ENTITY Borrowred
      UPDATE FIELDS ( UserMembership )
      WITH CORRESPONDING #( lt_borrowed )
      FAILED DATA(lt_failed).
    ENDIF.
  ENDMETHOD.

  METHOD get_instance_features.

    "Step1:
    READ ENTITIES OF zpdp_i_book IN LOCAL MODE
    ENTITY book BY \_Borrowed
    FIELDS ( BookId BorrowedBookId Status  )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_borrowed)
    FAILED failed.

    DELETE lt_borrowed WHERE Status  <> 'L' AND Status  <> 'R'.
*
    " Step2
    LOOP AT lt_borrowed INTO DATA(ls_borrowed).
      result[] = VALUE #( BASE result
                         ( %tky = ls_borrowed-%tky
                           %is_draft = ls_borrowed-%is_draft
                           %features-%update = if_abap_behv=>fc-o-disabled
                          ) ).
    ENDLOOP.

  ENDMETHOD.
ENDCLASS.

CLASS lhc_Book DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Book RESULT result.
    METHODS validatebook FOR VALIDATE ON SAVE
      IMPORTING keys FOR book~validatebook.
    METHODS copybook FOR MODIFY
      IMPORTING keys FOR ACTION book~copybook.
    METHODS deactivebook FOR MODIFY
      IMPORTING keys FOR ACTION book~deactivebook RESULT result.
    METHODS activebook FOR MODIFY
      IMPORTING keys FOR ACTION book~activebook RESULT result.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR book RESULT result.
    METHODS get_publisher_data FOR DETERMINE ON MODIFY
      IMPORTING keys FOR book~get_publisher_data.
    METHODS get_author_data FOR DETERMINE ON MODIFY
      IMPORTING keys FOR book~get_author_data.
    METHODS earlynumbering_cba_borrowed FOR NUMBERING
      IMPORTING entities FOR CREATE book\_borrowed.

    METHODS earlynumbering_cba_image FOR NUMBERING
      IMPORTING entities FOR CREATE book\_image.
    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE book.

ENDCLASS.

CLASS lhc_Book IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD earlynumbering_create.

    DATA: entity      TYPE STRUCTURE FOR CREATE zpdp_i_book,
          book_id_max TYPE zdp_tb_book-book_id.

    LOOP AT entities INTO entity WHERE BookId IS NOT INITIAL.
      APPEND CORRESPONDING #( entity ) TO mapped-book.
    ENDLOOP.

    DATA(entities_wo_bookid) = entities.
    DELETE entities_wo_bookid WHERE BookId IS NOT INITIAL.

    TRY.
        cl_numberrange_runtime=>number_get(
          EXPORTING
*            ignore_buffer     =
            nr_range_nr       = '01'
            object            = CONV #( 'ZR_BOOKID' )
            quantity          = CONV #( lines( entities_wo_bookid ) )
          IMPORTING
            number            = DATA(number_range_key)
            returncode        = DATA(number_range_return_code)
            returned_quantity = DATA(number_range_returned_quantity)
        ).
*        CATCH cx_nr_object_not_found.
*        CATCH cx_number_ranges.
      CATCH cx_number_ranges INTO DATA(lx_number_ranges).
        "" step3: If there is an exception, throw error
        LOOP AT entities_wo_bookid INTO entity.
          APPEND VALUE #( %cid = entity-%cid
                          %key = entity-%key
                          %msg = lx_number_ranges  )
                          TO reported-book.
          APPEND VALUE #( %cid = entity-%cid
                          %key = entity-%key )
                          TO failed-book.
        ENDLOOP.
        EXIT.
    ENDTRY.

    CASE number_range_return_code.
      WHEN '1'.
        "" Step4: Handle especial cases where number range exceed critical %
        LOOP AT entities_wo_bookid INTO entity.
          APPEND VALUE #( %cid = entity-%cid
                          %msg = NEW /dmo/cm_flight_messages(
                          textid = /dmo/cm_flight_messages=>number_range_depleted
                          severity = if_abap_behv_message=>severity-warning ) )
                          TO reported-book.
        ENDLOOP.
      WHEN '2' OR '3'.
        "" Step5: The number range return last number , or number exhaused
        LOOP AT entities_wo_bookid INTO entity.
          APPEND VALUE #( %cid = entity-%cid
                          %msg = NEW /dmo/cm_flight_messages(
                          textid = /dmo/cm_flight_messages=>not_sufficient_numbers
                          severity = if_abap_behv_message=>severity-warning ) )
                          TO reported-book.
          APPEND VALUE #( %cid = entity-%cid
                          %key = entity-%key
                          %fail-cause = if_abap_behv=>cause-conflict )
                          TO failed-book.
        ENDLOOP.
    ENDCASE.

    "" Step6: Final check for all numbers
    ASSERT number_range_returned_quantity = lines( entities_wo_bookid ).

    "" Step7: Loop over the incoming travel data and assign the numbers from number range and retuen MAPPED data
    book_id_max = number_range_key - number_range_returned_quantity.
    LOOP AT entities_wo_bookid INTO entity.
      book_id_max += 1.
      entity-BookId = book_id_max.

      APPEND VALUE #( %cid = entity-%cid
                      %is_draft  = entity-%is_draft
                      %key = entity-%key ) TO mapped-book.
    ENDLOOP.

  ENDMETHOD.

  METHOD earlynumbering_cba_Borrowed.
    DATA: lv_borrowed_max TYPE zdp_tb_borrowed-borrowed_book_id.

    READ ENTITIES OF zpdp_c_book
    ENTITY Book BY \_Borrowed
    ALL FIELDS WITH CORRESPONDING #( entities )
    RESULT DATA(lt_Borrowed).

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<lfs_book>) GROUP BY <lfs_book>-BookId.
      lv_borrowed_max = REDUCE #( INIT max = CONV zdp_tb_borrowed-borrowed_book_id( '0' )
                                  FOR ls_Borrowed IN lt_Borrowed
                                  WHERE ( BookId = <lfs_book>-BookId )
                                  NEXT max = COND #( WHEN max < ls_Borrowed-BorrowedBookId
                                                      THEN ls_Borrowed-BorrowedBookId
                                                      ELSE max )
                                   ).

      lv_borrowed_max = REDUCE #( INIT max = lv_borrowed_max
                                  FOR ls_book IN entities USING KEY entity WHERE ( BookId = <lfs_book>-BookId )
                                  FOR ls_target IN ls_book-%target
                                  NEXT max = COND #( WHEN max < ls_target-BorrowedBookId
                                               THEN ls_target-BorrowedBookId
                                               ELSE max )

                                ).

      LOOP AT entities ASSIGNING FIELD-SYMBOL(<book>) USING KEY entity
            WHERE BookId = <lfs_book>-BookId.
        LOOP AT <book>-%target ASSIGNING FIELD-SYMBOL(<borrowed_wo_number>).
          APPEND CORRESPONDING #( <borrowed_wo_number> ) TO mapped-borrowred
          ASSIGNING FIELD-SYMBOL(<mapped_borrowred>).
          IF <mapped_borrowred>-BorrowedBookId IS INITIAL.
            lv_borrowed_max += 10.
            <mapped_borrowred>-BorrowedBookId = lv_borrowed_max.
          ENDIF.
        ENDLOOP.
      ENDLOOP.
    ENDLOOP.

  ENDMETHOD.

  METHOD earlynumbering_cba_Image.
    DATA: lv_image_max TYPE zdp_tb_image-image_id.

    READ ENTITIES OF zpdp_i_book IN LOCAL MODE
    ENTITY Book BY \_Image
    ALL FIELDS WITH CORRESPONDING #( entities )
    RESULT DATA(lt_images).

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<lfs_book>) GROUP BY <lfs_book>-BookId.
      lv_image_max = REDUCE #( INIT max = CONV zdp_tb_image-image_id( '0' )
                                        FOR ls_images IN lt_images
                                        WHERE ( BookId = <lfs_book>-BookId )
                                        NEXT max = COND #( WHEN max < ls_images-ImageId
                                                            THEN ls_images-ImageId
                                                            ELSE max )
                                         ).

      lv_image_max = REDUCE #( INIT max = lv_image_max
                                  FOR ls_image IN entities USING KEY entity WHERE ( BookId = <lfs_book>-BookId )
                                  FOR ls_target IN ls_image-%target
                                  NEXT max = COND #( WHEN max < ls_target-ImageId
                                               THEN ls_target-ImageId
                                               ELSE max )

                                ).

      LOOP AT entities ASSIGNING FIELD-SYMBOL(<book>) USING KEY entity  WHERE bookid = <lfs_book>-BookId.
        LOOP AT <book>-%target ASSIGNING FIELD-SYMBOL(<image_wo_number>).
          APPEND CORRESPONDING #( <image_wo_number> ) TO mapped-image
          ASSIGNING FIELD-SYMBOL(<mapped_image>).
          IF <mapped_image>-ImageId IS INITIAL.
            lv_image_max += 1.
            <mapped_image>-ImageId = lv_image_max.
          ENDIF.
        ENDLOOP.
      ENDLOOP.
    ENDLOOP.

  ENDMETHOD.

  METHOD validateBook.

    READ ENTITIES OF zpdp_i_book IN LOCAL MODE
    ENTITY Book
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_books).

    CHECK lt_books IS NOT INITIAL.

    "
    SELECT *
    FROM zdp_tb_book
    INTO TABLE @DATA(lt_book_isbn).

    " Status
    SELECT *
    FROM zdp_tb_status
    FOR ALL ENTRIES IN @lt_books
    WHERE status = @lt_books-Status
    INTO TABLE @DATA(lt_status).

    " Genre
    SELECT *
    FROM zdp_tb_genre
    FOR ALL ENTRIES IN @lt_books
    WHERE genre_id = @lt_books-Genre
    INTO TABLE @DATA(lt_genre).

    " Publish
    SELECT *
    FROM zdp_tb_publisher
    FOR ALL ENTRIES IN @lt_books
    WHERE publisher_id  = @lt_books-PublisherId
    INTO TABLE @DATA(lt_publisher).


    " Author
    SELECT *
           FROM zdp_tb_author
           FOR ALL ENTRIES IN @lt_books
           WHERE author_id  = @lt_books-AuthorId
           INTO TABLE @DATA(lt_author).

    LOOP AT lt_books ASSIGNING FIELD-SYMBOL(<lfs_book>).
      " Status
      APPEND VALUE #( %tky        = <lfs_book>-%tky
                      %state_area = 'STATUS'
                         ) TO reported-book.
      IF <lfs_book>-Status IS INITIAL.
        APPEND VALUE #( %tky = <lfs_book>-%tky ) TO failed-book.
        APPEND VALUE #( %tky = <lfs_book>-%tky
                        %element-status = if_abap_behv=>mk-on
                        %state_area     = 'STATUS'
                        %msg = NEW zdpd_cl_msg(
                                      textid      = zdpd_cl_msg=>status_null
                                      status      = <lfs_book>-Status
                                      severity    = if_abap_behv_message=>severity-error
                            )
                        ) TO reported-book.

      ELSE.
        IF ( NOT line_exists( lt_status[ status = <lfs_book>-Status ] ) ).
          APPEND VALUE #( %tky = <lfs_book>-%tky ) TO failed-book.
          APPEND VALUE #( %tky = <lfs_book>-%tky
                          %element-status = if_abap_behv=>mk-on
                          %state_area     = 'STATUS'
                          %msg = NEW zdpd_cl_msg(
                                        textid      = zdpd_cl_msg=>status_unkown
                                        status      = <lfs_book>-Status
                                        severity    = if_abap_behv_message=>severity-error
                              )
                          ) TO reported-book.
        ENDIF.
      ENDIF.

      " Quantity
      APPEND VALUE #( %tky        = <lfs_book>-%tky
                      %state_area = 'QUANTITY'
                         ) TO reported-book.
      IF <lfs_book>-Quantity < 0.
        APPEND VALUE #( %tky = <lfs_book>-%tky ) TO failed-book.
        APPEND VALUE #( %tky = <lfs_book>-%tky
                        %element-quantity = if_abap_behv=>mk-on
                        %state_area       = 'QUANTITY'
                        %msg = NEW zdpd_cl_msg(
                                      textid      = zdpd_cl_msg=>quantity_minus
                                      quantity      = <lfs_book>-Quantity
                                      severity    = if_abap_behv_message=>severity-error
                            )
                        ) TO reported-book.
      ENDIF.

      " Genre
      APPEND VALUE #( %tky        = <lfs_book>-%tky
                      %state_area = 'GENRE'
                         ) TO reported-book.
      IF <lfs_book>-Genre IS INITIAL.
        APPEND VALUE #( %tky = <lfs_book>-%tky ) TO failed-book.
        APPEND VALUE #( %tky = <lfs_book>-%tky
                        %element-genre = if_abap_behv=>mk-on
                        %state_area    = 'GENRE'
                        %msg = NEW zdpd_cl_msg(
                                      textid      = zdpd_cl_msg=>genre_null
                                      Genre      = <lfs_book>-Genre
                                      severity    = if_abap_behv_message=>severity-error
                            )
                        ) TO reported-book.

      ELSE.
        IF ( NOT line_exists( lt_genre[ genre_id = <lfs_book>-Genre ] ) ).
          APPEND VALUE #( %tky = <lfs_book>-%tky ) TO failed-book.
          APPEND VALUE #( %tky = <lfs_book>-%tky
                          %element-genre = if_abap_behv=>mk-on
                          %state_area    = 'GENRE'
                          %msg = NEW zdpd_cl_msg(
                                        textid      = zdpd_cl_msg=>genre_unkown
                                        genre      = <lfs_book>-Genre
                                        severity    = if_abap_behv_message=>severity-error
                              )
                          ) TO reported-book.
        ENDIF.
      ENDIF.

      " Title
      APPEND VALUE #( %tky        = <lfs_book>-%tky
                      %state_area = 'TITLE'
                         ) TO reported-book.
      IF <lfs_book>-Title IS INITIAL.
        APPEND VALUE #( %tky = <lfs_book>-%tky ) TO failed-book.
        APPEND VALUE #( %tky = <lfs_book>-%tky
                        %element-title = if_abap_behv=>mk-on
                        %state_area    = 'TITLE'
                        %msg = NEW zdpd_cl_msg(
                                      textid      = zdpd_cl_msg=>title_null
                                      title      = <lfs_book>-Title
                                      severity    = if_abap_behv_message=>severity-error
                            )
                        ) TO reported-book.
      ENDIF.

      " ISBN
      APPEND VALUE #( %tky        = <lfs_book>-%tky
                      %state_area = 'ISBN'
                         ) TO reported-book.
      IF <lfs_book>-Isbn IS INITIAL.
        APPEND VALUE #( %tky = <lfs_book>-%tky ) TO failed-book.
        APPEND VALUE #( %tky = <lfs_book>-%tky
                        %element-isbn = if_abap_behv=>mk-on
                        %state_area   = 'ISBN'
                        %msg = NEW zdpd_cl_msg(
                                      textid      = zdpd_cl_msg=>isbn_null
                                      isbn      = <lfs_book>-Isbn
                                      severity    = if_abap_behv_message=>severity-error
                            )
                        ) TO reported-book.
      ELSE.
        DELETE lt_book_isbn WHERE book_id = <lfs_book>-BookId.
        IF ( line_exists( lt_book_isbn[ Isbn = <lfs_book>-Isbn ] ) ).
          APPEND VALUE #( %tky = <lfs_book>-%tky ) TO failed-book.
          APPEND VALUE #( %tky = <lfs_book>-%tky
                          %element-isbn = if_abap_behv=>mk-on
                          %state_area   = 'ISBN'
                          %msg = NEW zdpd_cl_msg(
                                        textid      = zdpd_cl_msg=>isbn_duplicate
                                        isbn      = <lfs_book>-Isbn
                                        severity    = if_abap_behv_message=>severity-error
                              )
                          ) TO reported-book.
        ENDIF.
      ENDIF.

      "Publisher
      APPEND VALUE #( %tky        = <lfs_book>-%tky
                      %state_area = 'PUBLISHER'
                        ) TO reported-book.
      IF <lfs_book>-PublisherId IS INITIAL.
        APPEND VALUE #( %tky = <lfs_book>-%tky ) TO failed-book.
        APPEND VALUE #( %tky = <lfs_book>-%tky
                        %element-publisherid = if_abap_behv=>mk-on
                        %state_area          = 'PUBLISHER'
                        %msg = NEW zdpd_cl_msg(
                                      textid       = zdpd_cl_msg=>publisher_null
                                      publisher_id = <lfs_book>-PublisherId
                                      severity     = if_abap_behv_message=>severity-error
                            )
                        ) TO reported-book.
      ELSE.
        IF ( NOT line_exists( lt_publisher[ publisher_id = <lfs_book>-PublisherId ] ) ).
          APPEND VALUE #( %tky = <lfs_book>-%tky ) TO failed-book.
          APPEND VALUE #( %tky = <lfs_book>-%tky
                          %element-publisherid = if_abap_behv=>mk-on
                          %state_area          = 'PUBLISHER'
                          %msg = NEW zdpd_cl_msg(
                                        textid       = zdpd_cl_msg=>publisher_unkown
                                        publisher_id = <lfs_book>-PublisherId
                                        severity     = if_abap_behv_message=>severity-error
                              )
                          ) TO reported-book.
        ENDIF.
      ENDIF.

      " Author
      APPEND VALUE #( %tky        = <lfs_book>-%tky
                      %state_area = 'AUTHOR'
                         ) TO reported-book.
      IF <lfs_book>-AuthorId IS INITIAL.
        APPEND VALUE #( %tky = <lfs_book>-%tky ) TO failed-book.
        APPEND VALUE #( %tky = <lfs_book>-%tky
                        %element-AuthorId = if_abap_behv=>mk-on
                        %state_area       = 'AUTHOR'
                        %msg = NEW zdpd_cl_msg(
                                      textid       = zdpd_cl_msg=>author_null
                                      auhtor_id = <lfs_book>-AuthorId
                                      severity     = if_abap_behv_message=>severity-error
                            )
                        ) TO reported-book.
      ELSE.
        IF ( NOT line_exists( lt_author[ author_id = <lfs_book>-AuthorId ] ) ).
          APPEND VALUE #( %tky = <lfs_book>-%tky ) TO failed-book.
          APPEND VALUE #( %tky = <lfs_book>-%tky
                          %element-AuthorId = if_abap_behv=>mk-on
                          %state_area       = 'AUTHOR'
                          %msg = NEW zdpd_cl_msg(
                                        textid       = zdpd_cl_msg=>author_unkown
                                        auhtor_id    = <lfs_book>-AuthorId
                                        severity     = if_abap_behv_message=>severity-error
                              )
                          ) TO reported-book.
        ENDIF.
      ENDIF.

      "Publish On
      APPEND VALUE #( %tky        = <lfs_book>-%tky
                      %state_area = 'PUBLICATIONDATE'
                         ) TO reported-book.
      IF <lfs_book>-PublicationDate IS NOT INITIAL.
        IF <lfs_book>-PublicationDate > cl_abap_context_info=>get_system_date(  ).
          APPEND VALUE #( %tky = <lfs_book>-%tky ) TO failed-book.
          APPEND VALUE #( %tky = <lfs_book>-%tky
                          %element-PublicationDate = if_abap_behv=>mk-on
                          %state_area = 'PUBLICATIONDATE'
                          %msg = NEW zdpd_cl_msg(
                                        textid       = zdpd_cl_msg=>publish_date_on_or_bef_sysdate
                                        publish_date = <lfs_book>-PublicationDate
                                        severity     = if_abap_behv_message=>severity-error
                              )
                          ) TO reported-book.
        ENDIF.

      ENDIF.

      " Rating
      APPEND VALUE #( %tky        = <lfs_book>-%tky
                      %state_area = 'RATING'
                         ) TO reported-book.
      IF <lfs_book>-Rating IS NOT INITIAL.
        IF <lfs_book>-Rating NOT BETWEEN 1 AND 5.
          APPEND VALUE #( %tky = <lfs_book>-%tky ) TO failed-book.
          APPEND VALUE #( %tky = <lfs_book>-%tky
                          %element-Rating = if_abap_behv=>mk-on
                          %state_area = 'RATING'
                          %msg = NEW zdpd_cl_msg(
                                        textid       = zdpd_cl_msg=>rating_invalid
                                        severity     = if_abap_behv_message=>severity-error
                              )
                          ) TO reported-book.
        ENDIF.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.

  METHOD copyBook.
    DATA: lt_books       TYPE TABLE FOR CREATE zpdp_i_book\\Book.

    READ TABLE keys WITH KEY %cid = '' INTO DATA(key_with_initial_cid).
    ASSERT key_with_initial_cid IS INITIAL.

    READ ENTITIES OF zpdp_i_book IN LOCAL MODE
    ENTITY book
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(book_read_result)
    FAILED failed.

    LOOP AT book_read_result ASSIGNING FIELD-SYMBOL(<lfs_read_book>).
      APPEND VALUE #( %cid = keys[ KEY id %tky = <lfs_read_book>-%tky ]-%cid
                      %is_draft = if_abap_behv=>mk-on
                      %data = CORRESPONDING #( <lfs_read_book> "EXCEPT bookid isbn
                     ) ) TO lt_books
          ASSIGNING FIELD-SYMBOL(<lfs_book>).
      <lfs_book>-CreatedBy = cl_abap_context_info=>get_user_technical_name( ).
      <lfs_book>-CreatedOn = cl_abap_context_info=>get_system_date( ).
    ENDLOOP.

    MODIFY ENTITIES OF zpdp_i_book IN LOCAL MODE
    ENTITY Book
            CREATE FIELDS ( " Title
                            Quantity
                            Status
                            Genre
                            Rating
                            PublisherId
                            PublicationDate
                            AuthorId  )
            WITH lt_books
     MAPPED DATA(mapped_create).

    mapped-book = mapped_create-book.

  ENDMETHOD.


  METHOD DeactiveBook.

    " modify travel instance
    MODIFY ENTITIES OF zpdp_i_book IN LOCAL MODE
       ENTITY Book
       UPDATE FIELDS ( Status )
       WITH VALUE #( FOR key IN keys ( %tky          = key-%tky
                                       Status = 'X' ) )
    FAILED failed
    REPORTED reported.

    " read changed data for action result
    READ ENTITIES OF zpdp_i_book IN LOCAL MODE
       ENTITY Book
       ALL FIELDS WITH
       CORRESPONDING #( keys )
       RESULT DATA(books).

    " set the action result parameter
    result = VALUE #( FOR book IN books ( %tky      = book-%tky
                                          %is_draft = book-%is_draft
                                          %param    = Book ) ).

  ENDMETHOD.

  METHOD ActiveBook.
    " modify travel instance
    MODIFY ENTITIES OF zpdp_i_book IN LOCAL MODE
       ENTITY Book
       UPDATE FIELDS ( Status )
       WITH VALUE #( FOR key IN keys ( %tky          = key-%tky
                                       Status = 'O' ) )
    FAILED failed
    REPORTED reported.

    " read changed data for action result
    READ ENTITIES OF zpdp_i_book IN LOCAL MODE
       ENTITY Book
       ALL FIELDS WITH
       CORRESPONDING #( keys )
       RESULT DATA(books).

    " set the action result parameter
    result = VALUE #( FOR book IN books ( %tky   = book-%tky
                                          %is_draft = book-%is_draft
                                          %param = Book ) ).
  ENDMETHOD.

  METHOD get_instance_features.

    " For Borrowed Book
    READ ENTITIES OF zpdp_i_book IN LOCAL MODE
    ENTITY book
    FIELDS ( bookid Status Quantity )
    WITH CORRESPONDING #( keys )
    RESULT DATA(Books)
    FAILED failed.

    " Step2: Return the result with booking creation possible or not
    READ TABLE Books INTO DATA(ls_book) INDEX 1.

    DATA(lv_allow) = COND #( WHEN ls_book-Status = 'X' THEN if_abap_behv=>fc-o-disabled
                                                        ELSE if_abap_behv=>fc-o-enabled ).

    IF lv_allow EQ if_abap_behv=>fc-o-enabled.
      lv_allow = COND #( WHEN ls_book-Quantity = 0 THEN if_abap_behv=>fc-o-disabled
                                                    ELSE if_abap_behv=>fc-o-enabled ).
    ENDIF.

    " For Image

    result = VALUE #( FOR book IN Books
                      ( %tky = book-%tky
                        %assoc-_Borrowed = lv_allow ) ).

  ENDMETHOD.


  METHOD get_publisher_data.

    READ ENTITIES OF zpdp_i_book IN LOCAL MODE
      ENTITY Book
      FIELDS ( BookId PublisherId )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_book).

    SELECT
    FROM zdp_tb_publisher AS t1
    INNER JOIN @lt_book AS t2 ON
        t1~publisher_id = t2~PublisherId
     FIELDS t1~publisher_id,
            t1~address,
            t1~name
     INTO TABLE @DATA(lt_publisher).
    IF sy-subrc = 0.
    ENDIF.

    SORT lt_publisher BY publisher_id.
    LOOP AT lt_book ASSIGNING FIELD-SYMBOL(<lfs_book>).
      CLEAR: <lfs_book>-PublisherAddr.
      READ TABLE lt_publisher INTO DATA(ls_publisher)
                           WITH KEY publisher_id = <lfs_book>-PublisherId
                           BINARY SEARCH.
      IF sy-subrc = 0.
        <lfs_book>-PublisherAddr = ls_publisher-address.
      ENDIF.
    ENDLOOP.
    MODIFY ENTITIES OF zpdp_i_book IN LOCAL MODE
      ENTITY Book
        UPDATE  FIELDS ( PublisherAddr  )
        WITH VALUE #( FOR ls_book IN lt_book
        (
         %tky             = ls_book-%tky
         PublisherAddr    = ls_book-PublisherAddr
        ) ).



  ENDMETHOD.

  METHOD get_author_data.
    READ ENTITIES OF zpdp_i_book IN LOCAL MODE
      ENTITY Book
      FIELDS ( BookId AuthorId )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_book).

    SELECT
    FROM zdp_tb_author AS t1
    INNER JOIN @lt_book AS t2 ON
        t1~author_id = t2~AuthorId
     FIELDS t1~author_id,
            t1~country,
            t1~name
     INTO TABLE @DATA(lt_author).
    IF sy-subrc = 0.
    ENDIF.

    SORT lt_author BY author_id.
    LOOP AT lt_book ASSIGNING FIELD-SYMBOL(<lfs_book>).
      CLEAR:  <lfs_book>-AuthorCountry.
      READ TABLE lt_author INTO DATA(ls_author)
                           WITH KEY author_id = <lfs_book>-AuthorId
                           BINARY SEARCH.
      IF sy-subrc = 0.
        <lfs_book>-AuthorCountry = ls_author-country.
      ENDIF.
    ENDLOOP.
    MODIFY ENTITIES OF zpdp_i_book IN LOCAL MODE
      ENTITY Book
        UPDATE  FIELDS ( AuthorCountry )
        WITH VALUE #( FOR ls_book IN lt_book
        (
         %tky          = ls_book-%tky
         AuthorCountry = ls_book-AuthorCountry
        ) ).

  ENDMETHOD.


ENDCLASS.
