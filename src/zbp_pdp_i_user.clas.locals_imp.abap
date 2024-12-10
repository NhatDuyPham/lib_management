CLASS lhc_User DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR User RESULT result.
    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE user.

ENDCLASS.

CLASS lhc_User IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD earlynumbering_create.
*
    DATA: entity      TYPE STRUCTURE FOR CREATE zpdp_i_user,
          user_id_max TYPE zdp_tb_user-user_id.

    LOOP AT entities INTO entity WHERE UserId IS NOT INITIAL.
      APPEND CORRESPONDING #( entity ) TO mapped-user.
    ENDLOOP.

    DATA(entities_wo_userid) = entities.
    DELETE entities_wo_userid WHERE UserId IS NOT INITIAL.

    TRY.
        cl_numberrange_runtime=>number_get(
          EXPORTING
*            ignore_buffer     =
            nr_range_nr       = '01'
            object            = CONV #( 'ZR_USERID' )
            quantity          = CONV #( lines( entities_wo_userid ) )
          IMPORTING
            number            = DATA(number_range_key)
            returncode        = DATA(number_range_return_code)
            returned_quantity = DATA(number_range_returned_quantity)
        ).
*        CATCH cx_nr_object_not_found.
*        CATCH cx_number_ranges.
      CATCH cx_number_ranges INTO DATA(lx_number_ranges).
        "" step3: If there is an exception, throw error
        LOOP AT entities_wo_userid INTO entity.
          APPEND VALUE #( %cid = entity-%cid
                          %key = entity-%key
                          %msg = lx_number_ranges  )
                          TO reported-user.
          APPEND VALUE #( %cid = entity-%cid
                          %key = entity-%key )
                          TO failed-user.
        ENDLOOP.
        EXIT.
    ENDTRY.

    CASE number_range_return_code.
      WHEN '1'.
        "" Step4: Handle especial cases where number range exceed critical %
        LOOP AT entities_wo_userid INTO entity.
          APPEND VALUE #( %cid = entity-%cid
                          %msg = NEW /dmo/cm_flight_messages(
                          textid = /dmo/cm_flight_messages=>number_range_depleted
                          severity = if_abap_behv_message=>severity-warning ) )
                          TO reported-user.
        ENDLOOP.
      WHEN '2' OR '3'.
        "" Step5: The number range return last number , or number exhaused
        LOOP AT entities_wo_userid INTO entity.
          APPEND VALUE #( %cid = entity-%cid
                          %msg = NEW /dmo/cm_flight_messages(
                          textid = /dmo/cm_flight_messages=>not_sufficient_numbers
                          severity = if_abap_behv_message=>severity-warning ) )
                          TO reported-user.
          APPEND VALUE #( %cid = entity-%cid
                          %key = entity-%key
                          %fail-cause = if_abap_behv=>cause-conflict )
                          TO failed-user.
        ENDLOOP.
    ENDCASE.

    "" Step6: Final check for all numbers
    ASSERT number_range_returned_quantity = lines( entities_wo_userid ).

    "" Step7: Loop over the incoming travel data and assign the numbers from number range and retuen MAPPED data
    user_id_max = number_range_key - number_range_returned_quantity.
    LOOP AT entities_wo_userid INTO entity.
      user_id_max += 1.
      entity-UserId = user_id_max.

      APPEND VALUE #( %cid = entity-%cid
                      %is_draft  = entity-%is_draft
                      %key = entity-%key ) TO mapped-user.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
