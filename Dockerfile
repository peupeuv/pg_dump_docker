FROM ubuntu:20.04

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary packages
RUN apt-get update && apt-get install -y \
    gnupg \
    wget \
    ca-certificates \
    cron && \
    rm -rf /var/lib/apt/lists/*

# Add PostgreSQL's repository. It contains the most recent stable release
# of PostgreSQL, `13`.
RUN wget --no-check-certificate -qO - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
    && sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ focal-pgdg main" > /etc/apt/sources.list.d/pgdg.list'


# Install PostgreSQL client
RUN apt-get update && apt-get install -y \
    postgresql-client-13 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*


# Copy necessary files
COPY backup.sh /backup.sh
COPY crontab /etc/cron.d/backup-cron

# Permissions and log file
RUN chmod 0644 /etc/cron.d/backup-cron && \
    chmod +x /backup.sh && \
    crontab /etc/cron.d/backup-cron
    #touch /var/log/cron.log

# Redirect logs to JSON file
#CMD cron && tail -f /var/log/cron.log
CMD cron -f