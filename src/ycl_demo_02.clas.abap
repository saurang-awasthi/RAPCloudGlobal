CLASS ycl_demo_02 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ycl_demo_02 IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
    DATA: lo_demo        TYPE REF TO yif_demo_01,
          lt_stock_total TYPE yif_demo_01=>tb_stock_total.

    lo_demo = ycl_demo_01=>get_instance(  ).
    lo_demo->mtd_get_stock_list( IMPORTING et_stock_total = lt_stock_total ).

    FREE lo_demo.
    lo_demo = ycl_demo_01=>get_instance(  ).
    lo_demo->mtd_get_stock_list( IMPORTING et_stock_total = lt_stock_total ).
  ENDMETHOD.
ENDCLASS.
