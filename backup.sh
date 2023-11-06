#!/bin/bash
# backup.sh - Backup script for PostgreSQL

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
echo "--------"
echo "Backup job started at $(date). Saving to ${BACKUP_FILE}"

# Perform the backup
export PGPASSWORD=${DB_PASSWORD}
pg_dump -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -Fd -f "${BACKUP_FILE}" -d "${DB_NAME}" -j 5 -v
STATUS=$?

if [[ -n "${RETAIN_COUNT}" ]]; then
    file_count=1
    for file_name in $(ls -t $BACKUP_DIR/*.gz); do
        if (( ${file_count} > ${RETAIN_COUNT} )); then
            echo "Removing older dump file: ${file_name}"
            rm "${file_name}"
        fi
        ((file_count++))
    done
else
    echo "No RETAIN_COUNT! Take care with disk space."
fi
