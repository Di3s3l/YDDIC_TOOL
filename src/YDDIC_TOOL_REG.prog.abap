*&---------------------------------------------------------------------*
*& Include YDDIC_TOOL_REG
*& Module registry: the only list of modules (order = listbox order).
*& Copyright (c) 2026 Di3s3l - MIT License (see LICENSE)
*&---------------------------------------------------------------------*
CLASS lcl_registry DEFINITION FINAL.
  PUBLIC SECTION.
    TYPES tt_modules TYPE STANDARD TABLE OF REF TO lif_exporter WITH EMPTY KEY.

    CLASS-METHODS get_all
      RETURNING VALUE(rt_modules) TYPE tt_modules.

    CLASS-METHODS get
      IMPORTING iv_type_id       TYPE ty_type_id
      RETURNING VALUE(ro_module) TYPE REF TO lif_exporter
      RAISING   lcx_ddic_error.

  PRIVATE SECTION.
    CLASS-DATA gt_modules TYPE tt_modules.
ENDCLASS.

CLASS lcl_registry IMPLEMENTATION.
  METHOD get_all.
    IF gt_modules IS INITIAL.
      gt_modules = VALUE #( ( NEW lcl_exp_tabl( ) )
                            ( NEW lcl_exp_func( ) )
                            ( NEW lcl_exp_prog( ) )
                            ( NEW lcl_exp_clas( ) ) ).
    ENDIF.
    rt_modules = gt_modules.
  ENDMETHOD.

  METHOD get.
    LOOP AT get_all( ) INTO DATA(lo_module).
      IF lo_module->get_info( )-type_id = iv_type_id.
        ro_module = lo_module.
        RETURN.
      ENDIF.
    ENDLOOP.
    RAISE EXCEPTION TYPE lcx_ddic_error
      EXPORTING iv_text = |{ TEXT-m11 } { iv_type_id }|.
  ENDMETHOD.
ENDCLASS.
