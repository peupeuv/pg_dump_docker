#!/bin/bash

# Default values for the backup script
PREFIX=${PREFIX:-dump}
DB_USER=${PGUSER:-postgres}
DB_PORT=${PGPORT:-5432}
BACKUP_DIR=${BACKUP_DIR:-'/backups'}
RETAIN_COUNT=${RETAIN_COUNT:-10}  # Number of backups to retain

# Format for the backup file name
DATE=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_FILE="$BACKUP_DIR/$PREFIX-$DATE"


# Logging
echo "--------"  >> /proc/1/fd/1 2>> /proc/1/fd/2
echo "Backup job started at $(date). Saving to ${BACKUP_FILE}" >> /proc/1/fd/1 2>> /proc/1/fd/2

# Perform the backup
export PGPASSWORD=${DB_PASSWORD}
pg_dump -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -Fd "${DB_NAME}" -f "${BACKUP_FILE}" -j 5 -v >> /proc/1/fd/1 2>> /proc/1/fd/2
STATUS=$?

if [ $STATUS -eq 0 ]; then
    echo "Backup completed successfully."  >> /proc/1/fd/1 2>> /proc/1/fd/2
else
    echo "Backup failed with status: $STATUS"  >> /proc/1/fd/1 2>> /proc/1/fd/2
    exit $STATUS
fi

if [[ -n "${RETAIN_COUNT}" ]]; then
    file_count=1
    for file_name in $(ls -t $BACKUP_DIR/*.gz); do
        if (( ${file_count} > ${RETAIN_COUNT} )); then
            echo "Removing older dump file: ${file_name}" >> /proc/1/fd/1 2>> /proc/1/fd/2
            rm "${file_name}"
        fi
        ((file_count++))
    done
else
    echo "No RETAIN_COUNT! Take care with disk space." >> /proc/1/fd/1 2>> /proc/1/fd/2
fi
