FROM postgres:latest

# Define environment variables
ENV DB_HOST=db
ENV DB_USER=user
ENV DB_PASSWORD=password
ENV DB_NAME=database
ENV DB_PORT=port

# Update and install cron
RUN apt-get update && \
    apt-get install -y cron && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create a non-root user
RUN useradd -m -s /bin/bash backupuser

# Copy necessary files
COPY backup.sh /backup.sh
COPY crontab /etc/cron.d/backup-cron

# Permissions and log file
RUN chmod 0644 /etc/cron.d/backup-cron && \
    chmod +x /backup.sh && \
    touch /var/log/cron.log && \
    chown backupuser:backupuser /var/log/cron.log

# Switch to non-root user
USER backupuser

# Redirect logs to JSON file
CMD cron && tail -f /var/log/cron.log | jq --unbuffered -c . > /var/log/cron.json
