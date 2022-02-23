# working with steps from: https://docs.docker.com/engine/reference/commandline/run/

FROM amazon/aws-cli

# Install jq
RUN yum install -y jq && \
    yum clean all

# Install nvm, then use that to install npm, then gamedig.  Gamedig's used to query the server
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash
RUN . ~/.nvm/nvm.sh && \
    source ~/.bashrc
RUN nvm install node
RUN npm install gamedig -g

COPY ./watchdog.sh .

ENTRYPOINT ["./watchdog.sh"]
