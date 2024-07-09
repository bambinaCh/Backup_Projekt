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
LIGHTGREEN='\033[1;32m' # Hellgrün
BLUE='\033[0;34m' # Blau
RED='\033[0;31m' # Rot
ORANGE='\033[0;33m' # Orange
YELLOW='\033[1;33m' # Gelb
CYAN='\033[0;36m' # Cyan
MAGENTA='\033[0;35m' # Magenta
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

# Backup-Name hinzufügen
check_Backup_name() {
  if [ $# -eq 1 ];then
    BACKUP_FILE="backup_$1_$DATE.tar.gz"
    log "${LIGHTGREEN}Success: Backupname wurde hinzugefügt, der neue Backupname ist ${BACKUP_FILE}${NC}"

  elif [ $# -eq 0 ];then
    echo -e "${CYAN}Möchtest du dem Backup einen eigenen Namen geben?(yes/no): ${NC}"
    read -r ANSWER
    if [[ "$ANSWER" == "yes" ]];then
      echo -e "${CYAN}Bitte gib einen Backup Namen ein: ${NC}"
      read -r BACKUP_NAME
      BACKUP_FILE="backup_${BACKUP_NAME}_${DATE}.tar.gz"
      log "${LIGHTGREEN}Success: Backupname wurde hinzugefügt, der neue Backupname ist ${BACKUP_FILE}${NC}"
    else
      BACKUP_FILE="backup_${DATE}.tar.gz"
      log "${LIGHTGREEN}Success: Backupname wurde hinzugefügt, der neue Backupname ist default${NC}"
    fi
  else
    log "${ORANGE}Usage: $0 oder $0 <Backup_name>${NC}"
    exit 2
  fi
}

# Argumente aus config_file prüfen
check_arguments() {
      # test ob source_dir und dest_dir in config_file gesetzt sind
    if [[ -z "$SOURCE_DIR" || -z "$DEST_DIR" ]]; then
      log "${RED}Error: Source_dir und dest_dir müssen im config_file angegeben sein und dürfen nicht leer sein.${NC}"
      exit 2
    else
      # test ob log_file in config_file gesetzt ist
      if [[ -z "$LOG_FILE" ]]; then
        log "${RED}Error: Log_file muss im config_file angegeben sein und darf nicht leer sein.${NC}"
        exit 2
      fi
      # test ob retention_period in config_file gesetzt ist
      if [[ -z "$RETENTION_PERIOD" ]]; then
        log "${RED}Error: Retention period must be provided in the config_file and cannot be empty.${NC}"
        exit 2
      fi
      log "${LIGHTGREEN}Success: alle Argumente sind richtig gesetzt und nicht leer.${NC}"
    fi
}

# Berechtigungen überprüfen
check_permissions() {
    # check die Berechtigung zum lesen in source_dir
    if [[ ! -r "$SOURCE_DIR" ]];then
        log "${RED}Error: Kein Leserecht für das Quellverzeichnis ${SOURCE_DIR}.${NC}"
        exit 1
    fi
    # check die Berechtigung zum schreiben in dest_dir
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
    # -f: spezifiziert den Dateinamen des Archivs, hier "$DEST_DIR/$BACKUP_FILE"
    tar -czvf "$DEST_DIR/$BACKUP_FILE" "$SOURCE_DIR"

    # tar gibt exit code zurück. 0 bedeutet Erfolg, 1 bedeutet Fehler
    TAR_EXIT_CODE=$?

    # check if exit code is 0 or else
    if [ $TAR_EXIT_CODE -eq 0 ];then
        log "${LIGHTGREEN}Success: Backup erfolgreich erstellt: ${DEST_DIR}/${BACKUP_FILE}${NC}"
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
    log "${CYAN}Backup-Skript gestartet${NC}"

    add_Backup_name

    log "${CYAN}prüfe variablen aus config_file und Umgebung${NC}"

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
