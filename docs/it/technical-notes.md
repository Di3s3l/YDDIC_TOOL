# Note tecniche

← [Documentazione](README.md) | 🇬🇧 [English version](../technical-notes.md)

## Architettura

```
YDDIC_TOOL     eventi del report → LCL_SCREEN
 _TOP          tipi, LCX_DDIC_ERROR (definizione), interfaccia LIF_EXPORTER
 _BASE         LCX_DDIC_ERROR (implementazione), LCL_EXPORTER_BASE,
               LCL_SOURCE_READER, LCL_FILE_WRITER
 _X_TABL _X_FUNC _X_PROG _X_CLAS     un modulo per tipo di oggetto
 _REG          LCL_REGISTRY: unico elenco dei moduli
 _SCR          selection screen + LCL_SCREEN (controller)
```

L'ordine degli include è vincolante: le classi locali vanno definite prima dell'uso. Un include TOP contiene solo dichiarazioni, perciò la classe di eccezione è implementata in `_BASE`.

## Contratto dei moduli (`LIF_EXPORTER`)

| Metodo | Contratto |
|--------|-----------|
| `get_info` | Chiave e testo della listbox, prefisso ed estensione del file, supporto del filtro, tipo oggetto per l'F4 |
| `validate` | Lunghezza del nome, poi esistenza, poi `S_DEVELOP 03` (un nome sbagliato dà "non trovato") |
| `export` | Righe del file (`string_table`) |
| `f4_name` | Nome scelto, iniziale se annullato. Default: `REPOSITORY_INFO_SYSTEM_F4` |

Gli errori viaggiano come `LCX_DDIC_ERROR` con il testo finale; il report li mostra come messaggio di stato e resta sulla selection screen.

## Moduli

| Modulo | Validate | Export | Auth `OBJTYPE` |
|--------|----------|--------|----------------|
| `LCL_EXP_TABL` | `DD02L`, attiva | `DDIF_FIELDINFO_GET` + `DDIF_TABL_GET` → CSV | `TABL` |
| `LCL_EXP_FUNC` | `TFDIR`; gruppo da `ENLFDIR` (corretto anche con namespace) | Sorgente del gruppo funzioni | `FUGR` |
| `LCL_EXP_PROG` | `PROGDIR`, attivo | Sorgente del programma | `PROG` |
| `LCL_EXP_CLAS` | `SEOCLASS` (classe o interfaccia) | Pool da `CL_OO_CLASSNAME_SERVICE` | `CLAS` / `INTF` |

**Percorso degli include (TABL).** `DD03P-ADMINFIELD` è il numero di include che racchiudono ogni riga. L'elenco degli include aperti viene accorciato a quel livello a ogni riga: un campo proprio dopo un blocco include, o un campo dopo un include annidato, riceve l'include giusto. La vecchia logica "ultimo `.INCLUDE` incontrato" sbagliava questi casi.

**Sorgenti.** Programma principale, poi i suoi include da `D010INC` in ordine alfabetico, letti con `READ REPORT`. `D010INC` non contiene alcuni include annidati (per esempio quelli degli include generati `$` e degli include di enhancement), quindi si segue anche ogni istruzione `INCLUDE <nome>` dei sorgenti letti, finché non ne compaiono di nuovi; un insieme dei nomi già visti evita doppioni e cicli. `INCLUDE TYPE/STRUCTURE/LIKE` e l'`INCLUDE METHODS` dei class pool sono ignorati. Nessun troncamento di nomi o righe. Gli include non leggibili o inesistenti sono elencati in testata, così un sorgente mancante non viene scambiato per uno inesistente. L'errore scatta solo se non si legge nessuna riga.

**Filtro per parola chiave.** Preparato una volta per export. Riga in maiuscolo; una parola con `*` o `+` confronta con `CP '*parola*'`, altrimenti `CS`. Segno I: almeno una deve corrispondere; segno E: una corrispondenza scarta la riga. La colonna OPTION è ignorata; le voci vuote sono scartate. Zero corrispondenze producono comunque un file (sola testata).

**File.** Cartella normalizzata (un solo `\` finale), nome `<prefisso>_<nome>[_GREP].<ext>` con `/` → `_`, `GUI_DOWNLOAD` ASC, codepage 4110 (UTF-8), BOM.

**Selection screen.** `P_NAME`/`P_PATH` non sono `OBLIGATORY` (il controllo scatterebbe a ogni cambio della listbox): sono segnati come obbligatori e controllati nel codice, di nuovo a `START-OF-SELECTION`.

## Aggiungere un modulo

1. Nuovo include `YDDIC_TOOL_X_<TIPO>` con `CLASS lcl_exp_<tipo> DEFINITION INHERITING FROM lcl_exporter_base FINAL`, che ridefinisce `get_info`, `validate`, `export` (aiuti: `check_length`, `check_auth`, `lcl_source_reader=>read`).
2. `INCLUDE yddic_tool_x_<tipo>.` nel programma principale, prima di `YDDIC_TOOL_REG`.
3. `( NEW lcl_exp_<tipo>( ) )` in `LCL_REGISTRY=>GET_ALL` (ordine dell'elenco = ordine della listbox).
4. Un simbolo di testo `T05`… per il testo della listbox.

Selection screen, nome del file e download non cambiano.
