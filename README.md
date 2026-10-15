# YDDIC_TOOL

Report ABAP che esporta su un file del PC le informazioni di un oggetto SAP: i campi di una tabella o struttura (CSV), oppure il sorgente completo di un gruppo funzioni, di un programma o di una classe/interfaccia (testo).

Serve quando chi analizza o sviluppa non ha accesso diretto al sistema, ad esempio un assistente AI: invece di dedurre firme e campi, legge la versione reale dell'oggetto.

- Transazione unica, quattro tipi di oggetto, filtro facoltativo per parola chiave sui sorgenti.
- Architettura modulare: ogni tipo di oggetto è una classe locale in un proprio include; per aggiungere un tipo basta un include e una riga nel registro.
- Sintassi ABAP 7.54; nessun oggetto DDIC da creare.

| | |
|---|---|
| [`src/`](src/) | Sorgenti: programma principale e 8 include |
| [`doc/documentazione.md`](doc/documentazione.md) | Installazione, uso, architettura |
| [`doc/simboli_testo.md`](doc/simboli_testo.md) | Simboli di testo e testi di selezione |
