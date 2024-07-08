#!/bin/bash

# Backup-Skript zur Sicherung eines Verzeichnisses


CONFIG_FILE="backup_config.cfg"     # Konfigurationsdatei laden

# Prüfen, ob Konfigurationsdatei vorhanden ist, und setzte Variablen aus config_file
if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
else
    echo "Fehler: Config-Datei $CONFIG_FILE nicht gefunden."
    exit 1
fi

# definierte Variablen aus config_file laden
SOURCE_DIR="$SOURCE_DIR"            # Verzeichnis, das gesichert werden soll
DEST_DIR="$DEST_DIR"                # Zielverzeichnis für das Backup
LOG_FILE="$LOG_FILE"                # Log-Datei

#Aktuelles Datum und Uhrzeit
DATE=$(date +%Y-%m-%d_%H-%M-%S)     # Aktuelles Datum und Uhrzeit

# Funktion zur Protokollierung
log() {
    echo "$(date +%Y-%m-%d_%H-%M-%S) : $1" >> "$LOG_FILE"
}

# Anzahl Argumente Prüfen
check_arguments() {
    if [[ $# -lt 2 ]];then
        log "Usage: $0 <source_dir> <dest_dir> OR $0 <source_dir> <dest_dir> <Backup_name>"
        exit 1
    elif [ $# -gt 3 ]; then
        log "Usage: $0 <source_dir> <dest_dir> <backup_name> OR $0 <source_dir> <dest_dir>"
        exit 1
    else [ $# -eq 3 ]
        if [ -n "$3" ]; then
            BACKUP_FILE="backup_$3_$DATE.tar.gz"
            Log "3 arguments are passed, Backup name is $BACKUP_FILE"
        else
            BACKUP_FILE="backup_$DATE.tar.gz"
            Log "2 arguments are passed, Backup name is $BACKUP_FILE"
        fi
    fi
}

# Berechtigungen überprüfen
check_permissions() {
    # if no permission to read source directory
    if [ ! -r "$SOURCE_DIR" ];then
        log "Fehler: Kein Leserecht für das Quellverzeichnis $SOURCE_DIR."
        exit 1
    fi
    # if no permission to write destination directory
    if [ ! -w "$DEST_DIR" ];then
        log "Fehler: Kein Schreibrecht für das Zielverzeichnis $DEST_DIR."
        exit 1
    fi
}

# Backup erstellen
create_backup() {
    tar -czvf "$DEST_DIR/$BACKUP_FILE" "$SOURCE_DIR"
    TAR_EXIT_CODE=$?

    if [ $TAR_EXIT_CODE -eq 0 ];then
        log "Backup erfolgreich erstellt: $DEST_DIR/$BACKUP_FILE"
    else
        log "Fehler beim Erstellen des Backups"
        exit 1
    fi
}

# Alte Backups löschen
delete_old_backups() {
    find "$DEST_DIR" -type f -name "backup_*.tar.gz" -mtime +7 -exec rm {} \;
    FIND_EXIT_CODE=$?

    if [ $FIND_EXIT_CODE -ne 0 ];then
        log "Fehler beim Löschen alter Backups"
        exit 1
    fi
}

# Hauptfunktion
main() {
    Log "check if 2 or 3 arguments are passed"

    check_arguments

    log "Backup gestartet"

    check_permissions
    create_backup
    delete_old_backups

    log "Backup abgeschlossen"
}

# Skript starten
main