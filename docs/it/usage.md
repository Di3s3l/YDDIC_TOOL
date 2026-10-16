# Utilizzo

← [Documentazione](README.md) | 🇬🇧 [English version](../usage.md)

## Selection screen

| Campo | Contenuto |
|-------|-----------|
| **Object type** | Tabella/struttura, modulo funzione, programma, classe/interfaccia |
| **Object name** | Obbligatorio. F4 apre la ricerca nel repository per il tipo scelto |
| **Target directory** | Obbligatoria. F4 apre la scelta della cartella. Il nome del file lo decide il programma |
| **Keyword** | Facoltativo, solo sorgenti (vedi sotto) |

Cambiando il tipo la schermata si aggiorna soltanto; i controlli (nome, esistenza, autorizzazione) avvengono con Invio o F8 e si fermano sul campo in errore.

## Tipi di oggetto e file

| Tipo | Inserire | Esporta | File |
|------|----------|---------|------|
| Tabella / struttura | `PRPS`, `BAPIRET2` | Una riga CSV per campo | `TABL_<nome>.csv` |
| Modulo funzione | `BAPI_PROJECT_GETINFO` | Sorgente **dell'intero gruppo funzioni** | `FUNC_<modulo>.txt` |
| Programma | `RM06EF00` | Programma e tutti i suoi include | `PROG_<nome>.txt` |
| Classe / interfaccia | `CL_GUI_TOOLBAR`, `IF_MESSAGE` | Pool completo della classe/interfaccia | `CLAS_<nome>.txt` |

- UTF-8 con BOM; un file con lo stesso nome viene sovrascritto.
- Namespace: `/ABC/OGGETTO` diventa `_ABC_OGGETTO` nel nome del file.
- Con le keyword il nome termina in `_GREP` (es. `PROG_RM06EF00_GREP.txt`).

### CSV (tabelle)

```
FIELD_NAME;KEY;DATA_ELEMENT;DDIC_TYPE;LENGTH;DECIMALS;DESCRIPTION;INCLUDE
MANDT;X;MANDT;CLNT;3;0;Mandante;
POSID;;PS_POSID;CHAR;24;0;Elemento WBS;PRPS_INC
```

- `KEY` = `X` per i campi della chiave primaria.
- `INCLUDE` = struttura inclusa da cui arriva il campo, vuoto per i campi propri; include annidati come percorso `ESTERNO>INTERNO`; `?` = sconosciuto (mappa degli include non leggibile, con popup).
- Descrizioni nella lingua di accesso; una descrizione che contiene `;` o `"` va tra virgolette, con `"` raddoppiate (RFC 4180).

### Sorgenti

Una testata di righe `*`, poi una riga per riga di sorgente: nome dell'include (40 caratteri), numero di riga (6 caratteri), testo.

| Riga di testata | Significato |
|-----------------|-------------|
| `Includes read: n of m` | Include letti su tutti quelli trovati |
| `Found by scan` | Include raggiunti solo tramite un'istruzione `INCLUDE` (non elencati dal sistema per il programma principale) |
| `Not readable` | Elencati dal sistema, sorgente non leggibile |
| `Not found` | Citati da un'istruzione `INCLUDE`, sorgente inesistente |
| `Filter`, `Lines matched: n of m` | Parole chiave usate e righe tenute su tutte quelle lette |

Gli include si prendono dall'elenco del sistema per il programma principale, poi si segue ogni istruzione `INCLUDE` dei sorgenti letti finché non ne compaiono di nuovi.

## Filtro per parola chiave

- Una o più parole, maiuscole e minuscole indifferenti; una riga viene esportata se contiene **almeno una** delle parole.
- Le parole inserite come **esclusione** (segno E) scartano le righe che le contengono.
- `*` e `+` funzionano come caratteri jolly (`CALL*BAPI`).
- Esempi: `AUTHORITY-CHECK` in un programma; `CONSTANTS` in una classe.
- Nessuna riga trovata non è un errore: il file `_GREP` viene scritto con la sola testata e `Lines matched: 0 of n`.
- Il filtro tiene righe singole: serve a individuare il codice, non come base per un'analisi completa.

## Messaggi

| Messaggio | Significato |
|-----------|-------------|
| `Enter an object name.` | Object name vuoto |
| `... not found ...` | Oggetto inesistente (o, per tabelle e programmi, non attivo) |
| `Missing authorization S_DEVELOP (display) for ...` | Manca l'autorizzazione di visualizzazione sugli oggetti di sviluppo |
| `No source lines found: ...` | Nessun sorgente leggibile |
| `Enter a valid target directory.` | Cartella vuota o non valida |
| `File download failed: ...` | Il PC ha rifiutato il file (cartella inesistente, permessi, conferma di sicurezza SAP GUI negata) |
| `File saved: <file> (<n> lines)` | Fatto |

Il download passa da SAP GUI: non funziona in background.
