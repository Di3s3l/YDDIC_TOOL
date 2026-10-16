*&---------------------------------------------------------------------*
*& Include YDDIC_TOOL_X_PROG — module PROG
*& Program or include -> source, PROG_<name>.txt
*& Copyright (c) 2026 Di3s3l - MIT License (see LICENSE)
*&---------------------------------------------------------------------*
CLASS lcl_exp_prog DEFINITION INHERITING FROM lcl_exporter_base FINAL.
  PUBLIC SECTION.
    METHODS lif_exporter~get_info REDEFINITION.
    METHODS lif_exporter~validate REDEFINITION.
    METHODS lif_exporter~export   REDEFINITION.
ENDCLASS.

CLASS lcl_exp_prog IMPLEMENTATION.
  METHOD lif_exporter~get_info.
    rs_info = VALUE #( type_id         = 'PROG'
                       description     = TEXT-t03
                       file_prefix     = `PROG`
                       file_ext        = `txt`
                       supports_filter = abap_true
                       f4_type         = 'PROG' ).
  ENDMETHOD.

  METHOD lif_exporter~validate.
    check_length( iv_name = iv_name iv_max = 40 ).

    SELECT SINGLE @abap_true
      FROM progdir
      INTO @DATA(lv_exists)
      WHERE name  = @iv_name
        AND state = 'A'.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE lcx_ddic_error
        EXPORTING iv_text = |{ TEXT-m08 } { iv_name }|.
    ENDIF.

    check_auth( iv_objtype = 'PROG' iv_name = iv_name ).
  ENDMETHOD.

  METHOD lif_exporter~export.
    rt_lines = lcl_source_reader=>read(
                 iv_mainprog = iv_name
                 it_filter   = it_filter
                 it_header   = VALUE #( ( lcl_source_reader=>header_line( iv_label = `Program` iv_value = iv_name ) ) ) ).
  ENDMETHOD.
ENDCLASS.
