# Automatisiertes Backup-System

Dieses Projekt besteht aus einem Skript zur automatisierten Erstellung von Backups eines Systems. Das Skript kann durch einen Cronjob regelmässig ausgeführt werden, um sicherzustellen, dass wichtige Daten stets gesichert sind.

## Autoren
- Benedict Brück
- Chaimaa El Jarite

## Funktionen
- Erstellen von komprimierten Backup-Dateien (tar.gz).
- Automatische Speicherung der Backup-Dateien in einem definierten Verzeichnis.
- Optionales Löschen alter Backups, um Speicherplatz zu sparen.
- Automatisierung der Backups durch Einsatz eines Cronjobs.
- Verwaltung von Dateiberechtigungen.
- Ausgabe und Überprüfung von Return Codes zur Fehlerbehandlung.
- Protokollierung von Backup-Aktivitäten in einer Log-Datei.

## Anforderungen
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


## Verwendung

### Skript erstellen / speichern
1. Erstelle eine Datei namens `backup_script.sh` 

2. um sicher zu stellen, das auch die beiden Files backup_script.sh und backup_config.cfg auch richtig eingelesen werden, müssen wir erst noch auf beide 
    ```dos2unix <filename>```
ausführen, da die files in einer Windowsumgebung geschrieben wurden. dafür müssen wir erst einmal dos2unix in unserem Terminal installieren und danach auf das script als auch auf die config_file anwenden.
so können wir sie nun auch richtig auslesen.

2. Mach das Skript ausführbar (im gleichen Verzeichnis wie wir aktuell sind):

    ```bash
    ./backup_script.sh oder ./backup_script.sh <Backup_Name>
    ```

3. Passe die Variablen `SOURCE_DIR`, `DEST_DIR` `LOG_DIR`, `LOG_FILE`, `LOG_DELETED_FILES` und `RETENTION_PERIOD` nach Bedarf an.

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


