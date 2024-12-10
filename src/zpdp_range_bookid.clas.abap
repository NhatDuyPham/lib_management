CLASS zpdp_range_bookid DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZPDP_RANGE_BOOKID IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

  DATA: lV_object   TYPE cl_numberrange_objects=>nr_attributes-object,
          lt_interval TYPE cl_numberrange_intervals=>nr_interval,
          ls_interval TYPE cl_numberrange_intervals=>nr_nriv_line.

*    lV_object = 'ZR_BOOKID'.
*
*    ls_interval-nrrangenr  = '01'.
*    ls_interval-fromnumber = '0000000010'.
*    ls_interval-tonumber   = '9999999999'.
*    ls_interval-procind     = 'I'.
*
*    APPEND ls_interval TO lt_interval.
*
*    TRY.
*        cl_numberrange_intervals=>create(
*          EXPORTING
*            interval  = lt_interval
*            object    = lV_object
**            subobject =
**            option    =
**          IMPORTING
**            error     =
**            error_inf =
**            error_iv  =
**            warning   =
*        ).
*      CATCH cx_nr_object_not_found.
*      CATCH cx_number_ranges INTO DATA(lo_error).
*
*        out->write(
*  EXPORTING
*    data   = lo_error->get_longtext( )
*        ).
*    ENDTRY.


    TRY.
        cl_numberrange_runtime=>number_get(
          EXPORTING
            nr_range_nr       = '01'
            object            = 'ZR_BOOKID'
*            quantity          = CONV #( lines( lt_book_wo_id ) )
          IMPORTING
            number            = DATA(lv_number)
            returncode        = DATA(lv_returncode)
            returned_quantity = DATA(lv_quantity)
    ).
      CATCH cx_nr_object_not_found.
      CATCH cx_number_ranges INTO DATA(lo_number_ranges).
    ENDTRY.
    out->write(
      EXPORTING
        data   = lv_number
    ).
  ENDMETHOD.
ENDCLASS.
