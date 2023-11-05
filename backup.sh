#!/bin/bash

NOW=$(date +"%Y-%m-%d_%H-%M-%S")

# Filename for backup
BACKUP_FILE="/backups/db-$NOW"


# Start the backup and time it
START=$(date +%s)
PGPASSWORD="${DB_PASSWORD}" pg_dump -h "$DB_HOST" -U "$DB_USER" -Fd "$DB_NAME" -f "$BACKUP_FILE" -j 5 -v
STATUS=$?
END=$(date +%s)

# Calculate duration
DURATION=$((END - START))

# Log the outcome
if [ $STATUS -eq 0 ]; then
    echo "$(date +"%Y-%m-%d %H:%M:%S") Backup completed successfully in $DURATION seconds"
else
    echo "$(date +"%Y-%m-%d %H:%M:%S") Backup failed after $DURATION seconds"
fi
