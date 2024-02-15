CLASS ycl_demo_01 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES: BEGIN OF tp_stock,
             stock TYPE string_table,
           END OF tp_stock,
           tb_stock TYPE STANDARD TABLE OF tp_stock WITH DEFAULT KEY,
           BEGIN OF tp_fund_data,
             title     TYPE char100,
             date      TYPE char10,
             stockList TYPE tb_stock,
           END OF tp_fund_data,
           BEGIN OF tp_fund_detail,
             code    TYPE char3,
             message TYPE bapi_msg,
             data    TYPE tp_fund_data,
           END OF tp_fund_detail.
    INTERFACES: if_oo_adt_classrun, yif_demo_01 .

    CLASS-METHODS: get_instance RETURNING VALUE(ro_instance) TYPE REF TO yif_demo_01.
    METHODS: mtd_get_fund_detail IMPORTING VALUE(iv_fundid) TYPE string
                                 CHANGING  ct_stock_total   TYPE yif_demo_01=>tb_stock_total, "tb_stock_total,

      mtd_get_stock_list EXPORTING VALUE(et_stock_total) TYPE yif_demo_01=>tb_stock_total.

  PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-DATA: gt_stock_total TYPE yif_demo_01=>tb_stock_total,
                go_instance    TYPE REF TO yif_demo_01.
    METHODS: mtd_move_value IMPORTING VALUE(io_datvl) TYPE REF TO data
                            EXPORTING VALUE(es_datvl) TYPE tp_fund_detail,

      mtd_move_struct_value IMPORTING VALUE(io_datvl)     TYPE REF TO data
                                      VALUE(io_strudescr) TYPE REF TO cl_abap_structdescr
                            CHANGING  cs_datvl            TYPE any,

      mtd_move_table_value IMPORTING VALUE(io_datvl)     TYPE REF TO data
                                     VALUE(io_tabldescr) TYPE REF TO cl_abap_tabledescr
                           CHANGING  cs_datvl            TYPE STANDARD TABLE.
ENDCLASS.



CLASS ycl_demo_01 IMPLEMENTATION.

  METHOD mtd_get_fund_detail.
    DATA: lv_url      TYPE string,
          lo_dest     TYPE REF TO if_http_destination,
          lo_client   TYPE REF TO if_web_http_client,
          lo_request  TYPE REF TO if_web_http_request,
          lo_response TYPE REF TO if_web_http_response,
          lv_respvl   TYPE string,
          ls_status   TYPE if_web_http_response=>http_status,
          lt_field    TYPE if_web_http_request=>name_value_pairs,
          lt_namemap  TYPE /ui2/cl_json=>name_mappings.
    DATA: lo_datvl      TYPE REF TO data,
          ls_funddt     TYPE tp_fund_detail,
          ls_stock_list TYPE tp_stock.
    FIELD-SYMBOLS: <fs_stock_total> TYPE yif_demo_01=>tp_stock_total.

    lv_url  = 'https://api.doctorxiong.club/v1/fund/position?code=' && iv_fundid.
    lt_namemap = VALUE #( ( abap = 'TABLE_LINE' json = '' ) ).
    TRY.
        lo_dest = cl_http_destination_provider=>create_by_url( i_url = lv_url ).
        lo_client = cl_web_http_client_manager=>create_by_http_destination( i_destination = lo_dest ).
        lo_request = lo_client->get_http_request( ).
        lo_response = lo_client->execute( i_method = if_web_http_client=>get ).
        lt_field = lo_response->get_header_fields(  ).
        ls_status = lo_response->get_status(  ).
        IF ls_status-code EQ '200'.
          lv_respvl = lo_response->get_text(  ).
*          /ui2/cl_json=>deserialize( EXPORTING json = lv_respvl pretty_name = 'L' name_mappings = lt_namemap
*                                     CHANGING data = es_funddt ).
        ENDIF.
        lo_client->close(  ).
      CATCH cx_http_dest_provider_error.
        "handle exception
      CATCH cx_web_http_client_error.
        "handle exception
    ENDTRY.

    IF lv_respvl NE space.
      lo_datvl = /ui2/cl_json=>generate( EXPORTING json = lv_respvl pretty_name = 'L' ).
      IF lo_datvl IS BOUND.
        me->mtd_move_value( EXPORTING io_datvl = lo_datvl IMPORTING es_datvl = ls_funddt ).

        LOOP AT ls_funddt-data-stocklist INTO ls_stock_list.
          CHECK lines( ls_stock_list-stock[] ) EQ 5.
          READ TABLE ct_stock_total ASSIGNING <fs_stock_total> WITH TABLE KEY stock_id = ls_stock_list-stock[ 1 ].
          IF sy-subrc NE 0.
            APPEND VALUE #( stock_id = ls_stock_list-stock[ 1 ] stock_nm = ls_stock_list-stock[ 2 ] stock_dt = ls_funddt-data-date
                            fund_itm = VALUE #( ( fund_id = iv_fundid fund_nm = ls_funddt-data-title propval = ls_stock_list-stock[ 3 ]
                                                  holdcnt = ls_stock_list-stock[ 4 ] holdamt = ls_stock_list-stock[ 5 ] ) ) ) TO ct_stock_total.
          ELSE.
            IF NOT line_exists( <fs_stock_total>-fund_itm[ fund_id = iv_fundid ] ).
              APPEND VALUE #( fund_id = iv_fundid fund_nm = ls_funddt-data-title propval = ls_stock_list-stock[ 3 ]
                              holdcnt = ls_stock_list-stock[ 4 ] holdamt = ls_stock_list-stock[ 5 ]  ) TO <fs_stock_total>-fund_itm.
            ENDIF.
          ENDIF.
        ENDLOOP.

      ENDIF.
    ENDIF.

  ENDMETHOD.
  METHOD mtd_move_value.
    DATA: lo_typedescr TYPE REF TO cl_abap_typedescr,
          lo_strudescr TYPE REF TO cl_abap_structdescr,
          lv_typekind  TYPE abap_typekind.
    lo_typedescr = cl_abap_typedescr=>describe_by_data( es_datvl ).
    lv_typekind = lo_typedescr->type_kind.
    IF lv_typekind EQ cl_abap_typedescr=>typekind_struct1 OR lv_typekind EQ cl_abap_typedescr=>typekind_struct2.
      lo_strudescr ?= lo_typedescr.
      me->mtd_move_struct_value( EXPORTING io_datvl = io_datvl io_strudescr = lo_strudescr
                                 CHANGING cs_datvl = es_datvl ).
    ENDIF.
  ENDMETHOD.

  METHOD mtd_move_struct_value.
    DATA: lt_component TYPE abap_component_tab,
          ls_component LIKE LINE OF lt_component,
          lo_strudescr TYPE REF TO cl_abap_structdescr,
          lo_datadescr TYPE REF TO cl_abap_datadescr,
          lo_tabldescr TYPE REF TO cl_abap_tabledescr,
          lv_typekind  TYPE abap_typekind.

    FIELD-SYMBOLS: <fv_datvl> TYPE any,
                   <fv_value> TYPE any,
                   <fv_val02> TYPE any,
                   <ft_tagvl> TYPE STANDARD TABLE,
                   <fv_tagvl> TYPE any.

    lt_component = io_strudescr->get_components(  ).
    ASSIGN io_datvl->* TO <fv_datvl>.

    LOOP AT lt_component INTO ls_component.
      lv_typekind = ls_component-type->type_kind.
      IF lv_typekind EQ cl_abap_typedescr=>typekind_struct1 OR lv_typekind EQ cl_abap_typedescr=>typekind_struct2.
        ASSIGN COMPONENT ls_component-name OF STRUCTURE <fv_datvl> TO <fv_value>.
        CHECK <fv_value> IS ASSIGNED.
        ASSIGN COMPONENT ls_component-name OF STRUCTURE cs_datvl TO <fv_tagvl>.
        CHECK <fv_tagvl> IS ASSIGNED.
        lo_strudescr ?= ls_component-type.
        me->mtd_move_struct_value( EXPORTING io_datvl = <fv_value> io_strudescr = lo_strudescr
                                    CHANGING cs_datvl = <fv_tagvl> ).
      ELSEIF lv_typekind EQ cl_abap_typedescr=>typekind_table.
        ASSIGN COMPONENT ls_component-name OF STRUCTURE <fv_datvl> TO <fv_value>.
        CHECK <fv_value> IS ASSIGNED.
        ASSIGN COMPONENT ls_component-name OF STRUCTURE cs_datvl TO <ft_tagvl>.
        CHECK <fv_tagvl> IS ASSIGNED.
        lo_tabldescr ?= ls_component-type.
        me->mtd_move_table_value( EXPORTING io_datvl = <fv_value> io_tabldescr = lo_tabldescr
                                   CHANGING cs_datvl = <ft_tagvl> ).
      ELSE.
        ASSIGN COMPONENT ls_component-name OF STRUCTURE <fv_datvl> TO <fv_value>.
        CHECK <fv_value> IS ASSIGNED.
        ASSIGN COMPONENT ls_component-name OF STRUCTURE cs_datvl TO <fv_tagvl>.
        CHECK <fv_tagvl> IS ASSIGNED.
        ASSIGN <fv_value>->* TO <fv_val02>.
        <fv_tagvl> = <fv_val02>.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD mtd_move_table_value.
    DATA: lo_strudescr TYPE REF TO cl_abap_structdescr,
          lo_tabldescr TYPE REF TO cl_abap_tabledescr,
          lt_component TYPE abap_component_tab,
          ls_component LIKE LINE OF lt_component,
          lv_typekind  TYPE abap_typekind.
    DATA: lo_substru   TYPE REF TO cl_abap_structdescr,
          lo_datadescr TYPE REF TO cl_abap_datadescr,
          lo_targetvl  TYPE REF TO data,
          lo_tabvl     TYPE REF TO data,
          lo_result    TYPE REF TO data.
    FIELD-SYMBOLS: <ft_value> TYPE STANDARD TABLE,
                   <fs_value> TYPE any,
                   <ft_val02> TYPE STANDARD TABLE,
                   <fs_val02> TYPE any,
                   <fv_val02> TYPE any.
    FIELD-SYMBOLS: <ft_target> TYPE STANDARD TABLE,
                   <fs_result> TYPE any.

    ASSIGN io_datvl->* TO <ft_value>.

    lo_strudescr ?= io_tabldescr->get_table_line_type(  ).
    lt_component = lo_strudescr->get_components(  ).
    LOOP AT lt_component INTO ls_component.
      lv_typekind = ls_component-type->type_kind.
      IF lv_typekind EQ cl_abap_typedescr=>typekind_table.
        lo_tabldescr ?= ls_component-type.
        lo_datadescr = lo_tabldescr->get_table_line_type(  ).
        IF lo_datadescr->kind = cl_abap_datadescr=>kind_elem.

          LOOP AT <ft_value> ASSIGNING <fs_value>.
            ASSIGN <fs_value>->* TO <ft_val02>.
            CREATE DATA lo_result LIKE LINE OF cs_datvl.
            ASSIGN lo_result->* TO <fs_result>.
            ASSIGN COMPONENT ls_component-name OF STRUCTURE <fs_result> TO <ft_target>.
            CHECK <ft_target> IS ASSIGNED.

            LOOP AT <ft_val02> ASSIGNING <fs_val02>.
              ASSIGN <fs_val02>->* TO <fv_val02>.
              APPEND <fv_val02> TO <ft_target>.
            ENDLOOP.
            APPEND <fs_result> TO cs_datvl.
            UNASSIGN: <fs_result>, <ft_target>.
            FREE: lo_result.

          ENDLOOP.

        ENDIF.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD yif_demo_01~mtd_get_stock_list.
    DATA lt_stock_total TYPE yif_demo_01=>tb_stock_total.
    CLEAR: et_stock_total, et_stock_total[].
    IF me->gt_stock_total[] IS NOT INITIAL.
      APPEND LINES OF me->gt_stock_total TO et_stock_total.
    ELSE.
      me->mtd_get_fund_detail( EXPORTING iv_fundid = '000083' CHANGING ct_stock_total = lt_stock_total ).
      me->mtd_get_fund_detail( EXPORTING iv_fundid = '000408' CHANGING ct_stock_total = lt_stock_total ).
      me->mtd_get_fund_detail( EXPORTING iv_fundid = '005991' CHANGING ct_stock_total = lt_stock_total ).
      me->mtd_get_fund_detail( EXPORTING iv_fundid = '009549' CHANGING ct_stock_total = lt_stock_total ).
      me->mtd_get_fund_detail( EXPORTING iv_fundid = '005827' CHANGING ct_stock_total = lt_stock_total ).
      me->mtd_get_fund_detail( EXPORTING iv_fundid = '161005' CHANGING ct_stock_total = lt_stock_total ).
      me->mtd_get_fund_detail( EXPORTING iv_fundid = '501203' CHANGING ct_stock_total = lt_stock_total ).
      me->mtd_get_fund_detail( EXPORTING iv_fundid = '501206' CHANGING ct_stock_total = lt_stock_total ).
      me->mtd_get_fund_detail( EXPORTING iv_fundid = '519069' CHANGING ct_stock_total = lt_stock_total ).
*      lt_stock_total = VALUE #( ( stock_id = '000001' stock_nm = 'XXXXX01' stock_dt = '2023-09-30'
*                                  fund_itm = VALUE #( ( fund_id = 'F000001' fund_nm = 'FXXX01' ) ) ) ).
      APPEND LINES OF lt_stock_total TO et_stock_total.
      APPEND LINES OF et_stock_total TO me->gt_stock_total.
    ENDIF.
  ENDMETHOD.

  METHOD mtd_get_stock_list.
    DATA lt_stock_total TYPE yif_demo_01=>tb_stock_total.
    CLEAR: et_stock_total, et_stock_total[].
    IF me->gt_stock_total[] IS NOT INITIAL.
      APPEND LINES OF me->gt_stock_total TO et_stock_total.
    ELSE.
*      me->mtd_get_fund_detail( EXPORTING iv_fundid = '000083' CHANGING ct_stock_total = lt_stock_total ).
*      me->mtd_get_fund_detail( EXPORTING iv_fundid = '000408' CHANGING ct_stock_total = lt_stock_total ).
*      me->mtd_get_fund_detail( EXPORTING iv_fundid = '005991' CHANGING ct_stock_total = lt_stock_total ).
*      me->mtd_get_fund_detail( EXPORTING iv_fundid = '009549' CHANGING ct_stock_total = lt_stock_total ).
*      me->mtd_get_fund_detail( EXPORTING iv_fundid = '005827' CHANGING ct_stock_total = lt_stock_total ).
*      me->mtd_get_fund_detail( EXPORTING iv_fundid = '161005' CHANGING ct_stock_total = lt_stock_total ).
*      me->mtd_get_fund_detail( EXPORTING iv_fundid = '501203' CHANGING ct_stock_total = lt_stock_total ).
*      me->mtd_get_fund_detail( EXPORTING iv_fundid = '501206' CHANGING ct_stock_total = lt_stock_total ).
*      me->mtd_get_fund_detail( EXPORTING iv_fundid = '519069' CHANGING ct_stock_total = lt_stock_total ).
      lt_stock_total = VALUE #( ( stock_id = '000001' stock_nm = 'XXXXX01' stock_dt = '2023-09-30'
                                  fund_itm = VALUE #( ( fund_id = 'F000001' fund_nm = 'FXXX01' ) ) ) ).
      APPEND LINES OF lt_stock_total TO et_stock_total.
      APPEND LINES OF et_stock_total TO me->gt_stock_total.
    ENDIF.
  ENDMETHOD.
  METHOD get_instance.
    IF go_instance IS BOUND.
      ro_instance = go_instance.
    ELSE.
      ro_instance = NEW ycl_demo_01(  ).
      go_instance = ro_instance.
    ENDIF.
  ENDMETHOD.
  METHOD if_oo_adt_classrun~main.
    DATA: lt_stock_total TYPE yif_demo_01=>tb_stock_total,
          lo_writer      TYPE REF TO cl_sxml_string_writer,
          lo_reader      TYPE REF TO if_sxml_reader,
          lv_result      TYPE string.
    me->mtd_get_stock_list( IMPORTING et_stock_total = lt_stock_total ).
    CHECK lt_stock_total[] IS NOT INITIAL.
    lo_writer = cl_sxml_string_writer=>create( type = if_sxml=>co_xt_xml10 encoding = 'UTF-8' ).
    lo_writer->if_sxml_writer~set_option( option = if_sxml_writer=>co_opt_linebreaks ).
    lo_writer->if_sxml_writer~set_option( option = if_sxml_writer=>co_opt_indent ).
    CALL TRANSFORMATION yfund_export SOURCE stock_data = lt_stock_total
                                     RESULT XML lo_writer.
    lo_reader = cl_sxml_string_reader=>create( lo_writer->get_output(  ) ).
    lo_reader->next_node(  ).
    lo_reader->skip_node( lo_writer ).
    lv_result = cl_abap_conv_codepage=>create_in(  )->convert( lo_writer->get_output( ) ).
    out->write( lv_result ).
*    CALL METHOD cl_gui_frontend_services=>gui_download(
*      EXPORTING
*        filename = ''
*        filetype = 'ASC'
*      CHANGING
*        data_tab = data(lt_dat) ).
  ENDMETHOD.

ENDCLASS.
