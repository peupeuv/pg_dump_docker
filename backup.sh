#!/bin/bash

# Default values for the backup script
PREFIX=${PREFIX:-dump}
DB_USER=${DB_USER:-postgres}
DB_PORT=${DB_PORT:-5432}
BACKUP_DIR=${BACKUP_DIR:-'/backups'}
RETAIN_COUNT=${RETAIN_COUNT:-10}  # Number of backups to retain

# Format for the backup file name
DATE=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_FILE="$BACKUP_DIR/$PREFIX-$DATE"


# Logging
echo "--------"  >> /proc/1/fd/1 2>> /proc/1/fd/2
echo "[$(date +"%Y-%m-%d %H:%M:%S")] Dumping to: ${BACKUP_FILE}" >> /proc/1/fd/1 2>> /proc/1/fd/2

# Perform the backup
# pg_dump verbosity is only for debugging, remove it or rediect it to proper logfile.
PGPASSWORD="${DB_PASSWORD}" pg_dump -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -Fd "${DB_NAME}" -f "${BACKUP_FILE}" -j 5 -v >> /proc/1/fd/1 2>> /proc/1/fd/2
STATUS=$?

if [ $STATUS -eq 0 ]; then
    echo "Backup completed successfully."  >> /proc/1/fd/1 2>> /proc/1/fd/2
else
    echo "Backup failed with status: $STATUS"  >> /proc/1/fd/1 2>> /proc/1/fd/2
    exit $STATUS
fi

if [[ -n "${RETAIN_COUNT}" ]]; then
    dir_count=1
    # List the backup directories by their creation time, newest first
    for dir_name in $(ls -td $BACKUP_DIR/$PREFIX*/); do
        if (( ${dir_count} > ${RETAIN_COUNT} )); then
            echo "[$(date +"%Y-%m-%d %H:%M:%S")] Removing older dump directory: ${dir_name}" >> /proc/1/fd/1 2>> /proc/1/fd/2
            rm -r "${dir_name}"
        fi
        ((dir_count++))
    done
else
    echo "[$(date +"%Y-%m-%d %H:%M:%S")][WARN] No RETAIN_COUNT set! Take care with disk space." >> /proc/1/fd/1 2>> /proc/1/fd/2
fi