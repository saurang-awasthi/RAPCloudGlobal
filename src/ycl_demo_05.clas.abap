CLASS ycl_demo_05 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ycl_demo_05 IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    DATA: ls_business_data TYPE ycl_service_mode_demo01=>tys_a_business_partner_type,
          lo_http_dest     TYPE REF TO if_http_destination,
          lo_http_client   TYPE REF TO if_web_http_client,
          lo_client_proxy  TYPE REF TO /iwbep/if_cp_client_proxy,
          lo_request       TYPE REF TO if_web_http_request,
          lo_response      TYPE REF TO if_web_http_response.
    DATA: lv_userid TYPE string,
          lv_url    TYPE string VALUE 'https://sandbox.api.sap.com/s4hanacloud/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_BusinessPartner(''1000071'')' .
          "'https://sandbox.api.sap.com/s4hanacloud/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_BusinessPartner?$inlinecount=allpages&$top=50'.
          "'https://sandbox.api.sap.com/s4hanacloud/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_BusinessPartner('''')/to_BPDataController?$inlinecount=allpages&$top=50'.

    TRY.

        lo_http_dest = cl_http_destination_provider=>create_by_url( i_url = lv_url ).
        lo_http_client = cl_web_http_client_manager=>create_by_http_destination( lo_http_dest ).
        lo_request = lo_http_client->get_http_request(  ).
        lo_request->set_header_fields( VALUE #( ( name = 'APIKey' value = 'vSLpGnV9Safp6cYkUVAbwgRkaqbF2Q7N' )
                                                ( name = 'DataServiceVersion' value = '2.0' )
                                                ( name = 'Accept' value = 'application/json' ) )  ).
        lo_response = lo_http_client->execute( if_web_http_client=>get ).
        out->write( |Response: { lo_response->get_text(  ) }| ).
        lo_http_client->close(  ).
      CATCH /iwbep/cx_cp_remote INTO DATA(lx_remote).
        " Handle remote Exception
        " It contains details about the problems of your http(s) connection
        out->write( |Exception: /IWBEP/CX_CP_REMOTE -> { lx_remote->get_text(  ) } | ).

      CATCH /iwbep/cx_gateway INTO DATA(lx_gateway).
        " Handle Exception
        out->write( |Exception: /IWBEP/CX_GATEWAY -> { lx_gateway->get_text( ) }| ).
      CATCH cx_web_http_client_error INTO DATA(lx_web_http_client_error).
        " Handle Exception
        out->write( |Exception: CX_WEB_HTTP_CLIENT_ERROR -> { lx_web_http_client_error->get_text(  ) }| ).
        RAISE SHORTDUMP lx_web_http_client_error.

      CATCH cx_http_dest_provider_error INTO DATA(lx_http_dest_provider_error).
        "handle exception
        out->write( |Exception: CX_HTTP_DEST_PROVIDER_ERROR -> { lx_http_dest_provider_error->get_text(  ) } | ).
    ENDTRY.


  ENDMETHOD.
ENDCLASS.
