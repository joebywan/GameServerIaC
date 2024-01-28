


FROM sleavely/node-awscli

# Need this to query the server
RUN npm install gamedig -g

# Get the monitoring script on the container and set it up to run at start
COPY ./watchdog.sh .

ENTRYPOINT ["./watchdog.sh"]