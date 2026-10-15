# Installazione

← [Documentazione](README.md) | 🇬🇧 [English version](../installation.md)

## Requisiti

- Sistema SAP con release ABAP **7.54** (sviluppato e provato su S/4HANA, SAP_BASIS 754)
- Accesso a **SE38/SE80**, facoltativo **SE93**
- Workstation frontend con SAP GUI (necessaria per il download del file)
- Nessun oggetto DDIC da creare

## Passi

1. Creare il programma eseguibile `YDDIC_TOOL` e incollare `src/YDDIC_TOOL.prog.abap`. **Salvare senza attivare.**
2. Per ogni riga `INCLUDE` del programma principale, nell'ordine, creare l'include (tipo *Programma include*) e incollare il file corrispondente:
   `_TOP`, `_BASE`, `_X_TABL`, `_X_FUNC`, `_X_PROG`, `_X_CLAS`, `_REG`, `_SCR`. Salvare senza attivare.
3. Attivare il programma principale e **tutti gli 8 include insieme** (selezionarli tutti nell'elenco degli oggetti inattivi).
4. Inserire gli elementi di testo di [`src/text-element.md`](../../src/text-element.md) e attivarli.
5. Facoltativo: transazione `YDDIC_TOOL` in **SE93** — *Programma e schermata di selezione (transazione report)*, programma `YDDIC_TOOL`, schermata `1000`.

> Gli elementi di testo **non** sono nei file sorgente: vanno ricreati in ogni sistema.

## Pacchetto

Va bene qualsiasi pacchetto: locale (`$TMP`) per un tool personale, oppure trasportabile se il tool deve arrivare in altri sistemi.

## Autorizzazioni

| Oggetto | Valori | Perché |
|---------|--------|--------|
| `S_TCODE` | `YDDIC_TOOL` | Avvio della transazione (se creata) |
| `S_DEVELOP` | `ACTVT 03`, `OBJTYPE` `TABL`/`FUGR`/`PROG`/`CLAS`/`INTF` | Controllata dal programma prima di ogni export |
| `S_GUI` | `ACTVT 61` | Download del file (controllo standard) |
