*&---------------------------------------------------------------------*
*& Include YDDIC_TOOL_SCR
*& Selection screen and its controller.
*& Copyright (c) 2026 Di3s3l - MIT License (see LICENSE)
*&---------------------------------------------------------------------*
TABLES sscrfields.

" P_NAME/P_PATH not OBLIGATORY (would fire on every listbox change):
" checked in CHECK_NAME/CHECK_PATH
SELECTION-SCREEN BEGIN OF BLOCK b01 WITH FRAME TITLE TEXT-b01.
  PARAMETERS: p_type TYPE ty_type_id AS LISTBOX VISIBLE LENGTH 40
                     OBLIGATORY USER-COMMAND typ,
              p_name TYPE sobj_name.
SELECTION-SCREEN END OF BLOCK b01.

SELECTION-SCREEN BEGIN OF BLOCK b02 WITH FRAME TITLE TEXT-b02.
  PARAMETERS p_path TYPE localfile LOWER CASE.
SELECTION-SCREEN END OF BLOCK b02.

SELECTION-SCREEN BEGIN OF BLOCK b03 WITH FRAME TITLE TEXT-b03.
  SELECT-OPTIONS s_kw FOR gv_kw NO INTERVALS LOWER CASE MODIF ID flt.
SELECTION-SCREEN END OF BLOCK b03.

CLASS lcl_screen DEFINITION FINAL.
  PUBLIC SECTION.
    CLASS-METHODS initialization.
    CLASS-METHODS pbo.
    CLASS-METHODS f4_name.
    CLASS-METHODS f4_path.
    CLASS-METHODS check_name.
    CLASS-METHODS check_path.
    CLASS-METHODS run.

  PRIVATE SECTION.
    CONSTANTS gc_ucomm_type TYPE sy-ucomm VALUE 'TYP'.

    CLASS-METHODS current_module
      RETURNING VALUE(ro_module) TYPE REF TO lif_exporter.
ENDCLASS.

CLASS lcl_screen IMPLEMENTATION.
  METHOD initialization.
    DATA(lt_modules) = lcl_registry=>get_all( ).
    IF lt_modules IS NOT INITIAL.
      p_type = lt_modules[ 1 ]->get_info( )-type_id.
    ENDIF.
    p_path = TEXT-d01.
  ENDMETHOD.

  METHOD pbo.
    DATA lt_values TYPE vrm_values.

    LOOP AT lcl_registry=>get_all( ) INTO DATA(lo_module).
      DATA(ls_info) = lo_module->get_info( ).
      APPEND VALUE #( key = ls_info-type_id text = ls_info-description ) TO lt_values.
    ENDLOOP.

    CALL FUNCTION 'VRM_SET_VALUES'
      EXPORTING
        id              = 'P_TYPE'
        values          = lt_values
      EXCEPTIONS
        id_illegal_name = 1
        OTHERS          = 2.

    DATA(lo_current) = current_module( ).
    DATA(lv_filter_on) = xsdbool( lo_current IS BOUND AND lo_current->get_info( )-supports_filter = abap_true ).

    LOOP AT SCREEN INTO DATA(ls_screen).
      IF ls_screen-name = 'P_NAME' OR ls_screen-name = 'P_PATH'.
        ls_screen-required = '2'.
        MODIFY SCREEN FROM ls_screen.
      ELSEIF ls_screen-group1 = 'FLT'.
        ls_screen-input = COND #( WHEN lv_filter_on = abap_true THEN '1' ELSE '0' ).
        MODIFY SCREEN FROM ls_screen.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD f4_name.
    DATA: lt_fields TYPE STANDARD TABLE OF dynpread WITH DEFAULT KEY,
          lv_repid  TYPE sy-repid,
          lv_dynnr  TYPE sy-dynnr.

    " POV does not transport field values
    lv_repid  = sy-repid.
    lv_dynnr  = sy-dynnr.
    lt_fields = VALUE #( ( fieldname = 'P_TYPE' ) ( fieldname = 'P_NAME' ) ).
    CALL FUNCTION 'DYNP_VALUES_READ'
      EXPORTING
        dyname     = lv_repid
        dynumb     = lv_dynnr
      TABLES
        dynpfields = lt_fields
      EXCEPTIONS
        OTHERS     = 1.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    READ TABLE lt_fields INTO DATA(ls_type) WITH KEY fieldname = 'P_TYPE'.
    READ TABLE lt_fields INTO DATA(ls_name) WITH KEY fieldname = 'P_NAME'.

    TRY.
        DATA(lo_module) = lcl_registry=>get( CONV #( ls_type-fieldvalue ) ).
      CATCH lcx_ddic_error.
        RETURN.
    ENDTRY.

    DATA(lv_selected) = lo_module->f4_name( CONV #( to_upper( ls_name-fieldvalue ) ) ).
    IF lv_selected IS NOT INITIAL.
      p_name = lv_selected.
    ENDIF.
  ENDMETHOD.

  METHOD f4_path.
    DATA: lv_initial  TYPE string,
          lv_selected TYPE string.

    lv_initial = p_path.
    cl_gui_frontend_services=>directory_browse(
      EXPORTING
        initial_folder  = lv_initial
      CHANGING
        selected_folder = lv_selected
      EXCEPTIONS
        OTHERS          = 1 ).
    IF sy-subrc = 0.
      cl_gui_cfw=>flush( ).
      IF lv_selected IS NOT INITIAL.
        p_path = lv_selected.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD check_name.
    IF sscrfields-ucomm = gc_ucomm_type.
      RETURN.
    ENDIF.

    IF p_name IS INITIAL.
      MESSAGE TEXT-m12 TYPE 'E'.
    ENDIF.

    TRY.
        lcl_registry=>get( p_type )->validate( p_name ).
      CATCH lcx_ddic_error INTO DATA(lx_error).
        MESSAGE lx_error TYPE 'E'.
    ENDTRY.
  ENDMETHOD.

  METHOD check_path.
    IF sscrfields-ucomm = gc_ucomm_type.
      RETURN.
    ENDIF.

    DATA(lv_dir) = lcl_file_writer=>normalize_dir( p_path ).
    IF lv_dir IS INITIAL.
      MESSAGE TEXT-m13 TYPE 'E'.
    ENDIF.
  ENDMETHOD.

  METHOD run.
    TRY.
        DATA(lo_module) = lcl_registry=>get( p_type ).
        DATA(ls_info)   = lo_module->get_info( ).
        lo_module->validate( p_name ).

        DATA(lt_filter) = COND ty_filter_range( WHEN ls_info-supports_filter = abap_true THEN s_kw[] ).
        DELETE lt_filter WHERE low IS INITIAL.

        DATA(lt_lines) = lo_module->export( iv_name = p_name it_filter = lt_filter ).

        DATA(lv_file) = lcl_file_writer=>build_filename( iv_path     = p_path
                                                         is_info     = ls_info
                                                         iv_name     = p_name
                                                         iv_filtered = xsdbool( lt_filter IS NOT INITIAL ) ).
        lcl_file_writer=>write( iv_file = lv_file it_lines = lt_lines ).

        DATA(lv_message) = |{ TEXT-m04 } { lv_file } ({ lines( lt_lines ) } { TEXT-m15 })|.
        MESSAGE lv_message TYPE 'S'.
      CATCH lcx_ddic_error INTO DATA(lx_error).
        MESSAGE lx_error TYPE 'S' DISPLAY LIKE 'E'.
    ENDTRY.
  ENDMETHOD.

  METHOD current_module.
    TRY.
        ro_module = lcl_registry=>get( p_type ).
      CATCH lcx_ddic_error.
        CLEAR ro_module.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
