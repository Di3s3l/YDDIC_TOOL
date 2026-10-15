# Usage

← [Documentation](README.md) | 🇮🇹 [Versione italiana](it/usage.md)

## Selection Screen

| Field | Content |
|-------|---------|
| **Object type** | Table/structure, function module, program, class/interface |
| **Object name** | Required. F4 opens the repository search for the selected type |
| **Target directory** | Required. F4 opens the folder browser. The file name is set by the program |
| **Keyword** | Optional, sources only (see below) |

Changing the object type only refreshes the screen; checks (name, existence, authorization) run on Enter or F8 and stop on the field in error.

## Object Types and Files

| Type | Enter | Exports | File |
|------|-------|---------|------|
| Table / structure | `PRPS`, `BAPIRET2` | One CSV row per field | `TABL_<name>.csv` |
| Function module | `BAPI_PROJECT_GETINFO` | Source of the **whole function group** | `FUNC_<module>.txt` |
| Program | `RM06EF00` | Program and all its includes | `PROG_<name>.txt` |
| Class / interface | `CL_GUI_TOOLBAR`, `IF_MESSAGE` | Full class/interface pool | `CLAS_<name>.txt` |

- UTF-8 with BOM; an existing file with the same name is overwritten.
- Namespaces: `/ABC/OBJECT` becomes `_ABC_OBJECT` in the file name.
- With keywords the name ends in `_GREP` (e.g. `PROG_RM06EF00_GREP.txt`).

### CSV (tables)

```
FIELD_NAME;KEY;DATA_ELEMENT;DDIC_TYPE;LENGTH;DECIMALS;DESCRIPTION;INCLUDE
MANDT;X;MANDT;CLNT;3;0;Client;
POSID;;PS_POSID;CHAR;24;0;WBS Element;PRPS_INC
```

- `KEY` = `X` for primary key fields.
- `INCLUDE` = include structure the field comes from, empty for own fields; nested includes as a path `OUTER>INNER`.
- Descriptions in the logon language; a `;` in a description becomes `,`.

### Sources

A header of `*` lines (object, main program, system, date, includes read / not readable, filter), then one line per source line: include name (40 chars), line number (6 chars), source text.

## Keyword Filter

- One or more words, case-insensitive; a line is exported if it contains **at least one** of them.
- Words entered as **exclusions** (sign E) drop the lines that contain them.
- `*` and `+` work as wildcards (`CALL*BAPI`).
- Examples: `AUTHORITY-CHECK` in a program; `CONSTANTS` in a class.

## Messages

| Message | Meaning |
|---------|---------|
| `Enter an object name.` | Object name empty |
| `... not found ...` | Object missing (or, for tables and programs, not active) |
| `Missing authorization S_DEVELOP (display) for ...` | Display authorization on development objects missing |
| `No source lines found or matching the filter: ...` | No lines, or none matching the keywords |
| `Enter a valid target directory.` | Directory empty or invalid |
| `File download failed: ...` | The PC refused the file (missing folder, permissions, SAP GUI security prompt denied) |
| `File saved: <file> (<n> lines)` | Done |

The download goes through SAP GUI: it does not work in background.
