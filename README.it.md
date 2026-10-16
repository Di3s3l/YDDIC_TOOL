# YDDIC_TOOL

<img src="assets/sap-s4hana-logo.png" alt="SAP S/4HANA" width="200"/>

![Versione](https://img.shields.io/badge/versione-0.5-blue) ![ABAP](https://img.shields.io/badge/ABAP-7.54-brightgreen)

🇬🇧 [English version](README.md)

Report SAP ABAP modulare che esporta un oggetto del repository SAP in un file sulla workstation frontend: l'elenco dei campi di una tabella o struttura (CSV), oppure il sorgente completo di un gruppo funzioni, di un programma o di una classe/interfaccia (testo).

Pensato per dare a chi analizza o sviluppa senza accesso diretto al sistema (ad esempio un assistente AI) la definizione reale di un oggetto, invece di una deduzione.

---

## Funzionalità

- Una transazione, quattro tipi di oggetto: tabella/struttura, modulo funzione, programma, classe/interfaccia
- CSV con indicatore di chiave, metadati DDIC e percorso degli include di ogni campo (include annidati risolti)
- Sorgenti completi di tutti gli include, anche annidati, seguiti tramite le istruzioni `INCLUDE`; nessun troncamento delle righe; gli include non leggibili o inesistenti sono elencati nella testata del file
- Filtro facoltativo per parola chiave sui sorgenti (caratteri jolly, esclusioni) → file `_GREP`
- Help F4 sul nome dell'oggetto, per tipo
- Output UTF-8 con BOM
- Modulare: ogni tipo di oggetto è una classe locale in un proprio include; per aggiungere un tipo bastano un include e una riga nel registro
- Test ABAP Unit per la logica che non dipende dai dati del sistema (filtro, riconoscimento degli include, nomi dei file, percorso degli include, virgolette nel CSV)

---

## Documentazione

La cartella [`docs/it/`](docs/it/README.md) contiene istruzioni di installazione, guida all'utilizzo e note tecniche.

---

## File

| File | Descrizione |
|------|-------------|
| `src/YDDIC_TOOL.prog.abap` | Programma principale |
| `src/YDDIC_TOOL_*.prog.abap` | 9 include (l'ultimo contiene i test ABAP Unit) |
| `src/text-element.md` | Text elements — copiare i valori in SE38 |
| `docs/` | Documentazione |

---

## Licenza e Copyright

Copyright © 2026 <a href="https://enz.ovh" target="_blank">Di3s3l</a>

Uso personale e uso aziendale interno consentiti. La ridistribuzione o pubblicazione di versioni modificate richiede l'attribuzione all'autore originale.
