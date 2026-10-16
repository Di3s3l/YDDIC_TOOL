# Installation

← [Documentation](README.md) | 🇮🇹 [Versione italiana](it/installation.md)

## Requirements

- SAP system with ABAP release **7.54** (developed and tested on S/4HANA, SAP_BASIS 754)
- Access to **SE38/SE80**, optionally **SE93**
- Frontend workstation with SAP GUI (required for the file download)
- No DDIC objects to create

## Steps

1. Create the executable program `YDDIC_TOOL` and paste `src/YDDIC_TOOL.prog.abap`. **Save without activating.**
2. For each `INCLUDE` line of the main program, in order, create the include (type *Include program*) and paste the matching file:
   `_TOP`, `_BASE`, `_X_TABL`, `_X_FUNC`, `_X_PROG`, `_X_CLAS`, `_REG`, `_SCR`, `_TEST`. Save without activating.
3. Activate the main program and **all 9 includes together** (select them all in the inactive objects list).
4. Maintain the text elements from [`src/text-element.md`](../src/text-element.md) and activate them.
5. Check: in the editor of the main program, **Ctrl+Shift+F10** runs the unit tests; all must be green.
6. Optional: transaction `YDDIC_TOOL` in **SE93** — *Program and selection screen (report transaction)*, program `YDDIC_TOOL`, screen `1000`.

> Text elements are **not** part of the source files: recreate them in each system.

## Package

Any package works: local (`$TMP`) for a personal tool, or a transportable package if the tool must reach other systems.

## Authorizations

| Object | Values | Why |
|--------|--------|-----|
| `S_TCODE` | `YDDIC_TOOL` | Start the transaction (if created) |
| `S_DEVELOP` | `ACTVT 03`, `OBJTYPE` `TABL`/`FUGR`/`PROG`/`CLAS`/`INTF` | Checked by the program before every export |
| `S_GUI` | `ACTVT 61` | File download (standard check) |
