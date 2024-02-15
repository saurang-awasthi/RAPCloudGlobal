CLASS ycl_demo_03 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
    METHODS:
      mtd_save_datvl03,
      mtd_query_value IMPORTING VALUE(io_output) TYPE REF TO if_oo_adt_classrun_out,
      mtd_query_price IMPORTING VALUE(io_output) TYPE REF TO if_oo_adt_classrun_out.
ENDCLASS.



CLASS ycl_demo_03 IMPLEMENTATION.


  METHOD mtd_save_datvl03.
    DATA: lt_datvl03 TYPE STANDARD TABLE OF ytdemo03.

    lt_datvl03 = VALUE #( ( employee = '00000001' first_name = 'Friedrich' last_name = 'Meier' salary = '15000' currency = 'EUR' )
                          ( employee = '00000002' first_name = 'Johannes' last_name = 'Rahn' salary = '13000' currency = 'EUR' manager = '00000001' )
                          ( employee = '00000003' first_name = 'Lee' last_name = 'Neubasler' salary = '13000' currency = 'EUR' manager = '00000001' )
                          ( employee = '00000004' first_name = 'Holm' last_name = 'Illner' salary = '11000' currency = 'EUR' manager = '00000003' )
                          ( employee = '00000005' first_name = 'Max' last_name = 'Mustermann' salary = '9000' currency = 'EUR' manager = '00000004' )
                          ( employee = '00000006' first_name = 'Christoph' last_name = 'Mustermann' salary = '9000' currency = 'EUR' manager = '00000004' )
                          ( employee = '00000007' first_name = 'Max' last_name = 'Matthaeus' salary = '8000' currency = 'EUR' manager = '00000006' )
                          ( employee = '00000008' first_name = 'Thomas' last_name = 'Barth' salary = '8000' currency = 'EUR' manager = '00000006' )
                          ( employee = '00000009' first_name = 'Sophie' last_name = 'Rahn' salary = '8000' currency = 'EUR' manager = '00000006' )
                          ( employee = '00000010' first_name = 'Thomas' last_name = 'Mustermann' salary = '8000' currency = 'EUR' manager = '00000006' )
                          ( employee = '00000011' first_name = 'Timmy' last_name = 'Green' salary = '11000' currency = 'EUR' manager = '00000002' )
                          ( employee = '00000012' first_name = 'Lucy' last_name = 'Green' salary = '11000' currency = 'EUR' manager = '00000002' )  ).

    MODIFY ytdemo03 FROM TABLE @lt_datvl03.
    COMMIT WORK AND WAIT.
  ENDMETHOD.

  METHOD if_oo_adt_classrun~main.
*    DATA: lv_attachment TYPE /dmo/attachment,
*          lv_filename   TYPE /dmo/filename,
*          lv_mimetype   TYPE /dmo/mime_type.
*
*    DELETE FROM ytravel01.
*
*    INSERT ytravel01 FROM ( SELECT FROM /dmo/travel AS travel
*                                  FIELDS travel~travel_id AS travel_id,
*                                         travel~agency_id AS agency_id,
*                                         travel~customer_id AS customer_id,
*                                         travel~begin_date AS begin_date,
*                                         travel~end_date AS end_date,
*                                         travel~booking_fee AS booking_fee,
*                                         travel~total_price AS total_price,
*                                         travel~currency_code AS currency_code,
*                                         travel~description AS description,
*                                         CASE travel~status WHEN 'N' THEN 'O'
*                                                            WHEN 'P' THEN 'O'
*                                                            WHEN 'B' THEN 'A'
*                                                            ELSE 'X'  END AS overall_status,
*                                         @lv_attachment AS attachment,
*                                         @lv_mimetype AS mime_type,
*                                         @lv_filename AS file_name,
*                                         travel~createdby AS created_by,
*                                         travel~createdat AS created_at,
*                                         travel~lastchangedby AS last_changed_by,
*                                         travel~lastchangedat AS last_changed_at,
*                                         travel~lastchangedat AS local_last_changed_at
*                                 ORDER BY travel_id UP TO 20 ROWS ) .
*    COMMIT WORK AND WAIT.
*    me->mtd_save_datvl03(  ).
*    out->write( 'Demo data generated for table ytravel01 ' ).
*    me->mtd_query_value( out ).
    me->mtd_query_price( out ).
  ENDMETHOD.


  METHOD mtd_query_value.
    SELECT hierarchy_rank AS rank, hierarchy_parent_rank AS prank, hierarchy_level AS level,
           hierarchy_tree_size AS tsize,
           employee, firstname, lastname, salary, currency, manager
    FROM HIERARCHY( SOURCE yi_employee
                    CHILD TO PARENT ASSOCIATION _manager
                    START WHERE manager IS INITIAL
                    SIBLINGS ORDER BY employee ASCENDING )
    INTO TABLE @DATA(lt_employee).
    io_output->write( lt_employee ).
  ENDMETHOD.

  METHOD mtd_query_price.
    DATA: lv_url TYPE string VALUE 'https://sapes5.sapdevcenter.com/sap/bc/srt/xip/sap/zepm_product_soap/002/epm_product_soap/epm_product_soap'.
    TRY.
        DATA(destination) = cl_soap_destination_provider=>create_by_url( i_url = lv_url ).

        DATA(proxy) = NEW ysc_co_epm_product_soap( destination = destination ).

        " fill request
        DATA(request) = VALUE ysc_req_msg_type( req_msg_type-product = 'HT-1001' ).

        proxy->get_price(
          EXPORTING
            input = request
          IMPORTING
            output = DATA(response)
        ).
        io_output->write( |{ response-res_msg_type-price } { response-res_msg_type-currency }| ).
        " handle response
      CATCH cx_soap_destination_error INTO DATA(lx_soap_dest_error).
        " handle error
        io_output->write( |CX_SOAP_DESTINATION_ERROR -> { lx_soap_dest_error->get_text(  ) }| ).
      CATCH cx_ai_system_fault INTO DATA(lx_ai_system_falut).
        " handle error
        io_output->write( |CX_AI_SYSTEM_FAULT -> { lx_ai_system_falut->get_text(  ) }| ).
      CATCH ysc_cx_fault_msg_type INTO DATA(lx_fault_msg_type).
        " handle error
        io_output->write( |YSC_CX_FAULT_MSG_TYPE -> { lx_fault_msg_type->get_text(  ) }| ).
    ENDTRY.

  ENDMETHOD.

ENDCLASS.
