# Projekt Straßenbahnfahrplan

Projekt für das Praktikum Wissensrepräsentation

## Struktur

* `instance/`          enth. Beispiel
* `modellierung.lp`    Modellierung
* `planung.lp`         Planung bzw. Simulation
* `optimierung.lp`     Optimierung
* `_ausgabe.lp`        lesbares Ausgabeformat

Test mit

$ clingo instance01/instance.lp einfache_ausgabe.lp | sed "s|) |)\n|g"

## Optimierung

$ clingo instance01/instance.lp optimierung.lp einfache_ausgabe.lp
