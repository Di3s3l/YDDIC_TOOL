*&---------------------------------------------------------------------*
*& Include YDDIC_TOOL_TOP
*& Types, exception class (definition), module contract.
*& Copyright (c) 2026 Di3s3l - MIT License (see LICENSE)
*&---------------------------------------------------------------------*

TYPES ty_type_id TYPE c LENGTH 4.
TYPES ty_kw TYPE c LENGTH 70.
TYPES ty_filter_range TYPE RANGE OF ty_kw.

DATA gv_kw TYPE ty_kw.

" Implementation in YDDIC_TOOL_BASE: a TOP include holds declarations only
CLASS lcx_ddic_error DEFINITION INHERITING FROM cx_static_check FINAL.
  PUBLIC SECTION.
    METHODS constructor
      IMPORTING iv_text  TYPE string OPTIONAL
                previous TYPE REF TO cx_root OPTIONAL.
    METHODS if_message~get_text REDEFINITION.
  PRIVATE SECTION.
    DATA mv_text TYPE string.
ENDCLASS.

INTERFACE lif_exporter.
  TYPES: BEGIN OF ty_info,
           type_id         TYPE ty_type_id,
           description     TYPE string,
           file_prefix     TYPE string,
           file_ext        TYPE string,
           supports_filter TYPE abap_bool,
           f4_type         TYPE euobj-id,
         END OF ty_info.

  METHODS get_info
    RETURNING VALUE(rs_info) TYPE ty_info.

  "! Length, existence, S_DEVELOP 03
  METHODS validate
    IMPORTING iv_name TYPE sobj_name
    RAISING   lcx_ddic_error.

  METHODS export
    IMPORTING iv_name         TYPE sobj_name
              it_filter       TYPE ty_filter_range
    RETURNING VALUE(rt_lines) TYPE string_table
    RAISING   lcx_ddic_error.

  "! Initial result = nothing selected
  METHODS f4_name
    IMPORTING iv_name        TYPE sobj_name
    RETURNING VALUE(rv_name) TYPE sobj_name.
ENDINTERFACE.
