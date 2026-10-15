*&---------------------------------------------------------------------*
*& Include YDDIC_TOOL_X_FUNC — module FUNC
*& Function module -> function group source, FUNC_<module>.txt
*&---------------------------------------------------------------------*
CLASS lcl_exp_func DEFINITION INHERITING FROM lcl_exporter_base FINAL.
  PUBLIC SECTION.
    METHODS lif_exporter~get_info REDEFINITION.
    METHODS lif_exporter~validate REDEFINITION.
    METHODS lif_exporter~export   REDEFINITION.

  PRIVATE SECTION.
    METHODS resolve
      IMPORTING iv_name     TYPE sobj_name
      EXPORTING ev_mainprog TYPE progname
                ev_group    TYPE sobj_name
      RAISING   lcx_ddic_error.
ENDCLASS.

CLASS lcl_exp_func IMPLEMENTATION.
  METHOD lif_exporter~get_info.
    rs_info = VALUE #( type_id         = 'FUNC'
                       description     = TEXT-t02
                       file_prefix     = `FUNC`
                       file_ext        = `txt`
                       supports_filter = abap_true
                       f4_type         = 'FF' ).
  ENDMETHOD.

  METHOD lif_exporter~validate.
    check_length( iv_name = iv_name iv_max = 30 ).
    resolve( EXPORTING iv_name = iv_name IMPORTING ev_group = DATA(lv_group) ).
    check_auth( iv_objtype = 'FUGR' iv_name = lv_group ).
  ENDMETHOD.

  METHOD lif_exporter~export.
    resolve( EXPORTING iv_name     = iv_name
             IMPORTING ev_mainprog = DATA(lv_mainprog)
                       ev_group    = DATA(lv_group) ).

    rt_lines = lcl_source_reader=>read(
                 iv_mainprog = lv_mainprog
                 it_filter   = it_filter
                 it_header   = VALUE #( ( lcl_source_reader=>header_line( iv_label = `Function module` iv_value = iv_name ) )
                                        ( lcl_source_reader=>header_line( iv_label = `Function group`  iv_value = lv_group ) ) ) ).
  ENDMETHOD.

  METHOD resolve.
    DATA(lv_funcname) = CONV rs38l_fnam( iv_name ).

    SELECT SINGLE pname
      FROM tfdir
      INTO @ev_mainprog
      WHERE funcname = @lv_funcname.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE lcx_ddic_error
        EXPORTING iv_text = |{ TEXT-m07 } { iv_name }|.
    ENDIF.

    " ENLFDIR: right also for namespace groups, where PNAME+4 is not
    SELECT SINGLE area
      FROM enlfdir
      INTO @DATA(lv_area)
      WHERE funcname = @lv_funcname.
    IF sy-subrc = 0.
      ev_group = lv_area.
    ELSE.
      ev_group = ev_mainprog+4.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
