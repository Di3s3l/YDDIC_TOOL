*&---------------------------------------------------------------------*
*& Include YDDIC_TOOL_TEST
*& ABAP Unit tests of the logic that does not read the system
*& (Ctrl+Shift+F10 in the editor).
*&---------------------------------------------------------------------*

CLASS ltc_source_reader DEFINITION FINAL FOR TESTING
  RISK LEVEL HARMLESS DURATION SHORT.
  PRIVATE SECTION.
    METHODS filter_one_inclusion_enough FOR TESTING.
    METHODS filter_exclusion_wins       FOR TESTING.
    METHODS filter_only_exclusions      FOR TESTING.
    METHODS filter_wildcard             FOR TESTING.
    METHODS filter_ignores_case         FOR TESTING.
    METHODS filter_drops_blank_entries  FOR TESTING.
    METHODS include_statements_accepted FOR TESTING.
    METHODS include_lookalikes_rejected FOR TESTING.
    METHODS header_label_width          FOR TESTING.

    METHODS kept
      IMPORTING iv_line        TYPE string
                it_filter      TYPE ty_filter_range
      RETURNING VALUE(rv_kept) TYPE abap_bool.
ENDCLASS.

CLASS ltc_source_reader IMPLEMENTATION.
  METHOD kept.
    rv_kept = lcl_source_reader=>matches(
                iv_line     = iv_line
                it_patterns = lcl_source_reader=>prepare_filter( it_filter ) ).
  ENDMETHOD.

  METHOD filter_one_inclusion_enough.
    DATA(lt_filter) = VALUE ty_filter_range( sign = 'I' option = 'EQ'
                                             ( low = 'AUTHORITY' ) ( low = 'BAPI' ) ).
    cl_abap_unit_assert=>assert_true(
      act = kept( iv_line = `CALL FUNCTION 'BAPI_PO_GETDETAIL'` it_filter = lt_filter ) ).
    cl_abap_unit_assert=>assert_false(
      act = kept( iv_line = `WRITE lv_text.` it_filter = lt_filter ) ).
  ENDMETHOD.

  METHOD filter_exclusion_wins.
    DATA(lt_filter) = VALUE ty_filter_range( option = 'EQ'
                                             ( sign = 'I' low = 'AUTHORITY' )
                                             ( sign = 'E' low = 'DUMMY' ) ).
    cl_abap_unit_assert=>assert_false(
      act = kept( iv_line = `AUTHORITY-CHECK OBJECT 'S_DEVELOP' ID 'DEVCLASS' DUMMY` it_filter = lt_filter ) ).
    cl_abap_unit_assert=>assert_true(
      act = kept( iv_line = `AUTHORITY-CHECK OBJECT 'S_TCODE'` it_filter = lt_filter ) ).
  ENDMETHOD.

  METHOD filter_only_exclusions.
    DATA(lt_filter) = VALUE ty_filter_range( ( sign = 'E' option = 'EQ' low = 'DUMMY' ) ).
    cl_abap_unit_assert=>assert_true(
      act = kept( iv_line = `WRITE lv_text.` it_filter = lt_filter ) ).
    cl_abap_unit_assert=>assert_false(
      act = kept( iv_line = `ID 'P_GROUP' DUMMY` it_filter = lt_filter ) ).
  ENDMETHOD.

  METHOD filter_wildcard.
    DATA(lt_filter) = VALUE ty_filter_range( ( sign = 'I' option = 'EQ' low = 'CALL*BAPI' ) ).
    cl_abap_unit_assert=>assert_true(
      act = kept( iv_line = `  CALL FUNCTION 'BAPI_PROJECT_GETINFO'` it_filter = lt_filter ) ).
    cl_abap_unit_assert=>assert_false(
      act = kept( iv_line = `  CALL METHOD lo_obj->run( ).` it_filter = lt_filter ) ).
  ENDMETHOD.

  METHOD filter_ignores_case.
    DATA(lt_filter) = VALUE ty_filter_range( ( sign = 'I' option = 'EQ' low = 'authority-check' ) ).
    cl_abap_unit_assert=>assert_true(
      act = kept( iv_line = `AUTHORITY-CHECK OBJECT 'S_DEVELOP'` it_filter = lt_filter ) ).
  ENDMETHOD.

  METHOD filter_drops_blank_entries.
    DATA(lt_filter) = VALUE ty_filter_range( ( sign = 'I' option = 'EQ' low = space ) ).
    cl_abap_unit_assert=>assert_initial(
      act = lcl_source_reader=>prepare_filter( lt_filter ) ).
  ENDMETHOD.

  METHOD include_statements_accepted.
    cl_abap_unit_assert=>assert_equals(
      act = lcl_source_reader=>included_name( `  INCLUDE l2054top.                 " Global Data` )
      exp = CONV progname( 'L2054TOP' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = lcl_source_reader=>included_name( `INCLUDE  LSEUAV17.` )
      exp = CONV progname( 'LSEUAV17' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = lcl_source_reader=>included_name( `INCLUDE CL_ERP_CO_OLC_SW_CHECK========EIMP .` )
      exp = CONV progname( 'CL_ERP_CO_OLC_SW_CHECK========EIMP' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = lcl_source_reader=>included_name( `INCLUDE <icon>.` )
      exp = CONV progname( '<ICON>' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = lcl_source_reader=>included_name( `INCLUDE /abc/lgroupf01.` )
      exp = CONV progname( '/ABC/LGROUPF01' ) ).
  ENDMETHOD.

  METHOD include_lookalikes_rejected.
    DATA(lt_lines) = VALUE string_table(
      ( `  INCLUDE TYPE slis_coltypes.` )
      ( `  include structure bapiret2.` )
      ( `  INCLUDE LIKE rsfindlst-object," Name des Objektes` )
      ( `  include methods.` )
      ( `    INCLUDE = objlist-obj_name.` )
      ( `* INCLUDE l2054top.` )
      ( `" INCLUDE l2054top.` )
      ( `DATA lv_include TYPE progname.` )
      ( `lv_text = 'INCLUDE x'.` ) ).
    LOOP AT lt_lines INTO DATA(lv_line).
      cl_abap_unit_assert=>assert_initial(
        act = lcl_source_reader=>included_name( lv_line )
        msg = lv_line ).
    ENDLOOP.
  ENDMETHOD.

  METHOD header_label_width.
    cl_abap_unit_assert=>assert_equals(
      act = lcl_source_reader=>header_line( iv_label = `Filter` iv_value = `X` )
      exp = `* Filter         : X` ).
  ENDMETHOD.
ENDCLASS.

CLASS ltc_file_writer DEFINITION FINAL FOR TESTING
  RISK LEVEL HARMLESS DURATION SHORT.
  PRIVATE SECTION.
    METHODS normalize_dir          FOR TESTING.
    METHODS filename_namespace     FOR TESTING.
    METHODS filename_blank_dir_err FOR TESTING.
ENDCLASS.

CLASS ltc_file_writer IMPLEMENTATION.
  METHOD normalize_dir.
    cl_abap_unit_assert=>assert_equals(
      act = lcl_file_writer=>normalize_dir( `C:\tmp` ) exp = `C:\tmp\` ).
    cl_abap_unit_assert=>assert_equals(
      act = lcl_file_writer=>normalize_dir( `  C:\tmp\\ ` ) exp = `C:\tmp\` ).
    cl_abap_unit_assert=>assert_equals(
      act = lcl_file_writer=>normalize_dir( `C:\tmp/` ) exp = `C:\tmp\` ).
    cl_abap_unit_assert=>assert_initial(
      act = lcl_file_writer=>normalize_dir( `   ` ) ).
  ENDMETHOD.

  METHOD filename_namespace.
    DATA(ls_info) = VALUE lif_exporter=>ty_info( file_prefix = `PROG` file_ext = `txt` ).
    TRY.
        cl_abap_unit_assert=>assert_equals(
          act = lcl_file_writer=>build_filename( iv_path     = `C:\tmp`
                                                 is_info     = ls_info
                                                 iv_name     = '/ABC/REPORT'
                                                 iv_filtered = abap_true )
          exp = `C:\tmp\PROG__ABC_REPORT_GREP.txt` ).
      CATCH lcx_ddic_error.
        cl_abap_unit_assert=>fail( msg = `Unexpected exception` ).
    ENDTRY.
  ENDMETHOD.

  METHOD filename_blank_dir_err.
    DATA(ls_info) = VALUE lif_exporter=>ty_info( file_prefix = `PROG` file_ext = `txt` ).
    TRY.
        lcl_file_writer=>build_filename( iv_path     = ` `
                                         is_info     = ls_info
                                         iv_name     = 'RM06EF00'
                                         iv_filtered = abap_false ).
        cl_abap_unit_assert=>fail( msg = `Exception expected for a blank directory` ).
      CATCH lcx_ddic_error ##NO_HANDLER.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.

CLASS ltc_exp_tabl DEFINITION FINAL FOR TESTING
  RISK LEVEL HARMLESS DURATION SHORT.
  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO lcl_exp_tabl.

    METHODS setup.
    METHODS include_path_by_level FOR TESTING.
    METHODS csv_text_quoting      FOR TESTING.

    METHODS include_of
      IMPORTING it_map            TYPE lcl_exp_tabl=>tt_incl_map
                iv_field          TYPE fieldname
      RETURNING VALUE(rv_include) TYPE string.
ENDCLASS.

CLASS ltc_exp_tabl IMPLEMENTATION.
  METHOD setup.
    mo_cut = NEW #( ).
  ENDMETHOD.

  METHOD include_of.
    rv_include = VALUE #( it_map[ fieldname = iv_field ]-include DEFAULT `<missing>` ).
  ENDMETHOD.

  METHOD include_path_by_level.
    " Own field, include A with nested include B, field back in A after B,
    " own field after the include block (the PRPS / GJV_DATA_3 case)
    DATA(lt_dd03p) = VALUE lcl_exp_tabl=>tt_dd03p(
      ( fieldname = 'MANDT'    adminfield = '0' )
      ( fieldname = '.INCLUDE' adminfield = '0' precfield = 'INC_A' )
      ( fieldname = 'F1'       adminfield = '1' )
      ( fieldname = '.INCLUDE' adminfield = '1' precfield = 'INC_B' )
      ( fieldname = 'F2'       adminfield = '2' )
      ( fieldname = 'F3'       adminfield = '1' )
      ( fieldname = 'OWN'      adminfield = '0' ) ).

    DATA(lt_map) = mo_cut->include_map( lt_dd03p ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_map ) exp = 5 ).
    cl_abap_unit_assert=>assert_equals( act = include_of( it_map = lt_map iv_field = 'MANDT' ) exp = `` ).
    cl_abap_unit_assert=>assert_equals( act = include_of( it_map = lt_map iv_field = 'F1' )    exp = `INC_A` ).
    cl_abap_unit_assert=>assert_equals( act = include_of( it_map = lt_map iv_field = 'F2' )    exp = `INC_A>INC_B` ).
    cl_abap_unit_assert=>assert_equals( act = include_of( it_map = lt_map iv_field = 'F3' )    exp = `INC_A` ).
    cl_abap_unit_assert=>assert_equals( act = include_of( it_map = lt_map iv_field = 'OWN' )   exp = `` ).
  ENDMETHOD.

  METHOD csv_text_quoting.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->csv_text( `Plain text` )    exp = `Plain text` ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->csv_text( `Value; unit` )   exp = `"Value; unit"` ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->csv_text( `Say "hello"` )   exp = `"Say ""hello"""` ).
  ENDMETHOD.
ENDCLASS.
