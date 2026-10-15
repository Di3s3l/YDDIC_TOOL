# YDDIC_TOOL — Text Elements

Authoritative list. Maintain in **SE38 → Goto → Text Elements** and activate.
Max length must not be shorter than the text, otherwise the text is truncated.

## Text Symbols

| Symbol | Max Len | Value | Use |
|--------|---------|-------|-----|
| `B01` | 30 | `Object` | Block title |
| `B02` | 30 | `Output` | Block title |
| `B03` | 40 | `Source filter (optional)` | Block title |
| `T01` | 60 | `Table / structure (DDIC fields)` | Object type listbox |
| `T02` | 60 | `Function module (function group source)` | Object type listbox |
| `T03` | 60 | `Program (full source)` | Object type listbox |
| `T04` | 60 | `Class / interface (pool source)` | Object type listbox |
| `D01` | 60 | `C:\tmp` | Default target directory |
| `H01` | 30 | `FIELD_NAME` | CSV header, column 1 |
| `H08` | 30 | `KEY` | CSV header, column 2 |
| `H02` | 30 | `DATA_ELEMENT` | CSV header, column 3 |
| `H03` | 30 | `DDIC_TYPE` | CSV header, column 4 |
| `H04` | 30 | `LENGTH` | CSV header, column 5 |
| `H05` | 30 | `DECIMALS` | CSV header, column 6 |
| `H06` | 30 | `DESCRIPTION` | CSV header, column 7 |
| `H07` | 30 | `INCLUDE` | CSV header, column 8 |
| `M01` | 70 | `Table/structure not found or not active:` | |
| `M02` | 70 | `Cannot read field structure of` | |
| `M03` | 70 | `Cannot read include structure map: INCLUDE column left empty.` | Non-blocking popup |
| `M04` | 30 | `File saved:` | |
| `M05` | 70 | `File download failed:` | |
| `M06` | 70 | `Missing authorization S_DEVELOP (display) for` | |
| `M07` | 70 | `Function module not found:` | |
| `M08` | 70 | `Program not found or not active:` | |
| `M09` | 70 | `Class/interface not found:` | |
| `M10` | 70 | `No source lines found or matching the filter:` | |
| `M11` | 70 | `Object type not registered:` | |
| `M12` | 70 | `Enter an object name.` | |
| `M13` | 70 | `Enter a valid target directory.` | |
| `M14` | 70 | `Object name too long:` | |
| `M15` | 20 | `lines` | |

A blank or missing CSV header symbol falls back to `NONAME`.

## Selection Texts

Leave **Dictionary Reference** unchecked.

| Name | Text |
|------|------|
| `P_TYPE` | `Object type` |
| `P_NAME` | `Object name` |
| `P_PATH` | `Target directory` |
| `S_KW` | `Keyword` |
