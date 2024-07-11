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
Klonen sie das Repository. Danach können sie dem folgenden Ablauf durchgehen, solange sie in einer Linuxumgebung arbeiten:

1. Geben sie der Datei ./backup_script die Rechte, die es benötigt:
    ```bash
    chmod +x ./backup_script.sh
    ```

2. um sicher zu stellen, das die beiden Files backup_script.sh und backup_config.cfg auch richtig eingelesen werden, müssen wir erst noch dos2unix in unserer Shell installieren:

    ```bash
    sudo apt install dos2unix
    ```

3. dadurch wird uns ermöglicht, die in einer Windowsumgebung geschriebenen Bashscripts auch richtig ausführen. Daher müssen wir nun dos2unix auf das Script und config_file anwenden. Hier wird kurz aufgezeigt, wie das angestellt.

    ```bash
    dos2unix <filename>
    ```

4. Das Skript ausführen (im gleichen Verzeichnis wie wir aktuell sind):
    ```bash
    ./backup_script.sh oder ./backup_script.sh <Backup_Name>
    ```

5. Passe die Variablen `SOURCE_DIR`, `DEST_DIR` `LOG_DIR`, `LOG_FILE`, `LOG_DELETED_FILES` und `RETENTION_PERIOD` nach Bedarf an.

### Cronjob einrichten

1. Öffne die Crontab-Datei indem du den folgenden Code eingibst:

    ```bash
    crontab -e
    ```

2. durch den folgenden Code, den wir am ende des Cron_files hinzufügen, wird täglich um 2 Uhr morgens ein Backup erstellst.

    ```bash
    0 2 * * * /bin/bash /path/to/script/<script_name>
    ```
    
3. mit ```ctrl + X``` speichern wir den neuen Cronjob. Achtung Cronjobs werden nicht in der gleichen Hierarchie angelegt, wie das backup_script.

### Testen

1. Führe das Skript manuell aus, um sicherzustellen, dass es korrekt funktioniert:

    ```bash
    ./backup_script.sh
    ```

    oder wenn wir dem Backup gleich einen Namen mitgeben wollen:

    ```bash
    ./backup_script.sh <Backup_Name>
    ```


