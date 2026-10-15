# YDDIC_TOOL — Documentazione

## Installazione

1. SE38/SE80: creare il programma eseguibile `YDDIC_TOOL` e gli 8 include di `src/` (tipo include), nell'ordine delle righe `INCLUDE` del main. Salvare senza attivare.
2. Attivare tutti gli oggetti insieme.
3. Inserire gli elementi di testo di [`simboli_testo.md`](simboli_testo.md) e attivarli.
4. Facoltativo: transazione `YDDIC_TOOL` (SE93, transazione report, schermata `1000`).

Autorizzazioni dell'utente: `S_DEVELOP` con `ACTVT 03` sugli oggetti da esportare (controllata dal programma), `S_GUI` con `ACTVT 61` per il download.

## Uso

| Campo | Contenuto |
|---|---|
| Object type | Tabella/struttura, modulo funzione, programma, classe/interfaccia |
| Object name | Nome dell'oggetto (F4 disponibile) |
| Target directory | Cartella sul PC |
| Keyword | Facoltativo, solo sorgenti: esporta le righe che contengono una delle parole (`*`/`+` come jolly, esclusione con il segno E) |

| Tipo | Esporta | File |
|---|---|---|
| Tabella/struttura | Una riga per campo: `FIELD_NAME;KEY;DATA_ELEMENT;DDIC_TYPE;LENGTH;DECIMALS;DESCRIPTION;INCLUDE` | `TABL_<nome>.csv` |
| Modulo funzione | Sorgente dell'intero gruppo funzioni | `FUNC_<modulo>.txt` |
| Programma | Programma e tutti i suoi include | `PROG_<nome>.txt` |
| Classe/interfaccia | Pool completo, include compresi | `CLAS_<nome>.txt` |

File in UTF-8 con BOM. Con le keyword il nome termina in `_GREP`. Nel CSV la colonna `INCLUDE` riporta il percorso degli include annidati (`ESTERNO>INTERNO`). Nei sorgenti ogni riga è `include, numero di riga, testo`, preceduta da una testata `*` con oggetto, sistema, include letti e non leggibili, filtro.

## Architettura

```
YDDIC_TOOL    eventi del report
 _TOP         tipi, eccezione, interfaccia LIF_EXPORTER
 _BASE        modulo base (autorizzazione, F4), lettore sorgenti, scrittura file
 _X_<tipo>    un modulo per tipo: TABL, FUNC, PROG, CLAS
 _REG         registro dei moduli (ordine = ordine della listbox)
 _SCR         selection screen e controller
```

Ogni modulo eredita da `LCL_EXPORTER_BASE` e implementa `get_info`, `validate` (lunghezza, esistenza, autorizzazione), `export` (righe del file). Selection screen, nome file e download sono comuni.

Aggiungere un tipo: nuovo include `YDDIC_TOOL_X_<tipo>` con la classe del modulo, riga `INCLUDE` nel main prima di `_REG`, una riga in `LCL_REGISTRY=>GET_ALL`, un simbolo di testo per la descrizione.
