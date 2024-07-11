#!/bin/bash
# Version: 1.0
# Author: El Jarite und Brück
# Description: Shell-Skript zum Erstellen von Backups
# Shell-Application: ./backup_script.sh oder ./backup_script.sh <Backup_name>
# require: backup_config.cfg

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

# Konfigurationsdatei laden
CONFIG_FILE="backup_config.cfg"

# Funktion zur Protokollierung
log() {
  echo -e "$(date +%Y-%m-%d_%H-%M-%S) : $1" >> "${DEST_DIR}/${LOG_DIR}/${LOG_FILE}"
}

# Prüfen, ob Konfigurationsdatei vorhanden ist, und setze Variablen aus config_file
if [[ -f "$CONFIG_FILE" ]]; then
  source "$CONFIG_FILE"
  echo -e "${LIGHTGREEN}Config_Datei gefunden.${NC}"
  log "Config Datei gefunden."
else
  echo -e "${RED}Error: Config-Datei ${CONFIG_FILE} nicht gefunden.${NC}"
  log "Config-Datei nicht gefunden."
  exit 1
fi

# definiere Variablen aus config_file
SOURCE_DIR="${SOURCE_DIR}"
DEST_DIR="${DEST_DIR}"
LOG_DIR="${LOG_DIR}"
LOG_FILE="${LOG_FILE}"
LOG_DELETED_FILES="${LOG_DELETED_FILES}"
RETENTION_PERIOD="${RETENTION_PERIOD}"

# Hirarchie der Backupstructur prüfen und falls nicht vorhanden, erweitern
create_hirarchie() {
  if [[ ! -d "$DEST_DIR" ]]; then
    echo -e "${ORANGE}Warnung: Zielverzeichnis ${DEST_DIR} existiert nicht, wird erstellt.${NC}"
    log "Warnung: Zielverzeichnis ${DEST_DIR} existiert nicht, wird erstellt"
    mkdir -p "$DEST_DIR"
    chmod a+w "$DEST_DIR"
  fi

  if [[ ! -d "${DEST_DIR}/${LOG_DIR}" ]]; then
    mkdir -p "${DEST_DIR}/${LOG_DIR}"
    chmod a+w "${DEST_DIR}/${LOG_DIR}"
  fi
  echo -e "${LIGHTGREEN}Backup-Structur erstellt.${NC}"
  log "Backup-Structur erstellt."
}

#Aktuelles Datum und Uhrzeit
DATE=$(date +%Y-%m-%d_%H-%M-%S)

# Argumente aus config_file prüfen
check_arguments() {
  if [[ -z "$SOURCE_DIR" || -z "$DEST_DIR" || -z "$LOG_FILE" || -z "$RETENTION_PERIOD" ]]; then
    echo -e "${RED}Error: Eine oder mehrere notwendige Variablen sind nicht in der config_file angegeben.${NC}"
    log "eine oder mehrere Variablen sind im config file nicht angegeben."
    exit 2
  fi
  echo -e "${LIGHTGREEN}Alle Agrumente sind richtig gesetzt und nicht leer.${NC}"
  log "Alle Argumente sind richtig gesetzt und nicht leer."
}

# Berechtigungen überprüfen
check_permissions() {
  if [[ ! -e "$SOURCE_DIR" ]]; then
    echo -e "${RED}Error: Quellverzeichnis ${SOURCE_DIR} existiert nicht.${NC}"
    log "Error: Das Quellenverzeichnis ${DEST_DIR} nicht gefunden, wird erstellt."
    exit 1
  fi

  if [[ ! -r "$SOURCE_DIR" ]]; then
    echo -e "${RED}Error: Keine Leserecht für das Quellverzeichnis ${SOURCE_DIR}.${NC}"
    log "Error: Kein Leserecht für das Quellenverzeichnis ${DEST_DIR, wird erstellt}."

    exit 1
  fi

  if [[ ! -d "$DEST_DIR" ]]; then
    echo -  "${ORANGE}Warnung: Zielverzeichnis ${DEST_DIR} existiert nicht, wird erstellt.${NC}"
    log "Warnung: das Zielverzeichnis ${DEST_DIR} existiert nicht, wird erstellt."
    mkdir -p "$DEST_DIR"
    chmod a+w "$DEST_DIR"
  fi

  if [[ ! -w "$DEST_DIR" ]]; then
    echo -e "${RED}Error: Kein Schreibrecht für das Zielverzeichnis ${DEST_DIR}.${NC}"
    log "Warnung: Kein Schreibrecht für das Zielverzeichnis ${DEST_DIR}."
    exit 1
  fi

  if [[ ! -d "${DEST_DIR}/${LOG_DIR}" ]]; then
    mkdir -p "${DEST_DIR}/${LOG_DIR}"
    chmod a+w "${DEST_DIR}/${LOG_DIR}"
  fi

  if [[ ! -w "${DEST_DIR}/${LOG_DIR}" ]]; then
    echo -e "${RED}Error: Kein Schreibrecht für das Log-Verzeichnis ${DEST_DIR}/${LOG_DIR}.${NC}"
    log "Warnung: Kein Schreibrecht für Log-Verzeichnis ${DEST_DIR}/${LOG_DIR}."
    exit 1
  fi
  echo -e "${LIGHTGREEN}Alle Berechtigungen sind in Ordnung.${NC}"
  log "Alle Berechntigungen sind in Ordnung!"
}

# Backup-Name hinzufügen
check_Backup_name() {
  if [[ $# -eq 1 ]]; then
    BACKUP_FILE="backup_$1_$DATE.tar.gz"
  elif [[ $# -eq 0 ]]; then
    read -p "Möchtest du dem Backup einen eigenen Namen geben? (y/n):" ANSWER
    if [[ "$ANSWER" == "y" ]]; then
      read -p "Bitte gib einen Backup Namen ein:" BACKUP_NAME
      BACKUP_FILE="backup_${BACKUP_NAME}_${DATE}.tar.gz"
    else
      BACKUP_FILE="backup_${DATE}.tar.gz"
    fi
  else
    echo -e "${CYAN}Usage: $0 oder $0 <Backup_name>${NC}"
    log "Usage: $0 oder $0 <Backup_name>"
    exit 2
  fi
  echo -e "${LIGHTGREEN}Backupname wurde hinzugefügt: ${BACKUP_FILE}.${NC}"
  log "Backupname wurde hinzugefügt: ${BACKUP_FILE}"
}

# Backup erstellen
create_backup() {
  tar -czvf "${DEST_DIR}/${BACKUP_FILE}" "$SOURCE_DIR"
  TAR_EXIT_CODE=$?

  if [[ $TAR_EXIT_CODE -eq 0 ]]; then
    echo -e "${LIGHTGREEN}Success: Backup erfolgreich erstellt: ${DEST_DIR}/${BACKUP_FILE}${NC}"
    log "Success: Backup erfolgreich erstellt: ${DEST_DIR}/${BACKUP_FILE}"
  else
    echo -e "${RED}Error: Fehler beim Erstellen des Backups${NC}"
    log "Error: Fehler beim Erstellen des Backups"
    exit 2
  fi
}

# Alte Backups löschen
delete_old_backups() {
  find "$DEST_DIR" -type f -name "backup_*.tar.gz" -mtime +${RETENTION_PERIOD} -exec rm {} \; >> "${DEST_DIR}/${LOG_DIR}/${LOG_DELETED_FILES}"
  FIND_EXIT_CODE1=$?

  find "$DEST_DIR" -type f -name "backup_*_*.tar.gz" -mtime +${RETENTION_PERIOD} -exec rm {} \; >> "${DEST_DIR}/${LOG_DIR}/${LOG_DELETED_FILES}"
  FIND_EXIT_CODE2=$?

  if [[ $FIND_EXIT_CODE1 -ne 0 || $FIND_EXIT_CODE2 -ne 0 ]]; then
    echo -e "${RED}Error: Fehler beim Löschen alter Backups.${NC}"
    log "Error: Fehler beim löschen alter Backups."
    exit 2
  fi
}

# Hauptfunktion
main() {
  echo -e "${LIGHTGREEN}Backupscript gestartet.${NC}"
  log "Backup-Skript gestartet"

  check_Backup_name "$@"
  create_hirarchie
  check_arguments
  check_permissions
  create_backup
  delete_old_backups

  echo -e "${GREEN}Backup erfolgreich abgeschlossen.${NC}"
  log "Backup erfolgreich abgeschlossen."
  exit 0
}

# Skript starten
main "$@"
