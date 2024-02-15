CLASS lhc_travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    CONSTANTS: BEGIN OF ls_travel_status,
                 open     TYPE c LENGTH 1 VALUE 'O',  " Open
                 accepted TYPE c LENGTH 1 VALUE 'A',  " Accepted
                 rejected TYPE c LENGTH 1 VALUE 'X',  " Rejected
               END OF ls_travel_status.

    METHODS:
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR Travel
        RESULT result,

      earlynumbering_create FOR NUMBERING
        IMPORTING entities FOR CREATE Travel,

      setStatusToOpen FOR DETERMINE ON MODIFY
        IMPORTING keys FOR Travel~setStatusToOpen,

      validateCustomer FOR VALIDATE ON SAVE
        IMPORTING keys FOR Travel~validateCustomer.

    METHODS validateDates FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateDates.

    METHODS deductDiscount FOR MODIFY
      IMPORTING keys FOR ACTION Travel~deductDiscount RESULT result.

    METHODS copyTravel FOR MODIFY
      IMPORTING keys FOR ACTION Travel~copyTravel.

    METHODS acceptTravel FOR MODIFY
      IMPORTING keys FOR ACTION Travel~acceptTravel RESULT result.

    METHODS rejectTravel FOR MODIFY
      IMPORTING keys FOR ACTION Travel~rejectTravel RESULT result.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Travel RESULT result.

    METHODS popuptravel FOR READ
      IMPORTING keys FOR FUNCTION travel~popuptravel RESULT result.
ENDCLASS.

CLASS lhc_travel IMPLEMENTATION.
  METHOD get_global_authorizations.
  ENDMETHOD.
  METHOD earlynumbering_create.
    DATA: ls_entity           TYPE STRUCTURE FOR CREATE zr_ytravel01,
          lv_travel_id_max    TYPE /dmo/travel_id,
          lv_use_number_range TYPE abap_bool VALUE abap_false.

    LOOP AT entities INTO ls_entity WHERE TravelID IS NOT INITIAL.
      APPEND CORRESPONDING #( ls_entity ) TO mapped-travel.
    ENDLOOP.
    DATA(lt_entities) = entities.
    DELETE lt_entities WHERE TravelID IS NOT INITIAL.

    IF lv_use_number_range EQ abap_false.
      SELECT SINGLE FROM ytravel01 FIELDS MAX( travel_id ) AS travelid INTO @lv_travel_id_max.
      SELECT SINGLE FROM zytravel01_d FIELDS MAX( travelid ) INTO @DATA(lv_travelid_draft).
      IF lv_travelid_draft > lv_travel_id_max.
        lv_travel_id_max = lv_travelid_draft.
      ENDIF.
    ENDIF.

    LOOP AT lt_entities INTO ls_entity.
      lv_travel_id_max = lv_travel_id_max + 1.
      ls_entity-TravelID = lv_travel_id_max.
      APPEND VALUE #( %cid = ls_entity-%cid
                      %key = ls_entity-%key
                      %is_draft = ls_entity-%is_draft ) TO mapped-travel.
    ENDLOOP.
  ENDMETHOD.

  METHOD setStatusToOpen.
    READ ENTITIES OF zr_ytravel01 IN LOCAL MODE ENTITY Travel
         FIELDS ( OverallStatus ) WITH CORRESPONDING #( keys )
         RESULT DATA(lt_travel)
         FAILED DATA(lt_read_failed).

    DELETE lt_travel WHERE OverallStatus IS NOT INITIAL.
    CHECK lt_travel IS NOT INITIAL.

    MODIFY ENTITIES OF zr_ytravel01 IN LOCAL MODE ENTITY Travel
    UPDATE SET FIELDS WITH VALUE #( FOR ls_travel IN lt_travel ( %tky = ls_travel-%tky OverallStatus = ls_travel_status-open ) )
    REPORTED DATA(lt_upd_reported).
    reported = CORRESPONDING #( DEEP lt_upd_reported ).
  ENDMETHOD.

  METHOD validateCustomer.
    DATA: lt_customer TYPE SORTED TABLE OF /dmo/customer WITH UNIQUE KEY customer_id.
    READ ENTITIES OF zr_ytravel01 IN LOCAL MODE ENTITY Travel
         FIELDS ( CustomerID ) WITH CORRESPONDING #( keys )
         RESULT DATA(lt_travel).
    lt_customer = CORRESPONDING #( lt_travel DISCARDING DUPLICATES MAPPING customer_id = CustomerID EXCEPT * ).
    DELETE lt_customer WHERE customer_id IS INITIAL.
    IF lt_customer IS NOT INITIAL.
      SELECT FROM /dmo/customer FIELDS customer_id
         FOR ALL ENTRIES IN @lt_customer
       WHERE customer_id = @lt_customer-customer_id
        INTO TABLE @DATA(lt_valid_customer).
    ENDIF.

    LOOP AT lt_travel INTO DATA(ls_travel).
      APPEND VALUE #( %tky = ls_travel-%tky
                      %state_area = 'VALIDATE_CUSTOMER' ) TO reported-travel.
      IF ls_travel-CustomerID IS INITIAL.
        APPEND VALUE #( %tky = ls_travel-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = ls_travel-%tky
                        %state_area = 'VALIDATE_CUSTOMER'
                        %msg = NEW /dmo/cm_flight_messages( textid = /dmo/cm_flight_messages=>enter_customer_id
                                                            severity = if_abap_behv_message=>severity-error )
                        %element-CustomerID = if_abap_behv=>mk-on ) TO reported-travel.
      ELSEIF ls_travel-CustomerID IS NOT INITIAL AND NOT line_exists( lt_valid_customer[ customer_id = ls_travel-CustomerID ] ).
        APPEND VALUE #( %tky = ls_travel-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = ls_travel-%tky
                        %state_area = 'VALIDATE_CUSTOMER'
                        %msg = NEW /dmo/cm_flight_messages( customer_id = ls_travel-CustomerID
                                                            textid = /dmo/cm_flight_messages=>customer_unkown
                                                            severity = if_abap_behv_message=>severity-error )
                        %element-CustomerID = if_abap_behv=>mk-on ) TO reported-travel.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validateDates.
    READ ENTITIES OF zr_ytravel01 IN LOCAL MODE ENTITY Travel
         FIELDS ( BeginDate EndDate TravelID ) WITH CORRESPONDING #( keys )
         RESULT DATA(lt_travel).
    LOOP AT lt_travel INTO DATA(ls_travel).
      APPEND VALUE #( %tky = ls_travel-%tky
                      %state_area = 'VALIDATE_DATES' ) TO reported-travel.
      IF ls_travel-BeginDate IS INITIAL.
        APPEND VALUE #( %tky = ls_travel-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = ls_travel-%tky %state_area = 'VALIDATE_DATES'
                        %msg = NEW /dmo/cm_flight_messages( textid = /dmo/cm_flight_messages=>enter_begin_date
                                                            severity = if_abap_behv_message=>severity-error )
                        %element-BeginDate = if_abap_behv=>mk-on ) TO reported-travel.
      ENDIF.
      IF ls_travel-BeginDate < cl_abap_context_info=>get_system_date(  ) AND ls_travel-BeginDate IS NOT INITIAL.
        APPEND VALUE #( %tky = ls_travel-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = ls_travel-%tky %state_area = 'VALIDATE_DATES'
                        %msg = NEW /dmo/cm_flight_messages( begin_date = ls_travel-BeginDate
                                                            textid = /dmo/cm_flight_messages=>begin_date_on_or_bef_sysdate
                                                            severity = if_abap_behv_message=>severity-error )
                        %element-BeginDate = if_abap_behv=>mk-on ) TO reported-travel.
      ENDIF.
      IF ls_travel-EndDate < ls_travel-BeginDate AND ls_travel-BeginDate IS NOT INITIAL AND ls_travel-EndDate IS NOT INITIAL.
        APPEND VALUE #( %tky = ls_travel-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = ls_travel-%tky %state_area = 'VALIDATE_DATES'
                        %msg = NEW /dmo/cm_flight_messages( textid = /dmo/cm_flight_messages=>begin_date_bef_end_date
                                                            begin_date = ls_travel-BeginDate
                                                            end_date = ls_travel-EndDate
                                                            severity = if_abap_behv_message=>severity-error )
                        %element-BeginDate = if_abap_behv=>mk-on
                        %element-EndDate = if_abap_behv=>mk-on ) TO reported-travel.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD deductDiscount.
    DATA: lt_travel_upd         TYPE TABLE FOR UPDATE zr_ytravel01,
          lt_key_valid_discount LIKE keys,
          lv_discount           TYPE p DECIMALS 2,
          lv_reduced_fee        TYPE zr_ytravel01-BookingFee,
          lv_index              TYPE int4.
    lt_key_valid_discount = keys.

    LOOP AT lt_key_valid_discount INTO DATA(ls_key_valid_discount) WHERE %param-discount_percent IS INITIAL
                                                                      OR %param-discount_percent > 100
                                                                      OR %param-discount_percent <= 0.
      lv_index = sy-tabix.
      APPEND VALUE #( %tky = ls_key_valid_discount-%tky ) TO failed-travel.
      APPEND VALUE #( %tky = ls_key_valid_discount-%tky
                      %msg = NEW /dmo/cm_flight_messages( textid = /dmo/cm_flight_messages=>discount_invalid
                                                          severity = if_abap_behv_message=>severity-error )
                      %element-TotalPrice = if_abap_behv=>mk-on
                      %op-%action-deductDiscount = if_abap_behv=>mk-on ) TO reported-travel.
      DELETE lt_key_valid_discount INDEX lv_index.
    ENDLOOP.
    CHECK lt_key_valid_discount IS NOT INITIAL.
    READ ENTITIES OF zr_ytravel01 IN LOCAL MODE ENTITY Travel
         FIELDS ( BookingFee ) WITH CORRESPONDING #( lt_key_valid_discount )
         RESULT DATA(lt_travel).
    LOOP AT lt_travel INTO DATA(ls_travel).
      lv_discount = lt_key_valid_discount[ KEY draft %tky = ls_travel-%tky ]-%param-discount_percent / 100.
      lv_reduced_fee = ls_travel-BookingFee * ( 1 - lv_discount ).
      APPEND VALUE #( %tky = ls_travel-%tky BookingFee = lv_reduced_fee ) TO lt_travel_upd.
    ENDLOOP.

    MODIFY ENTITIES OF zr_ytravel01 IN LOCAL MODE ENTITY Travel
           UPDATE FIELDS ( BookingFee ) WITH lt_travel_upd.
    READ ENTITIES OF zr_ytravel01 IN LOCAL MODE ENTITY Travel
         ALL FIELDS WITH CORRESPONDING #( lt_travel )
         RESULT DATA(lt_travel_with_discount).
    result = VALUE #( FOR ls_travel_01 IN lt_travel_with_discount ( %tky = ls_travel_01-%tky %param = ls_travel_01 ) ).
  ENDMETHOD.

  METHOD copyTravel.
    DATA: lt_travel TYPE TABLE FOR CREATE zr_ytravel01\\Travel.

    READ TABLE keys WITH KEY %cid = '' INTO DATA(ls_key_with_initial_cid).
    ASSERT ls_key_with_initial_cid IS INITIAL.

    READ ENTITIES OF zr_ytravel01 IN LOCAL MODE ENTITY Travel
         ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT DATA(lt_travel_result)
         FAILED failed.
    LOOP AT lt_travel_result INTO DATA(ls_travel).
      APPEND VALUE #( %cid = keys[ KEY entity %key = ls_travel-%key ]-%cid
                      %is_draft = keys[ KEY entity %key = ls_travel-%key ]-%param-%is_draft
                      %data = CORRESPONDING #( ls_travel EXCEPT TravelID ) ) TO lt_travel
             ASSIGNING FIELD-SYMBOL(<fs_new_travel>).
      <fs_new_travel>-BeginDate = cl_abap_context_info=>get_system_date(  ).
      <fs_new_travel>-EndDate = cl_abap_context_info=>get_system_date( ) + 30.
      <fs_new_travel>-OverallStatus = ls_travel_status-open.
    ENDLOOP.

    MODIFY ENTITIES OF zr_ytravel01 IN LOCAL MODE ENTITY Travel
        CREATE FIELDS ( AgencyID CustomerID BeginDate EndDate BookingFee TotalPrice CurrencyCode OverallStatus Description )
        WITH lt_travel MAPPED DATA(ls_mapped_create).
    mapped-travel = ls_mapped_create-travel.
  ENDMETHOD.

  METHOD acceptTravel.
    MODIFY ENTITIES OF zr_ytravel01 IN LOCAL MODE
           ENTITY Travel UPDATE FIELDS ( OverallStatus )
           WITH VALUE #( FOR key IN keys ( %tky = key-%tky
                                           OverallStatus = ls_travel_status-accepted ) )
           FAILED failed
           REPORTED reported.

    READ ENTITIES OF zr_ytravel01 IN LOCAL MODE
         ENTITY Travel ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT DATA(lt_travel).

    result = VALUE #( FOR ls_travel IN lt_travel ( %tky = ls_travel-%tky %param = ls_travel ) ).
  ENDMETHOD.

  METHOD rejectTravel.
    MODIFY ENTITIES OF zr_ytravel01 IN LOCAL MODE
         ENTITY Travel UPDATE FIELDS ( OverallStatus )
         WITH VALUE #( FOR key IN keys ( %tky = key-%tky
                                         OverallStatus = ls_travel_status-rejected ) )
         FAILED failed
         REPORTED reported.

    READ ENTITIES OF zr_ytravel01 IN LOCAL MODE
         ENTITY Travel ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT DATA(lt_travel).

    result = VALUE #( FOR ls_travel IN lt_travel ( %tky = ls_travel-%tky %param = ls_travel ) ).
  ENDMETHOD.

  METHOD get_instance_features.
    READ ENTITIES OF zr_ytravel01 IN LOCAL MODE ENTITY Travel
         FIELDS ( TravelID OverallStatus )
         WITH CORRESPONDING #( keys )
    RESULT DATA(lt_travel)
    FAILED failed.

    result = VALUE #( FOR ls_travel IN lt_travel ( %tky = ls_travel-%tky
                                                   %features-%update = COND #( WHEN ls_travel-OverallStatus = ls_travel_status-accepted
                                                                               THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled )
                                                   %features-%delete = COND #( WHEN ls_travel-OverallStatus = ls_travel_status-open
                                                                               THEN if_abap_behv=>fc-o-enabled ELSE if_abap_behv=>fc-o-disabled )
                                                   %action-acceptTravel = COND #( WHEN ls_travel-OverallStatus = ls_travel_status-accepted
                                                                                  THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled )
                                                   %action-rejectTravel = COND #( WHEN ls_travel-OverallStatus = ls_travel_status-rejected
                                                                                  THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled )
                                                   %action-Edit = COND #( WHEN ls_travel-OverallStatus = ls_travel_status-accepted
                                                                          THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled )
                                                   %action-deductDiscount = COND #( WHEN ls_travel-OverallStatus = ls_travel_status-open
                                                                                    THEN if_abap_behv=>fc-o-enabled ELSE if_abap_behv=>fc-o-disabled ) ) ).

  ENDMETHOD.

  METHOD popupTravel.
    DATA: ls_key LIKE LINE OF keys.
    READ ENTITY zr_ytravel01 FIELDS ( TravelID ) WITH CORRESPONDING #( keys )
    RESULT DATA(lt_travel).
    LOOP AT keys INTO ls_key.
      READ TABLE lt_travel INTO DATA(ls_travel) WITH KEY %key = ls_key-%key.
      IF sy-subrc NE 0.
        CONTINUE.
      ENDIF.



    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
