# YDDIC_TOOL — Elementi di testo

Vai a → Elementi di testo. La lunghezza massima non deve essere minore della lunghezza del testo.

## Simboli di testo

| Simbolo | Lung. max | Testo |
|---|---|---|
| `B01` | 30 | `Object` |
| `B02` | 30 | `Output` |
| `B03` | 40 | `Source filter (optional)` |
| `T01` | 60 | `Table / structure (DDIC fields)` |
| `T02` | 60 | `Function module (function group source)` |
| `T03` | 60 | `Program (full source)` |
| `T04` | 60 | `Class / interface (pool source)` |
| `D01` | 60 | `C:\tmp` |
| `H01` | 30 | `FIELD_NAME` |
| `H02` | 30 | `DATA_ELEMENT` |
| `H03` | 30 | `DDIC_TYPE` |
| `H04` | 30 | `LENGTH` |
| `H05` | 30 | `DECIMALS` |
| `H06` | 30 | `DESCRIPTION` |
| `H07` | 30 | `INCLUDE` |
| `H08` | 30 | `KEY` |
| `M01` | 70 | `Table/structure not found or not active:` |
| `M02` | 70 | `Cannot read field structure of` |
| `M03` | 70 | `Cannot read include structure map: INCLUDE column left empty.` |
| `M04` | 30 | `File saved:` |
| `M05` | 70 | `File download failed:` |
| `M06` | 70 | `Missing authorization S_DEVELOP (display) for` |
| `M07` | 70 | `Function module not found:` |
| `M08` | 70 | `Program not found or not active:` |
| `M09` | 70 | `Class/interface not found:` |
| `M10` | 70 | `No source lines found or matching the filter:` |
| `M11` | 70 | `Object type not registered:` |
| `M12` | 70 | `Enter an object name.` |
| `M13` | 70 | `Enter a valid target directory.` |
| `M14` | 70 | `Object name too long:` |
| `M15` | 20 | `lines` |

`D01` è la cartella proposta all'avvio. `H01`–`H08` sono le intestazioni del CSV (ordine delle colonne: `H01`, `H08`, `H02`–`H07`).

## Testi di selezione

Senza "Testo del dizionario".

| Nome | Testo |
|---|---|
| `P_TYPE` | `Object type` |
| `P_NAME` | `Object name` |
| `P_PATH` | `Target directory` |
| `S_KW` | `Keyword` |
