#!/bin/bash
# entrypoint.sh for PostgreSQL backup

# Default directory for dumps

BACKUP_DIR=${BACKUP_DIR:-'/backups'}

# Log startup
echo "--------"  >> /proc/1/fd/1 2>> /proc/1/fd/2
echo "[$(date +"%Y-%m-%d %H:%M:%S")] Container Initiated: Starting pg_dump ..." >> /proc/1/fd/1 2>> /proc/1/fd/2 | tee "${BACKUP_DIR}/dump-log"

# Set default values if not provided
CRON_SCHEDULE=${CRON_SCHEDULE:-'0 1 * * *'}
DB_USER=${DB_USER:-'postgres'}
DB_PORT=${DB_PORT:-5432}

# Database name can be provided by a specific variable or default to 'postgres'
if [[ -n "${DB_NAME}" ]]; then
    DB_NAME=${DB_NAME}
else
    DB_NAME=${DB_NAME:-'postgres'}
fi

# Check for PostgreSQL password
if [[ -f "${DB_PASSWORD_FILE}" ]]; then
    DB_PASSWORD=$(<"${DB_PASSWORD_FILE}")
elif [[ -n "${DB_PASSWORD}" ]]; then
    DB_PASSWORD=${DB_PASSWORD}
else
    echo "ERROR: No PostgreSQL password set!"
    exit 1
fi

# Set environment variables for cron
# it is not recommanded to use env var for passwords 
CRON_ENV="PREFIX='$PREFIX'\nDB_USER='${DB_USER}'\nDB_HOST='${DB_HOST}'\nDB_NAME='${DB_NAME}'\nDB_PORT='${DB_PORT}'\nBACKUP_DIR='${BACKUP_DIR}'\nDB_PASSWORD='${DB_PASSWORD}'"

# Add environment variables to the cron environment
# Do not print passwords or any sensitive information on the logs
# echo -e "$CRON_SCHEDULE /backup.sh >> ${BACKUP_DIR}/backup-log 2>&1" | crontab -

echo -e "$CRON_ENV\n$CRON_SCHEDULE /backup.sh > /dev/null 2>&1" | crontab -

# Log the current crontab entries
#crontab -l | tee "${BACKUP_DIR}/backup-log" 2>&1

# Start cron in the foreground
cron -f
