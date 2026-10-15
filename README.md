# YDDIC_TOOL

<img src="assets/sap-s4hana-logo.png" alt="SAP S/4HANA" width="200"/>

![Version](https://img.shields.io/badge/version-0.3-blue) ![ABAP](https://img.shields.io/badge/ABAP-7.54-brightgreen)

🇮🇹 [Versione italiana](README.it.md)

Modular SAP ABAP report that exports an SAP repository object to a file on the frontend workstation: the field list of a table or structure (CSV), or the full source of a function group, program, or class/interface (text).

Built to give whoever analyzes or develops without direct system access (for example an AI assistant) the real definition of an object instead of a guess.

---

## Features

- One transaction, four object types: table/structure, function module, program, class/interface
- CSV with key flag, DDIC metadata and the include path of each field (nested includes resolved)
- Full sources with every include, no line truncation; unreadable includes listed in the file header
- Optional keyword filter on sources (wildcards, exclusions) → `_GREP` file
- F4 value help on the object name, per object type
- UTF-8 output with BOM
- Modular: each object type is a local class in its own include; adding a type needs one include and one registry line

Successor of `Y_EXPORT_DICTABLE`, whose table export it includes.

---

## Documentation

The [`docs/`](docs/README.md) folder contains installation instructions, usage guide and technical notes.

---

## Files

| File | Description |
|------|-------------|
| `src/YDDIC_TOOL.prog.abap` | Main program |
| `src/YDDIC_TOOL_*.prog.abap` | 8 includes |
| `src/text-element.md` | Text elements — copy values from here into SE38 |
| `docs/` | Documentation |

---

## License & Copyright

Copyright © 2026 <a href="https://enz.ovh" target="_blank">Di3s3l</a>

Personal use and internal corporate use permitted. Redistribution or publication of modified versions requires attribution to the original author.
