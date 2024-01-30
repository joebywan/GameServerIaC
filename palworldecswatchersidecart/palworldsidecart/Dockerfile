FROM sleavely/node-awscli

# Install dependencies for wget and unzip
RUN apt-get update && apt-get install -y wget unzip netcat-openbsd

# Download and extract ARRCON
RUN wget https://github.com/radj307/ARRCON/releases/download/3.3.7/ARRCON-3.3.7-Linux.zip \
    && unzip ARRCON-3.3.7-Linux.zip -d /usr/local/bin/ \
    && rm ARRCON-3.3.7-Linux.zip

# Set execute permissions for ARRCON
RUN chmod +x /usr/local/bin/ARRCON

# Get the monitoring script on the container and set it up to run at start
COPY ./watchdog.sh .

ENTRYPOINT ["./watchdog.sh"]
