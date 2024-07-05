#!/bin/bash

# Backup-Skript zur Sicherung eines Verzeichnisses

# Variablen definieren
SOURCE_DIR="/path/to/source"        # Verzeichnis, das gesichert werden soll
DEST_DIR="/path/to/backup"          # Zielverzeichnis für das Backup
DATE=$(date +%Y-%m-%d_%H-%M-%S)     # Aktuelles Datum und Uhrzeit
BACKUP_FILE="backup_$DATE.tar.gz"   # Name der Backup-Datei
LOG_FILE="/path/to/log/backup.log"  # Log-Datei

# Funktion zur Protokollierung
log() {
    echo "$(date +%Y-%m-%d_%H-%M-%S) : $1" >> "$LOG_FILE"
}

# Berechtigungen überprüfen
check_permissions() {
    if [ ! -r "$SOURCE_DIR" ];then
        log "Fehler: Kein Leserecht für das Quellverzeichnis $SOURCE_DIR."
        exit 1
    fi

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
    log "Backup gestartet"

    check_permissions
    create_backup
    delete_old_backups

    log "Backup abgeschlossen"
}

# Skript starten
main