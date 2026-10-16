# Technical Notes

← [Documentation](README.md) | 🇮🇹 [Versione italiana](it/technical-notes.md)

## Architecture

```
YDDIC_TOOL     report events → LCL_SCREEN
 _TOP          types, LCX_DDIC_ERROR (definition), interface LIF_EXPORTER
 _BASE         LCX_DDIC_ERROR (implementation), LCL_EXPORTER_BASE,
               LCL_SOURCE_READER, LCL_FILE_WRITER
 _X_TABL _X_FUNC _X_PROG _X_CLAS     one module per object type
 _REG          LCL_REGISTRY: the only list of modules
 _SCR          selection screen + LCL_SCREEN (controller)
 _TEST         ABAP Unit test classes
```

The include order is binding: local classes must be defined before use. A TOP include holds declarations only, so the exception class is implemented in `_BASE`.

## Module Contract (`LIF_EXPORTER`)

| Method | Contract |
|--------|----------|
| `get_info` | Listbox key and text, file prefix and extension, filter support, F4 object type |
| `validate` | Name length, then existence, then `S_DEVELOP 03` (a typo reads "not found") |
| `export` | File lines (`string_table`) |
| `f4_name` | Selected name, initial if cancelled. Default: `REPOSITORY_INFO_SYSTEM_F4` |

Errors travel as `LCX_DDIC_ERROR` carrying the final text; the report shows them as a status message and stays on the selection screen.

## Modules

| Module | Validate | Export | Auth `OBJTYPE` |
|--------|----------|--------|----------------|
| `LCL_EXP_TABL` | `DD02L`, active | `DDIF_FIELDINFO_GET` + `DDIF_TABL_GET` → CSV | `TABL` |
| `LCL_EXP_FUNC` | `TFDIR`; group from `ENLFDIR` (namespace-safe) | Function group source | `FUGR` |
| `LCL_EXP_PROG` | `PROGDIR`, active | Program source | `PROG` |
| `LCL_EXP_CLAS` | `SEOCLASS` (class or interface) | Pool from `CL_OO_CLASSNAME_SERVICE` | `CLAS` / `INTF` |

**Include path (TABL).** `DD03P-ADMINFIELD` is the number of includes around each row. The list of open includes is cut to that level at every row, so an own field after an include block, or a field after a nested include, gets the right include. The older "last `.INCLUDE` seen" logic got these cases wrong.

**Sources.** Main program, then its includes from `D010INC` in alphabetical order, each read with `READ REPORT`. `D010INC` misses some nested includes (e.g. those of generated `$` includes and of enhancement includes), so every `INCLUDE <name>` statement in the sources read is followed too, until no new include appears; a set of seen names prevents duplicates and cycles. `INCLUDE TYPE/STRUCTURE/LIKE` and the class-pool `INCLUDE METHODS` are ignored. No truncation of include names or lines. Unreadable or missing includes are listed in the header, so a missing source is never mistaken for a non-existent one. An error is raised only if no source line is read at all.

**Keyword filter.** Prepared once per export. Line upper-cased; a keyword containing `*` or `+` matches with `CP '*kw*'`, otherwise `CS`. Sign I: at least one must match; sign E: any match drops the line. The OPTION column is ignored; blank entries are dropped. Zero matches still produce a file (header only).

**File.** Directory normalized (one trailing `\`), name `<prefix>_<name>[_GREP].<ext>` with `/` → `_`, `GUI_DOWNLOAD` ASC, codepage 4110 (UTF-8), BOM.

**Selection screen.** `P_NAME`/`P_PATH` are not `OBLIGATORY` (the check would fire on every listbox change): they are flagged as required and checked in code, again at `START-OF-SELECTION`.

## Unit Tests

`YDDIC_TOOL_TEST` holds three test classes (`RISK LEVEL HARMLESS`, `DURATION SHORT`), run with Ctrl+Shift+F10:

| Class | Covers |
|-------|--------|
| `LTC_SOURCE_READER` | Keyword filter (inclusions, exclusions, wildcards, case, blank entries); recognition of `INCLUDE` statements and of look-alikes (`INCLUDE TYPE/STRUCTURE/LIKE/METHODS`, `INCLUDE =`, comments); header label width |
| `LTC_FILE_WRITER` | Directory normalization; file name with namespace and `_GREP`; error on a blank directory |
| `LTC_EXP_TABL` | Include path from hand-built `DD03P` rows (nested include, field after a nested include, own field after an include block); CSV quoting |

To be testable, these methods are public: `prepare_filter`, `matches`, `included_name` (source reader) and `include_map`, `csv_text` (TABL module); `include_map` works on `DD03P` rows, separate from the `DDIF_TABL_GET` call. Reading system data (sources, DDIC) is not unit-tested: it is checked with real exports.

## Adding a Module

1. New include `YDDIC_TOOL_X_<TYPE>` with `CLASS lcl_exp_<type> DEFINITION INHERITING FROM lcl_exporter_base FINAL`, redefining `get_info`, `validate`, `export` (helpers: `check_length`, `check_auth`, `lcl_source_reader=>read`).
2. `INCLUDE yddic_tool_x_<type>.` in the main program, before `YDDIC_TOOL_REG`.
3. `( NEW lcl_exp_<type>( ) )` in `LCL_REGISTRY=>GET_ALL` (list order = listbox order).
4. A text symbol `T05`… for the listbox text.
5. Unit tests for any logic of the module that does not read the system.

Selection screen, file naming and download do not change.
