#!/bin/bash

DATE=$(date +%Y%m%d%H%M%S)
pg_dump -h db -U user -Fd database -f /backups/db-$DATE -j 5 -v 2>&1 | tee /var/log/pg_dump.log

if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo "Backup completed successfully at $DATE" >> /var/log/backup.log
else
    echo "Backup failed at $DATE" >> /var/log/backup.log
fi
