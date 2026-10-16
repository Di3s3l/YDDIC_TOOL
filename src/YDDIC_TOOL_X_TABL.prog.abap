*&---------------------------------------------------------------------*
*& Include YDDIC_TOOL_X_TABL — module TABL
*& Table/structure fields -> TABL_<name>.csv
*&---------------------------------------------------------------------*
CLASS lcl_exp_tabl DEFINITION INHERITING FROM lcl_exporter_base FINAL.
  PUBLIC SECTION.
    METHODS lif_exporter~get_info REDEFINITION.
    METHODS lif_exporter~validate REDEFINITION.
    METHODS lif_exporter~export   REDEFINITION.

    " Public for the unit tests (YDDIC_TOOL_TEST)
    TYPES: BEGIN OF ty_incl_map,
             fieldname TYPE fieldname,
             include   TYPE string,
           END OF ty_incl_map,
           tt_incl_map TYPE HASHED TABLE OF ty_incl_map WITH UNIQUE KEY fieldname.
    TYPES tt_dd03p TYPE STANDARD TABLE OF dd03p WITH DEFAULT KEY.

    "! Field -> include path, from DD03P rows in position order
    METHODS include_map
      IMPORTING it_dd03p      TYPE tt_dd03p
      RETURNING VALUE(rt_map) TYPE tt_incl_map.

    "! CSV field: quoted, with doubled quotes, only if needed
    METHODS csv_text
      IMPORTING iv_text        TYPE csequence
      RETURNING VALUE(rv_text) TYPE string.

  PRIVATE SECTION.
    METHODS build_include_map
      IMPORTING iv_tabname    TYPE tabname
      RETURNING VALUE(rt_map) TYPE tt_incl_map.

    METHODS header_line
      RETURNING VALUE(rv_line) TYPE string.
ENDCLASS.

CLASS lcl_exp_tabl IMPLEMENTATION.
  METHOD lif_exporter~get_info.
    rs_info = VALUE #( type_id         = 'TABL'
                       description     = TEXT-t01
                       file_prefix     = `TABL`
                       file_ext        = `csv`
                       supports_filter = abap_false
                       f4_type         = 'TABL' ).
  ENDMETHOD.

  METHOD lif_exporter~validate.
    check_length( iv_name = iv_name iv_max = 30 ).

    DATA(lv_tabname) = CONV tabname( iv_name ).
    SELECT SINGLE @abap_true
      FROM dd02l
      INTO @DATA(lv_exists)
      WHERE tabname  = @lv_tabname
        AND as4local = 'A'.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE lcx_ddic_error
        EXPORTING iv_text = |{ TEXT-m01 } { iv_name }|.
    ENDIF.

    check_auth( iv_objtype = 'TABL' iv_name = iv_name ).
  ENDMETHOD.

  METHOD lif_exporter~export.
    DATA: lt_dfies TYPE STANDARD TABLE OF dfies WITH DEFAULT KEY,
          lv_descr TYPE string.

    DATA(lv_tabname) = CONV tabname( iv_name ).

    CALL FUNCTION 'DDIF_FIELDINFO_GET'
      EXPORTING
        tabname        = lv_tabname
        langu          = sy-langu
      TABLES
        dfies_tab      = lt_dfies
      EXCEPTIONS
        not_found      = 1
        internal_error = 2
        OTHERS         = 3.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE lcx_ddic_error
        EXPORTING iv_text = |{ TEXT-m02 } { iv_name }|.
    ENDIF.

    DATA(lt_incl_map) = build_include_map( lv_tabname ).

    APPEND header_line( ) TO rt_lines.

    LOOP AT lt_dfies INTO DATA(ls_dfies) WHERE fieldname IS NOT INITIAL.
      lv_descr = csv_text( ls_dfies-fieldtext ).

      " ? = include unknown (map not readable or field not in it), never
      " shown as an own field
      DATA(lv_include) = COND string( WHEN line_exists( lt_incl_map[ fieldname = ls_dfies-fieldname ] )
                                      THEN lt_incl_map[ fieldname = ls_dfies-fieldname ]-include
                                      ELSE `?` ).

      DATA(lv_field) = COND string( WHEN ls_dfies-lfieldname IS NOT INITIAL THEN ls_dfies-lfieldname
                                    ELSE ls_dfies-fieldname ).

      APPEND |{ lv_field };{ ls_dfies-keyflag };{ ls_dfies-rollname };{ ls_dfies-datatype };| &&
             |{ CONV i( ls_dfies-leng ) };{ CONV i( ls_dfies-decimals ) };{ lv_descr };{ lv_include }|
        TO rt_lines.
    ENDLOOP.
  ENDMETHOD.

  METHOD build_include_map.
    DATA lt_dd03p TYPE tt_dd03p.

    CALL FUNCTION 'DDIF_TABL_GET'
      EXPORTING
        name          = iv_tabname
        langu         = sy-langu
      TABLES
        dd03p_tab     = lt_dd03p
      EXCEPTIONS
        illegal_input = 1
        OTHERS        = 2.
    IF sy-subrc <> 0.
      MESSAGE TEXT-m03 TYPE 'I'.
      RETURN.
    ENDIF.

    rt_map = include_map( lt_dd03p ).
  ENDMETHOD.

  METHOD include_map.
    DATA: lt_path  TYPE string_table,
          lv_depth TYPE i,
          lv_from  TYPE i.

    " ADMINFIELD = number of includes around the row; LT_PATH = open
    " includes, outermost first
    LOOP AT it_dd03p INTO DATA(ls_dd03p).
      lv_depth = 0.
      IF ls_dd03p-adminfield CA '123456789'.
        lv_depth = ls_dd03p-adminfield.
      ENDIF.

      lv_from = lv_depth + 1.
      DELETE lt_path FROM lv_from.

      IF ls_dd03p-fieldname CP '.*'.
        APPEND condense( CONV string( ls_dd03p-precfield ) ) TO lt_path.
      ELSEIF ls_dd03p-fieldname IS NOT INITIAL.
        INSERT VALUE #( fieldname = ls_dd03p-fieldname
                        include   = concat_lines_of( table = lt_path sep = `>` ) ) INTO TABLE rt_map.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD csv_text.
    rv_text = iv_text.
    IF rv_text CA |;"\r\n|.
      rv_text = |"{ replace( val = rv_text sub = `"` with = `""` occ = 0 ) }"|.
    ENDIF.
  ENDMETHOD.

  METHOD header_line.
    DATA(lt_labels) = VALUE string_table( ( CONV #( TEXT-h01 ) ) ( CONV #( TEXT-h08 ) )
                                          ( CONV #( TEXT-h02 ) ) ( CONV #( TEXT-h03 ) )
                                          ( CONV #( TEXT-h04 ) ) ( CONV #( TEXT-h05 ) )
                                          ( CONV #( TEXT-h06 ) ) ( CONV #( TEXT-h07 ) ) ).
    LOOP AT lt_labels INTO DATA(lv_label).
      CONDENSE lv_label.
      " COND string: with type # the C(6) literal would truncate the labels
      lv_label = COND string( WHEN lv_label IS INITIAL THEN `NONAME` ELSE lv_label ).
      rv_line = COND #( WHEN sy-tabix = 1 THEN lv_label ELSE |{ rv_line };{ lv_label }| ).
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
