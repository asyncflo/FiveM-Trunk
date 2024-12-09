# FiveM-Trunk
FiveM Trunk Inventory

Erklärungen:
Kofferraum-Erkennung: Das Skript prüft, ob der Spieler sich hinter einem Fahrzeug befindet, indem die Position des Spielers relativ zur Position und Ausrichtung des Fahrzeugs berechnet wird.

Trunk-Inventar: Es gibt ein einfaches trunkInventories-Array, das anhand des Nummernschilds (plate) die Gegenstände speichert. Jeder Kofferraum kann bis zu 20 Gegenstände speichern.

Taste "K": Mit der Taste "K" wird der Befehl trunk ausgeführt, der den Kofferraum öffnet, falls der Spieler hinter einem Fahrzeug steht.

Gegenstandsverwaltung: Die aktuelle Logik verwendet einfache Chat-Meldungen und die E-Taste zum Hinzufügen eines Testitems. Das kannst du durch eine eigene UI für das Inventar ersetzen.

Installation:
Speichere das Skript im Resource-Ordner, z. B. resources/[your_scripts]/trunk_inventory.
Füge die Resource in die server.cfg hinzu:
cfg
ensure trunk_inventory
Starte den Server neu.


Anpassungen:
UI: Das Skript kann erweitert werden, um ein natives UI-Menü anzuzeigen.
Persistenz: Speicher das Inventar in einer Datenbank, damit der Inhalt auch nach einem Serverneustart erhalten bleibt.





