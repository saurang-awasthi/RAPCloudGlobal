CLASS lhc_invoice DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS updAttach FOR MODIFY
      IMPORTING keys FOR ACTION Invoice~updAttach.

ENDCLASS.

CLASS lhc_invoice IMPLEMENTATION.

  METHOD updAttach.
  ENDMETHOD.

ENDCLASS.

*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
