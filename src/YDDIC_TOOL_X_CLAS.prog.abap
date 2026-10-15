*&---------------------------------------------------------------------*
*& Include YDDIC_TOOL_X_CLAS — module CLAS
*& Class or interface -> pool source, CLAS_<name>.txt
*&---------------------------------------------------------------------*
CLASS lcl_exp_clas DEFINITION INHERITING FROM lcl_exporter_base FINAL.
  PUBLIC SECTION.
    METHODS lif_exporter~get_info REDEFINITION.
    METHODS lif_exporter~validate REDEFINITION.
    METHODS lif_exporter~export   REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS gc_clstype_interface TYPE seoclstype VALUE '1'.

    METHODS read_clstype
      IMPORTING iv_name           TYPE sobj_name
      RETURNING VALUE(rv_clstype) TYPE seoclstype
      RAISING   lcx_ddic_error.
ENDCLASS.

CLASS lcl_exp_clas IMPLEMENTATION.
  METHOD lif_exporter~get_info.
    rs_info = VALUE #( type_id         = 'CLAS'
                       description     = TEXT-t04
                       file_prefix     = `CLAS`
                       file_ext        = `txt`
                       supports_filter = abap_true
                       f4_type         = 'CLAS' ).
  ENDMETHOD.

  METHOD lif_exporter~validate.
    check_length( iv_name = iv_name iv_max = 30 ).
    DATA(lv_clstype) = read_clstype( iv_name ).
    check_auth( iv_objtype = COND #( WHEN lv_clstype = gc_clstype_interface THEN 'INTF' ELSE 'CLAS' )
                iv_name    = iv_name ).
  ENDMETHOD.

  METHOD lif_exporter~export.
    DATA lv_pool TYPE progname.

    DATA(lv_clsname) = CONV seoclsname( iv_name ).
    IF read_clstype( iv_name ) = gc_clstype_interface.
      lv_pool = cl_oo_classname_service=>get_interfacepool_name( lv_clsname ).
    ELSE.
      lv_pool = cl_oo_classname_service=>get_classpool_name( lv_clsname ).
    ENDIF.

    rt_lines = lcl_source_reader=>read(
                 iv_mainprog = lv_pool
                 it_filter   = it_filter
                 it_header   = VALUE #( ( lcl_source_reader=>header_line( iv_label = `Class/interface` iv_value = iv_name ) ) ) ).
  ENDMETHOD.

  METHOD read_clstype.
    DATA(lv_clsname) = CONV seoclsname( iv_name ).
    SELECT SINGLE clstype
      FROM seoclass
      INTO @rv_clstype
      WHERE clsname = @lv_clsname.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE lcx_ddic_error
        EXPORTING iv_text = |{ TEXT-m09 } { iv_name }|.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
