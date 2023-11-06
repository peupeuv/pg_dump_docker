# Start from the official Ubuntu base image
FROM ubuntu:20.04
LABEL org.opencontainers.image.authors="saidi.ppv@gmail.com"

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


ENV PREFIX="dump"
ENV RETAIN_COUNT=10  

# Copy necessary scripts
COPY backup.sh /backup.sh
COPY entrypoint.sh /entrypoint.sh

# Set the proper permissions
RUN chmod +x /backup.sh && \
    chmod +x /entrypoint.sh

# Set the user to run the cron job
USER root

# Run the command on container startup
ENTRYPOINT ["/entrypoint.sh"]
