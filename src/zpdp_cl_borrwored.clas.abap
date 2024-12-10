CLASS zpdp_cl_borrwored DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_sadl_exit_calc_element_read .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZPDP_CL_BORRWORED IMPLEMENTATION.


  METHOD if_sadl_exit_calc_element_read~calculate.
    DATA: lt_original_data TYPE STANDARD TABLE OF zpdp_c_borrowred WITH DEFAULT KEY.

    DATA(lv_curr_date) = cl_abap_context_info=>get_system_date(  ).

    lt_original_data = CORRESPONDING #( it_original_data ).

*    READ ENTITIES OF zpdp_c_book
*    ENTITY Borrowred
*    ALL FIELDS WITH CORRESPONDING #( lt_original_data  )
*    RESULT DATA(lt_read_borrowed)
*    FAILED DATA(lt_failed).
    SELECT book_id AS BookId
          ,borrowed_book_id AS BorrowedBookId
          ,borrowed_status AS status
    FROM zdp_tb_borrowed
    FOR ALL ENTRIES IN @lt_original_data
    WHERE book_id = @lt_original_data-BookId
      AND borrowed_book_id = @lt_original_data-BorrowedBookId
    INTO TABLE @DATA(lt_read_borrowed).


    SELECT *
    FROM ZPDP_borrowed_STATUS_VH
    INTO TABLE @DATA(lt_borrowed_status).
    SORT lt_borrowed_status BY Status.

    DATA: lv_status TYPE c.
    LOOP AT lt_original_data ASSIGNING FIELD-SYMBOL(<lfs_org_data>).
      CLEAR: lv_status.
      READ TABLE lt_read_borrowed INTO DATA(ls_read) WITH KEY BookId = <lfs_org_data>-BookId
                                                              BorrowedBookId = <lfs_org_data>-BorrowedBookId.
      IF sy-subrc EQ 0.
        lv_status = ls_read-Status.
      ENDIF.

      IF lv_status IS NOT INITIAL.
        <lfs_org_data>-current_status  = lv_status.

      ELSE.
        IF <lfs_org_data>-BorrowDate <= lv_curr_date AND lv_curr_date <= <lfs_org_data>-ReturnDate.
          <lfs_org_data>-current_status = 'N'.

        ELSEIF <lfs_org_data>-BorrowDate > lv_curr_date AND <lfs_org_data>-BorrowDate IS NOT INITIAL.
          <lfs_org_data>-current_status = 'C'.

        ELSEIF lv_curr_date > <lfs_org_data>-ReturnDate AND <lfs_org_data>-ReturnDate IS NOT INITIAL.
          <lfs_org_data>-current_status = 'O'.

        ELSEIF <lfs_org_data>-BorrowDate IS INITIAL AND <lfs_org_data>-ReturnDate IS INITIAL.
          <lfs_org_data>-current_status = ''.

        ENDIF.
      ENDIF.
      READ TABLE lt_borrowed_status INTO DATA(ls_borrowed_status) WITH KEY Status = <lfs_org_data>-current_status.
      IF sy-subrc EQ 0.
        <lfs_org_data>-current_status = ls_borrowed_status-StatusDesc.
      ENDIF.

      " Hidden Flag
*      IF  <lfs_org_data>-current_status IS NOT INITIAL.
      <lfs_org_data>-hidden_flag = abap_true.
*      ENDIF.
    ENDLOOP.

    ct_calculated_data = CORRESPONDING #( lt_original_data ).

  ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~get_calculation_info.
*    DATA(lv_1) = 1.
*    APPEND 'Status' TO et_requested_orig_elements.
  ENDMETHOD.
ENDCLASS.
