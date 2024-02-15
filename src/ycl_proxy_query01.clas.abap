CLASS ycl_proxy_query01 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_rap_query_provider .
  PROTECTED SECTION.
  PRIVATE SECTION.
    METHODS: mtd_sort_tabvl IMPORTING VALUE(it_sort_field) TYPE if_rap_query_request=>tt_sort_elements
                            CHANGING  ct_data              TYPE STANDARD TABLE,
      mtd_paging_tabvl IMPORTING VALUE(iv_top)  TYPE int8
                                 VALUE(iv_skip) TYPE int8
                       CHANGING  ct_data        TYPE STANDARD TABLE,
      mtd_filter_tabvl IMPORTING VALUE(it_filter) TYPE if_rap_query_filter=>tt_name_range_pairs
                       CHANGING  ct_data          TYPE STANDARD TABLE.

ENDCLASS.

CLASS ycl_proxy_query01 IMPLEMENTATION.


  METHOD if_rap_query_provider~select.
    DATA: lt_stock      TYPE STANDARD TABLE OF yc_stock_demo01,
          lt_fund       TYPE STANDARD TABLE OF yc_fund_demo01,
          lo_demo01     TYPE REF TO yif_demo_01,
          lv_top        TYPE int8,
          lv_skip       TYPE int8,
          lt_req_field  TYPE if_rap_query_request=>tt_requested_elements,
          lt_sort_field TYPE if_rap_query_request=>tt_sort_elements,
          lt_param      TYPE if_rap_query_request=>tt_parameters,
          lv_entity_id  TYPE string.
    DATA: lt_stock_total TYPE yif_demo_01=>tb_stock_total,
          ls_stock_total LIKE LINE OF lt_stock_total,
          lt_filt_field  TYPE if_rap_query_filter=>tt_name_range_pairs.
    lv_top = io_request->get_paging(  )->get_page_size(  ).
    lv_skip = io_request->get_paging(  )->get_offset(  ).
    lt_req_field = io_request->get_requested_elements(  ).
    lt_param = io_request->get_parameters(  ).
    lt_filt_field = io_request->get_filter(  )->get_as_ranges(  ).
    lt_sort_field = io_request->get_sort_elements(  ).
    lv_entity_id = io_request->get_entity_id(  ).
    IF lv_entity_id EQ 'YC_STOCK_DEMO01'.
      lo_demo01 = ycl_demo_01=>get_instance(  ).
      lo_demo01->mtd_get_stock_list( IMPORTING et_stock_total = lt_stock_total ).
      lt_stock = VALUE #( FOR ls_stockvl IN lt_stock_total ( Stock_id = ls_stockvl-stock_id Stock_nm = ls_stockvl-stock_nm
                                                             stock_dt = ls_stockvl-stock_dt fund_cnt = lines( ls_stockvl-fund_itm[] ) ) ).
      me->mtd_filter_tabvl( EXPORTING it_filter = lt_filt_field CHANGING ct_data = lt_stock ).
      me->mtd_sort_tabvl( EXPORTING it_sort_field = lt_sort_field CHANGING ct_data = lt_stock ).
      me->mtd_paging_tabvl( EXPORTING iv_top = lv_top iv_skip = lv_skip CHANGING ct_data = lt_stock ).
      io_response->set_total_number_of_records( lines( lt_stock ) ).
      io_response->set_data( lt_stock ).
    ELSEIF lv_entity_id EQ 'YC_FUND_DEMO01'.
      lo_demo01 = ycl_demo_01=>get_instance(  ).
      lo_demo01->mtd_get_stock_list( IMPORTING et_stock_total = lt_stock_total ).
      me->mtd_filter_tabvl( EXPORTING it_filter = lt_filt_field CHANGING ct_data = lt_stock_total ).
      LOOP AT lt_stock_total INTO ls_stock_total.
        LOOP AT ls_stock_total-fund_itm INTO DATA(ls_funditm).
          APPEND VALUE #( stock_id = ls_stock_total-stock_id fund_id = ls_funditm-fund_id fund_nm = ls_funditm-fund_nm
                          propval = ls_funditm-propval holdcnt = ls_funditm-holdcnt holdamt = ls_funditm-holdamt ) TO lt_fund.
        ENDLOOP.
      ENDLOOP.
      io_response->set_total_number_of_records( lines( lt_fund ) ).
      io_response->set_data( lt_fund ).
    ENDIF.
  ENDMETHOD.

  METHOD mtd_sort_tabvl.
    DATA: ls_sort_field LIKE LINE OF it_sort_field,
          lt_sort       TYPE abap_sortorder_tab,
          ls_sort       LIKE LINE OF lt_sort.

    CHECK it_sort_field[] IS NOT INITIAL.
    LOOP AT it_sort_field INTO ls_sort_field.
      CLEAR: ls_sort.
      ls_sort-name = ls_sort_field-element_name.
      TRANSLATE ls_sort-name TO UPPER CASE.
      IF ls_sort_field-descending EQ 'X'.
        ls_sort-descending = 'X'.
      ENDIF.
      APPEND ls_sort TO lt_sort.
    ENDLOOP.
    SORT ct_data BY (lt_sort).
  ENDMETHOD.

  METHOD mtd_paging_tabvl.
    DATA: lv_from   TYPE int4,
          lv_to     TYPE int4,
          lo_result TYPE REF TO data.
    FIELD-SYMBOLS: <ft_result> TYPE STANDARD TABLE,
                   <fs_result> TYPE any.
    CHECK iv_skip >= 0 AND iv_top > 0.
    CREATE DATA lo_result LIKE ct_data.
    ASSIGN lo_result->* TO <ft_result>.

    IF iv_skip IS NOT INITIAL.
      lv_from = iv_skip + 1.
    ELSE.
      lv_from = 1.
    ENDIF.
    IF iv_top IS NOT INITIAL.
      lv_to = lv_from + iv_top - 1.
    ELSE.
      lv_to = lines( ct_data ).
    ENDIF.

    LOOP AT ct_data ASSIGNING <fs_result> FROM lv_from TO lv_to.
      APPEND <fs_result> TO <ft_result>.
    ENDLOOP.
    ct_data = <ft_result>.

  ENDMETHOD.

  METHOD mtd_filter_tabvl.
    DATA: ls_filter LIKE LINE OF it_filter,
          lv_index  TYPE sy-tabix.
    FIELD-SYMBOLS: <fs_data>  TYPE any,
                   <fv_value> TYPE any.

    LOOP AT it_filter INTO ls_filter.
      TRANSLATE ls_filter-name TO UPPER CASE.
      LOOP AT ct_data ASSIGNING <fs_data>.
        lv_index = sy-tabix.
        ASSIGN COMPONENT ls_filter-name OF STRUCTURE <fs_data> TO <fv_value>.
        CHECK sy-subrc EQ 0.
        IF <fv_value> NOT IN ls_filter-range.
          DELETE ct_data INDEX lv_index.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
