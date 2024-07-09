#!/bin/bash
# Backup-Skript zur Sicherung eines Verzeichnisses von El Jarite und Brück

# echo "The script name is: $0"
# echo "The first argument is: $1"
# echo "The second argument is: $2"
# echo "Anzahl der Argumente: $#"
# echo "Alle Argumente: $*"
# echo "Alle Argumente, aufgeteilt: $@"



# definiere einige Farben für die Konsolenausgabe
GREEN='\033[0;32m' # Grün
RED='\033[0;31m' # Rot
CYAN='\033[0;36m' # Cyan
NC='\033[0m' # Keine Farbe

# Konfigurationsdatei laden und Variablen für source_dir, dest_dir, log_file and retention_period setzen
CONFIG_FILE="backup_config.cfg"

# Prüfen, ob Konfigurationsdatei vorhanden ist, und setzte Variablen aus config_file
if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
else
    log "${RED}Error: Config-Datei ${CONFIG_FILE} nicht gefunden.${NC}"
    exit 1
fi

# definierte Variablen aus config_file laden
SOURCE_DIR="$SOURCE_DIR"              # Verzeichnis, das gesichert werden soll
DEST_DIR="$DEST_DIR"                  # Zielverzeichnis für das Backup
LOG_FILE="$LOG_FILE"                  # Log-Datei
RETENTION_PERIOD="$RETENTION_PERIOD"  # Anzahl Tage, wie lange Backups aufbewahrt werden sollen

#Aktuelles Datum und Uhrzeit
DATE=$(date +%Y-%m-%d_%H-%M-%S)

# Funktion zur Protokollierung
log() {
    # $1 ist in diesem fall hier nicht mehr das argument(welches mitgegeben werden kann, sondern der Text aus der logfunction(error or success)
    echo -e "$(date +%Y-%m-%d_%H-%M-%S) : $1" >> "$LOG_FILE"
}

# Anzahl Argumente Prüfen
check_arguments() {
    #  check if argument is 1
    if [ $# -eq 1 ];then
      # test if source and destination directories are set values from config_file
      if [[ -z "$SOURCE_DIR" || -z "$DEST_DIR" ]]; then
        log "${RED}Error: Source and destination directories must be provided in the config_file and cannot be empty.${NC}"
        exit 2
      else
        BACKUP_FILE="backup_$1_$DATE.tar.gz"
        log "${CYAN}Success: Arguments from config and Backup_name are passed, Backup name is ${BACKUP_FILE}${NC}"
      fi
    #  check if more than 1 argument
    elif [ $# -gt 1 ];then
      log "${RED}Usage: $0 OR $0 <Backup_name>${NC}"
      exit 2
    #  check if no argument is passed
    else
      # test if source and destination directories are set values from config_file
      if [[ -z "$SOURCE_DIR" || -z "$DEST_DIR" ]]; then
        log "${RED}Error: Source and destination directories must be provided and cannot be empty.${NC}"
        exit 2
      else
        BACKUP_FILE="backup_$DATE.tar.gz"
        log "${CYAN}Success: Arguments from config are passed, Backup name is ${BACKUP_FILE}${NC}"
      fi
    fi
}

# Berechtigungen überprüfen
check_permissions() {
    # if no permission to read source directory
    if [[ ! -r "$SOURCE_DIR" ]];then
        log "${RED}Error: Kein Leserecht für das Quellverzeichnis ${SOURCE_DIR}.${NC}"
        exit 1
    fi
    # if no permission to write in destination directory
    if [[ ! -w "$DEST_DIR" ]];then
        log "${RED}Error: Kein Schreibrecht für das Zielverzeichnis ${DEST_DIR}.${NC}"
        exit 1
    fi
}

# Backup erstellen
create_backup() {
    # tar: tape archive, genutzt zum erstellen, verwalten und extrahieren von Archivdateien
    # kann mehrere Dateien und Verzechnisse in einem Archiv zusammenfassen
    # -c: erstellt ein neues Archiv
    # -z: Kompression mit gzip
    # -v: ausführliche Ausgabe
    # -f: spezifiziert den Dateinamen des Archivs
    tar -czvf "$DEST_DIR/$BACKUP_FILE" "$SOURCE_DIR"

    # tar gibt exit code zurück. 0 bedeutet Erfolg, 1 bedeutet Fehler
    TAR_EXIT_CODE=$?

    # check if exit code is 0 or else
    if [ $TAR_EXIT_CODE -eq 0 ];then
        log "${GREEN}Success: Backup erfolgreich erstellt: ${DEST_DIR}/${BACKUP_FILE}${NC}"
    else
        log "${RED}Error: Fehler beim Erstellen des Backups${NC}"
        exit 2
    fi
}

# Alte Backups löschen
delete_old_backups() {
    find "$DEST_DIR" -type f -name "backup_*.tar.gz" -mtime +${RETENTION_PERIOD} -exec rm {} \;
    find "$DEST_DIR" -type f -name "backup_*_*.tar.gz" -mtime +${RETENTION_PERIOD} -exec rm {} \;
    FIND_EXIT_CODE=$?

    if [ $FIND_EXIT_CODE -ne 0 ];then
        log "${RED}Error: Fehler beim Löschen alter Backups${NC}"
        exit 2
    fi
}

# Hauptfunktion
main() {
    log "${CYAN}check if 2 or 3 arguments are passed${NC}"

    check_arguments "$@"

    log "${CYAN}Backup gestartet${NC}"

    check_permissions
    create_backup
    delete_old_backups

    log "${GREEN}Backup abgeschlossen${NC}"
    exit 0

}

# Skript starten
main "$@"
