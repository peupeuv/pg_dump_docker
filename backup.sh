#!/bin/bash

DATE=$(date +%Y%m%d%H%M%S)
PGPASSWORD="${DB_PASSWORD}" pg_dump -h $DB_HOST -U $DB_USER -Fd $DB_NAME -f /backups/db-$DATE -j 5 -v

if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo "Backup completed successfully at $DATE" 
else
    echo "Backup failed at $DATE" 
fi
