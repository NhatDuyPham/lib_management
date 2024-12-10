CLASS zpdp_cl_book DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_sadl_exit_calc_element_read .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZPDP_CL_BOOK IMPLEMENTATION.


  METHOD if_sadl_exit_calc_element_read~calculate.

    DATA: lt_original_data TYPE STANDARD TABLE OF zpdp_c_book WITH DEFAULT KEY.

    lt_original_data = CORRESPONDING #( it_original_data ).

    SELECT book_id   AS BookId
          ,image_url AS ImageUrl
    FROM zdp_tb_book
    FOR ALL ENTRIES IN @lt_original_data
    WHERE book_id = @lt_original_data-BookId
    INTO TABLE @DATA(lt_read_book).

    LOOP AT lt_original_data ASSIGNING FIELD-SYMBOL(<lfs_org_data>).
     READ TABLE lt_read_book INTO DATA(ls_read) WITH KEY BookId = <lfs_org_data>-BookId.
      IF sy-subrc EQ 0.
       <lfs_org_data>-ImageUrl_list = ls_read-ImageUrl.
      ENDIF.
    ENDLOOP.

     ct_calculated_data = CORRESPONDING #( lt_original_data ).

  ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~get_calculation_info.
  ENDMETHOD.
ENDCLASS.
