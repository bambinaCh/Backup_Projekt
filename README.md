# Automatisiertes Backup-System

Dieses Projekt besteht aus einem Skript zur automatisierten Erstellung von Backups eines Systems. Das Skript kann durch einen Cronjob regelmässig ausgeführt werden, um sicherzustellen, dass wichtige Daten stets gesichert sind.

## Autoren

- Benedict Brück
- Chaimaa El Jarite

## Funktionen

- Return Codes
- if else / while / switch / for
- Test
- File Permission
- Shebang
- I/O Stream/Redirection
- Shell Variablen
- Functions (sinnvolle Namensgebung)
- [] und [[ ]] richtig anwenden
- String  vergleich
- Config um Variablen auszulesen

## Anforderungen

- Unix-ähnliches Betriebssystem (Linux, macOS)
- Bash
- tar (Standard Unix-Tool)
- cron (für die Automatisierung)
- Kenntnisse in den Bereichen Unix Utilities, File Permissions, Return Codes, Kontrollstrukturen (if, for, while), Funktionen und Skript-Good Practices

## Verwendung

### Skript erstellen / speichern

1. Erstelle eine Datei namens `backup_script.sh` 

2. Mach das Skript ausführbar:

    ```bash
    chmod +x backup_script.sh
    ```

3. Passe die Variablen `SOURCE_DIR`, `DEST_DIR` und `LOG_FILE` nach Bedarf an.

### Cronjob einrichten

1. Öffne die Crontab-Datei:

    ```bash
    crontab -e
    ```

2. Füge die folgende Zeile hinzu, um das Skript jeden Tag zb. um 2 Uhr morgens auszuführen:

    ```bash
    0 2 * * * /path/to/backup_script.sh
    ```

3. Speichere die Änderungen und beende den Editor.

### Testen

1. Führe das Skript manuell aus, um sicherzustellen, dass es korrekt funktioniert:

    ```bash
    ./backup_script.sh
    ```


