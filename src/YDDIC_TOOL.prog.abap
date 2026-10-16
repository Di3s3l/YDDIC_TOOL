*&---------------------------------------------------------------------*
*& Report YDDIC_TOOL                                           v0.5
*& Export of SAP repository objects (table fields, function group,
*& program, class sources) to a file on the PC.
*& Transaction YDDIC_TOOL. Design: docs/technical-notes.md
*& Copyright (c) 2026 Di3s3l - MIT License (see LICENSE)
*&---------------------------------------------------------------------*
REPORT yddic_tool.

INCLUDE yddic_tool_top.
INCLUDE yddic_tool_base.
INCLUDE yddic_tool_x_tabl.
INCLUDE yddic_tool_x_func.
INCLUDE yddic_tool_x_prog.
INCLUDE yddic_tool_x_clas.
INCLUDE yddic_tool_reg.
INCLUDE yddic_tool_scr.
INCLUDE yddic_tool_test.

INITIALIZATION.
  lcl_screen=>initialization( ).

AT SELECTION-SCREEN OUTPUT.
  lcl_screen=>pbo( ).

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_name.
  lcl_screen=>f4_name( ).

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_path.
  lcl_screen=>f4_path( ).

AT SELECTION-SCREEN ON p_name.
  lcl_screen=>check_name( ).

AT SELECTION-SCREEN ON p_path.
  lcl_screen=>check_path( ).

START-OF-SELECTION.
  lcl_screen=>run( ).
