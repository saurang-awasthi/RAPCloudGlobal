CLASS ycl_demo_04 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PUBLIC SECTION.
  PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-DATA: lo_cds_test_env TYPE REF TO if_cds_test_environment,
                lo_sql_test_env TYPE REF TO if_osql_test_environment,
                lv_begin_date   TYPE /dmo/begin_date,
                lv_end_date     TYPE /dmo/end_date,
                lt_agency       TYPE STANDARD TABLE OF /dmo/agency,
                lt_customer     TYPE STANDARD TABLE OF /dmo/customer,
                lt_carrier      TYPE STANDARD TABLE OF /dmo/carrier,
                lt_flight       TYPE STANDARD TABLE OF /dmo/flight.

    CLASS-METHODS:
      class_setup,
      class_teardown.
    METHODS:
      setup,
      teardown,
      create_with_action FOR TESTING RAISING cx_static_check.
ENDCLASS.



CLASS ycl_demo_04 IMPLEMENTATION.
  METHOD class_setup.
    lo_cds_test_env = cl_cds_test_environment=>create_for_multiple_cds( i_for_entities = VALUE #( ( i_for_entity = 'ZR_YTRAVEL01' ) ) ).
    lo_sql_test_env = cl_osql_test_environment=>create( i_dependency_list = VALUE #( ( '/DMO/AGENCY' ) ( '/DMO/CUSTOMER' )
                                                                                     ( '/DMO/CARRIER' ) ( '/DMO/FLIGHT' ) ) ).
    lv_begin_date = cl_abap_context_info=>get_system_date(  ) + 10.
    lv_end_date = cl_abap_context_info=>get_system_date(  ) + 30.

    lt_agency = VALUE #( ( agency_id = '070043' name = 'Z Agency 070043' ) ).
    lt_customer = VALUE #( ( customer_id = '000093' last_name = 'Z Customer 000093' )  ).
    lt_carrier = VALUE #( ( carrier_id = '015' name = 'Z Carrier 015' ) ).
    lt_flight = VALUE #( ( carrier_id = '015' connection_id = '9018' flight_date = lv_begin_date price = '2000' currency_code = 'EUR' ) ).
  ENDMETHOD.

  METHOD class_teardown.
    lo_cds_test_env->destroy(  ).
    lo_sql_test_env->destroy(  ).
  ENDMETHOD.

  METHOD create_with_action.
    MODIFY ENTITIES OF zr_ytravel01 ENTITY Travel
    CREATE FIELDS ( AgencyID CustomerID BeginDate EndDate Description TotalPrice BookingFee CurrencyCode )
      WITH VALUE #( ( %cid = 'ROOT1' AgencyID = lt_agency[ 1 ]-agency_id
                      CustomerID = lt_customer[ 1 ]-customer_id
                      BeginDate = lv_begin_date EndDate = lv_end_date
                      Description = 'Test Travel 01' TotalPrice = '1100' BookingFee = '20' CurrencyCode = 'EUR' ) )

    ENTITY Travel EXECUTE acceptTravel FROM VALUE #( ( %cid_ref = 'ROOT1' ) )

    ENTITY Travel EXECUTE deductDiscount FROM VALUE #( ( %cid_ref = 'ROOT1' %param-discount_percent = '20' ) )

    MAPPED DATA(lv_mapped)
    FAILED DATA(lv_failed)
    REPORTED DATA(lv_reported).

    cl_abap_unit_assert=>assert_initial( msg = 'failed' act = lv_failed ).
    cl_abap_unit_assert=>assert_initial( msg = 'reported' act = lv_reported ).

    cl_abap_unit_assert=>assert_not_initial( msg = 'mapped-travel' act = lv_mapped-travel ).

    COMMIT ENTITIES RESPONSES FAILED DATA(lv_commit_failed)
                              REPORTED DATA(lv_commit_reported).
    cl_abap_unit_assert=>assert_initial( msg = 'commit_failed' act = lv_commit_failed ).
    cl_abap_unit_assert=>assert_initial( msg = 'commit_reported' act = lv_commit_reported ).

    SELECT * FROM zr_ytravel01 INTO TABLE @DATA(lt_travel).
    cl_abap_unit_assert=>assert_not_initial( msg = 'travel from db' act = lt_travel ).
    cl_abap_unit_assert=>assert_not_initial( msg = 'travel-id' act = lt_travel[ 1 ]-TravelID ).
    cl_abap_unit_assert=>assert_equals( msg = 'overall status' exp = 'A' act = lt_travel[ 1 ]-OverallStatus ).
    cl_abap_unit_assert=>assert_equals( msg = 'discounted booking_fee' exp = '16' act = lt_travel[ 1 ]-BookingFee ).
  ENDMETHOD.

  METHOD setup.
    lo_cds_test_env->clear_doubles(  ).
    lo_sql_test_env->clear_doubles(  ).

    lo_sql_test_env->insert_test_data( lt_agency ).
    lo_sql_test_env->insert_test_data( lt_customer ).
    lo_sql_test_env->insert_test_data( lt_carrier ).
    lo_sql_test_env->insert_test_data( lt_flight ).
  ENDMETHOD.

  METHOD teardown.
    ROLLBACK ENTITIES.
  ENDMETHOD.

ENDCLASS.
