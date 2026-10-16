*&---------------------------------------------------------------------*
*& Include YDDIC_TOOL_BASE
*& Shared services: exception, base module, source reader, file writer.
*&---------------------------------------------------------------------*

CLASS lcx_ddic_error IMPLEMENTATION.
  METHOD constructor.
    super->constructor( previous = previous ).
    mv_text = iv_text.
  ENDMETHOD.

  METHOD if_message~get_text.
    result = mv_text.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_exporter_base DEFINITION ABSTRACT.
  PUBLIC SECTION.
    INTERFACES lif_exporter ABSTRACT METHODS get_info validate export.

  PROTECTED SECTION.
    METHODS check_auth
      IMPORTING iv_objtype TYPE trobjtype
                iv_name    TYPE sobj_name
      RAISING   lcx_ddic_error.

    "! Avoids silent truncation in the CONV to the DDIC name type
    METHODS check_length
      IMPORTING iv_name TYPE sobj_name
                iv_max  TYPE i
      RAISING   lcx_ddic_error.
ENDCLASS.

CLASS lcl_exporter_base IMPLEMENTATION.
  METHOD check_auth.
    AUTHORITY-CHECK OBJECT 'S_DEVELOP'
      ID 'DEVCLASS' DUMMY
      ID 'OBJTYPE'  FIELD iv_objtype
      ID 'OBJNAME'  FIELD iv_name
      ID 'P_GROUP'  DUMMY
      ID 'ACTVT'    FIELD '03'.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE lcx_ddic_error
        EXPORTING iv_text = |{ TEXT-m06 } { iv_objtype } { iv_name }|.
    ENDIF.
  ENDMETHOD.

  METHOD check_length.
    IF strlen( iv_name ) > iv_max.
      RAISE EXCEPTION TYPE lcx_ddic_error
        EXPORTING iv_text = |{ TEXT-m14 } { iv_name } (max { iv_max })|.
    ENDIF.
  ENDMETHOD.

  METHOD lif_exporter~f4_name.
    DATA: lv_type     TYPE euobj-id,
          lv_name     TYPE sobj_name,
          lv_selected TYPE sobj_name.

    lv_type = lif_exporter~get_info( )-f4_type.
    IF lv_type IS INITIAL.
      RETURN.
    ENDIF.
    lv_name = iv_name.

    " Wrong parameter types fail at runtime only: no value help then
    TRY.
        CALL FUNCTION 'REPOSITORY_INFO_SYSTEM_F4'
          EXPORTING
            object_type          = lv_type
            object_name          = lv_name
            suppress_selection   = abap_true
          IMPORTING
            object_name_selected = lv_selected
          EXCEPTIONS
            cancel               = 1
            wrong_type           = 2
            OTHERS               = 3.
        IF sy-subrc = 0.
          rv_name = lv_selected.
        ENDIF.
      CATCH cx_sy_dyn_call_error.
        CLEAR rv_name.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_source_reader DEFINITION FINAL.
  PUBLIC SECTION.
    CLASS-METHODS read
      IMPORTING iv_mainprog     TYPE progname
                it_filter       TYPE ty_filter_range
                it_header       TYPE string_table
      RETURNING VALUE(rt_lines) TYPE string_table
      RAISING   lcx_ddic_error.

    CLASS-METHODS header_line
      IMPORTING iv_label       TYPE csequence
                iv_value       TYPE csequence
      RETURNING VALUE(rv_line) TYPE string.

  PRIVATE SECTION.
    TYPES: BEGIN OF ty_pattern,
             exclude TYPE abap_bool,
             generic TYPE abap_bool,
             value   TYPE string,
             text    TYPE string,
           END OF ty_pattern,
           tt_pattern TYPE STANDARD TABLE OF ty_pattern WITH EMPTY KEY.

    CLASS-METHODS prepare_filter
      IMPORTING it_filter          TYPE ty_filter_range
      RETURNING VALUE(rt_patterns) TYPE tt_pattern.

    CLASS-METHODS matches
      IMPORTING iv_line         TYPE string
                it_patterns     TYPE tt_pattern
      RETURNING VALUE(rv_match) TYPE abap_bool.

    CLASS-METHODS filter_text
      IMPORTING it_patterns    TYPE tt_pattern
      RETURNING VALUE(rv_text) TYPE string.

    "! Include named by an INCLUDE statement on this line, initial if none
    CLASS-METHODS included_name
      IMPORTING iv_line        TYPE string
      RETURNING VALUE(rv_name) TYPE progname.

    CLASS-METHODS add_to_list
      IMPORTING iv_name TYPE csequence
      CHANGING  cv_list TYPE string.
ENDCLASS.

CLASS lcl_source_reader IMPLEMENTATION.
  METHOD read.
    DATA: lt_includes TYPE STANDARD TABLE OF progname WITH EMPTY KEY,
          lt_seen     TYPE HASHED TABLE OF progname WITH UNIQUE KEY table_line,
          lt_source   TYPE string_table,
          lt_body     TYPE string_table,
          lv_include  TYPE progname,
          lv_db_count TYPE i,
          lv_index    TYPE i,
          lv_scanned  TYPE abap_bool,
          lv_read     TYPE i,
          lv_total    TYPE i,
          lv_skipped  TYPE string,
          lv_found    TYPE string,
          lv_missing  TYPE string.

    DATA(lt_patterns) = prepare_filter( it_filter ).

    APPEND iv_mainprog TO lt_includes.
    SELECT include FROM d010inc
      APPENDING TABLE @lt_includes
      WHERE master = @iv_mainprog
      ORDER BY PRIMARY KEY.
    lv_db_count = lines( lt_includes ).
    LOOP AT lt_includes INTO lv_include.
      INSERT lv_include INTO TABLE lt_seen.
    ENDLOOP.

    " D010INC misses some nested includes (of generated or enhancement
    " includes): INCLUDE statements are followed until nothing new appears
    WHILE lv_index < lines( lt_includes ).
      lv_index = lv_index + 1.
      lv_include = lt_includes[ lv_index ].
      lv_scanned = xsdbool( lv_index > lv_db_count ).

      CLEAR lt_source.
      READ REPORT lv_include INTO lt_source.
      IF sy-subrc <> 0.
        IF lv_scanned = abap_true.
          add_to_list( EXPORTING iv_name = lv_include CHANGING cv_list = lv_missing ).
        ELSE.
          add_to_list( EXPORTING iv_name = lv_include CHANGING cv_list = lv_skipped ).
        ENDIF.
        CONTINUE.
      ENDIF.
      lv_read = lv_read + 1.
      lv_total = lv_total + lines( lt_source ).
      IF lv_scanned = abap_true.
        add_to_list( EXPORTING iv_name = lv_include CHANGING cv_list = lv_found ).
      ENDIF.

      LOOP AT lt_source INTO DATA(lv_line).
        " Before MATCHES: its LOOP overwrites SY-TABIX
        DATA(lv_line_no) = sy-tabix.

        DATA(lv_nested) = included_name( lv_line ).
        IF lv_nested IS NOT INITIAL.
          INSERT lv_nested INTO TABLE lt_seen.
          IF sy-subrc = 0.
            APPEND lv_nested TO lt_includes.
          ENDIF.
        ENDIF.

        IF lt_patterns IS NOT INITIAL AND matches( iv_line = lv_line it_patterns = lt_patterns ) = abap_false.
          CONTINUE.
        ENDIF.
        APPEND |{ lv_include WIDTH = 40 }{ lv_line_no WIDTH = 6 ALIGN = RIGHT } { lv_line }| TO lt_body.
      ENDLOOP.
    ENDWHILE.

    IF lv_total = 0.
      RAISE EXCEPTION TYPE lcx_ddic_error
        EXPORTING iv_text = |{ TEXT-m10 } { iv_mainprog }|.
    ENDIF.

    rt_lines = it_header.
    APPEND header_line( iv_label = `Main program` iv_value = iv_mainprog ) TO rt_lines.
    APPEND header_line( iv_label = `System`
                        iv_value = |{ sy-sysid }/{ sy-mandt }  { sy-datum DATE = ISO } { sy-uzeit TIME = ISO }  { sy-uname }| ) TO rt_lines.
    APPEND header_line( iv_label = `Includes read` iv_value = |{ lv_read } of { lines( lt_includes ) }| ) TO rt_lines.
    IF lv_found IS NOT INITIAL.
      APPEND header_line( iv_label = `Found by scan` iv_value = lv_found ) TO rt_lines.
    ENDIF.
    IF lv_skipped IS NOT INITIAL.
      APPEND header_line( iv_label = `Not readable` iv_value = lv_skipped ) TO rt_lines.
    ENDIF.
    IF lv_missing IS NOT INITIAL.
      APPEND header_line( iv_label = `Not found` iv_value = lv_missing ) TO rt_lines.
    ENDIF.
    IF lt_patterns IS NOT INITIAL.
      APPEND header_line( iv_label = `Filter` iv_value = filter_text( lt_patterns ) ) TO rt_lines.
      APPEND header_line( iv_label = `Lines matched` iv_value = |{ lines( lt_body ) } of { lv_total }| ) TO rt_lines.
    ENDIF.
    APPEND `` TO rt_lines.
    APPEND LINES OF lt_body TO rt_lines.
  ENDMETHOD.

  METHOD included_name.
    IF iv_line NS 'INCLUDE'.
      RETURN.
    ENDIF.

    " Comment lines do not match: they start with * or "
    FIND FIRST OCCURRENCE OF REGEX `^\s*INCLUDE\s+([A-Za-z0-9_/%<][A-Za-z0-9_/%<>=$]*)` IN iv_line
      IGNORING CASE SUBMATCHES DATA(lv_name).
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    lv_name = to_upper( lv_name ).
    " INCLUDE TYPE/STRUCTURE/LIKE: structures; INCLUDE METHODS: class pool
    IF lv_name = `TYPE` OR lv_name = `STRUCTURE` OR lv_name = `LIKE` OR lv_name = `METHODS`
       OR strlen( lv_name ) > 40.
      RETURN.
    ENDIF.
    rv_name = lv_name.
  ENDMETHOD.

  METHOD add_to_list.
    cv_list = COND #( WHEN cv_list IS INITIAL THEN iv_name ELSE |{ cv_list }, { iv_name }| ).
  ENDMETHOD.

  METHOD header_line.
    rv_line = |* { iv_label WIDTH = 15 }: { iv_value }|.
  ENDMETHOD.

  METHOD prepare_filter.
    DATA lv_value TYPE string.

    LOOP AT it_filter INTO DATA(ls_filter).
      DATA(lv_text) = condense( CONV string( ls_filter-low ) ).
      IF lv_text IS INITIAL.
        CONTINUE.
      ENDIF.

      lv_value = to_upper( lv_text ).
      DATA(lv_generic) = xsdbool( lv_value CA '*+' ).
      IF lv_generic = abap_true.
        lv_value = |*{ lv_value }*|.
      ENDIF.

      APPEND VALUE #( exclude = xsdbool( ls_filter-sign = 'E' )
                      generic = lv_generic
                      value   = lv_value
                      text    = lv_text ) TO rt_patterns.
    ENDLOOP.
  ENDMETHOD.

  METHOD matches.
    DATA: lv_hit      TYPE abap_bool,
          lv_has_incl TYPE abap_bool,
          lv_incl_hit TYPE abap_bool.

    DATA(lv_upper) = to_upper( iv_line ).

    LOOP AT it_patterns INTO DATA(ls_pattern).
      IF ls_pattern-generic = abap_true.
        lv_hit = xsdbool( lv_upper CP ls_pattern-value ).
      ELSE.
        lv_hit = xsdbool( lv_upper CS ls_pattern-value ).
      ENDIF.

      IF ls_pattern-exclude = abap_true.
        IF lv_hit = abap_true.
          rv_match = abap_false.
          RETURN.
        ENDIF.
      ELSE.
        lv_has_incl = abap_true.
        IF lv_hit = abap_true.
          lv_incl_hit = abap_true.
        ENDIF.
      ENDIF.
    ENDLOOP.

    rv_match = xsdbool( lv_has_incl = abap_false OR lv_incl_hit = abap_true ).
  ENDMETHOD.

  METHOD filter_text.
    LOOP AT it_patterns INTO DATA(ls_pattern).
      DATA(lv_entry) = COND string( WHEN ls_pattern-exclude = abap_true THEN |NOT { ls_pattern-text }|
                                    ELSE ls_pattern-text ).
      rv_text = COND #( WHEN rv_text IS INITIAL THEN lv_entry ELSE |{ rv_text }, { lv_entry }| ).
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_file_writer DEFINITION FINAL.
  PUBLIC SECTION.
    "! Initial result = unusable directory
    CLASS-METHODS normalize_dir
      IMPORTING iv_path       TYPE csequence
      RETURNING VALUE(rv_dir) TYPE string.

    CLASS-METHODS build_filename
      IMPORTING iv_path        TYPE csequence
                is_info        TYPE lif_exporter=>ty_info
                iv_name        TYPE sobj_name
                iv_filtered    TYPE abap_bool
      RETURNING VALUE(rv_file) TYPE string
      RAISING   lcx_ddic_error.

    CLASS-METHODS write
      IMPORTING iv_file  TYPE string
                it_lines TYPE string_table
      RAISING   lcx_ddic_error.
ENDCLASS.

CLASS lcl_file_writer IMPLEMENTATION.
  METHOD normalize_dir.
    rv_dir = replace( val   = CONV string( iv_path )
                      regex = `^\s+|[\s\\/]+$`
                      with  = ``
                      occ   = 0 ).
    IF rv_dir IS NOT INITIAL.
      rv_dir = rv_dir && `\`.
    ENDIF.
  ENDMETHOD.

  METHOD build_filename.
    DATA(lv_dir) = normalize_dir( iv_path ).
    IF lv_dir IS INITIAL.
      RAISE EXCEPTION TYPE lcx_ddic_error
        EXPORTING iv_text = CONV string( TEXT-m13 ).
    ENDIF.

    DATA(lv_name) = translate( val = condense( CONV string( iv_name ) ) from = `/` to = `_` ).

    rv_file = |{ lv_dir }{ is_info-file_prefix }_{ lv_name }|
           && COND string( WHEN iv_filtered = abap_true THEN `_GREP` )
           && |.{ is_info-file_ext }|.
  ENDMETHOD.

  METHOD write.
    " TABLES is by reference: local copy
    DATA(lt_data) = it_lines.

    CALL FUNCTION 'GUI_DOWNLOAD'
      EXPORTING
        filename                = iv_file
        filetype                = 'ASC'
        codepage                = '4110'
        write_bom               = abap_true
      TABLES
        data_tab                = lt_data
      EXCEPTIONS
        file_write_error        = 1
        no_batch                = 2
        gui_refuse_filetransfer = 3
        OTHERS                  = 4.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE lcx_ddic_error
        EXPORTING iv_text = |{ TEXT-m05 } { iv_file } (rc { sy-subrc })|.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
