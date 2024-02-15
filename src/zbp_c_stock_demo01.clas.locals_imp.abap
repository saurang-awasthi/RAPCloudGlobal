CLASS lhc_fundlist DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

*    METHODS update FOR MODIFY
*      IMPORTING entities FOR UPDATE FundList.

*    METHODS delete FOR MODIFY
*      IMPORTING keys FOR DELETE FundList.

    METHODS read FOR READ
      IMPORTING keys FOR READ FundList RESULT result.

    METHODS rba_Stockdt FOR READ
      IMPORTING keys_rba FOR READ FundList\_Stockdt FULL result_requested RESULT result LINK association_links.

ENDCLASS.

CLASS lhc_fundlist IMPLEMENTATION.

*  METHOD update.
*  ENDMETHOD.

*  METHOD delete.
*  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD rba_Stockdt.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_stocklist DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR StockList RESULT result.

*    METHODS create FOR MODIFY
*      IMPORTING entities FOR CREATE StockList.

*    METHODS update FOR MODIFY
*      IMPORTING entities FOR UPDATE StockList.

*    METHODS delete FOR MODIFY
*      IMPORTING keys FOR DELETE StockList.

    METHODS read FOR READ
      IMPORTING keys FOR READ StockList RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK StockList.

    METHODS rba_Funditems FOR READ
      IMPORTING keys_rba FOR READ StockList\_Funditems FULL result_requested RESULT result LINK association_links.

*    METHODS cba_Funditems FOR MODIFY
*      IMPORTING entities_cba FOR CREATE StockList\_Funditems.

ENDCLASS.

CLASS lhc_stocklist IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

*  METHOD create.
*  ENDMETHOD.

*  METHOD update.
*  ENDMETHOD.

*  METHOD delete.
*  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD rba_Funditems.
  ENDMETHOD.

*  METHOD cba_Funditems.
*  ENDMETHOD.

ENDCLASS.

*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
