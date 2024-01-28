#!/bin/bash

# Define the function is_server_up_local
function is_server_up_local {
    # Check that server is up using RCON
    COUNTER=0
    while true
    do
        # Using RCON to check server status
        CAPTUREOUTPUT=$(echo 'showplayers' | ./ARRCON --host $HOST --port $PORT --pass $ADMINPASSWORD 2>&1)

        # Check if the output contains player information, which indicates server is up
        if [[ $CAPTUREOUTPUT == *"name,playeruid,steamid"* ]]; then 
            echo "Server is up"
            break
        else
            echo "Server NOT up yet."
        fi

        COUNTER=$((COUNTER+1))
        # If server does not start in specified time, terminate
        if [ "$COUNTER" -gt $((60 * STARTUPMIN)) ]; then
            echo "10mins have passed without starting, terminating."
            zero_service
            break
        fi

        sleep 1
    done
}

# Function to check the number of players connected using RCON
function check_players_rcon {
    # Sending 'showplayers' command to the RCON client and capturing output
    local output=$(echo 'showplayers' | ./ARRCON --host 127.0.0.1 --port 25575 --pass adminpassword 2>&1)

    # Debugging: Print the entire output to stderr
    echo "RCON Output: $output" >&2

    # Check if the output contains the expected header "name,playeruid,steamid"
    if [[ "$output" == *"name,playeruid,steamid"* ]]; then
        # Counting the number of player lines based on the specified pattern
        local player_count=$(echo "$output" | grep -c '^[^,]\+,[0-9]\+,[0-9]\+$')
        
        # Debugging: Print the calculated player count
        echo "Calculated Player Count: $player_count" >&2

        echo $player_count
    else
        # Debugging: Indicate an unexpected output or server down
        echo "Unexpected output or server down" >&2
        echo 0
    fi
}

# Loop until players haven't connected for x time
function are_players_connected {
    COUNTER=0
    while [ "$COUNTER" -le $SHUTDOWNMIN ]
    do
        # Check the number of players connected
        PLAYERCOUNT=$(check_players_rcon)

        # Ensure PLAYERCOUNT is set to a default value if empty or non-integer
        # if ! [[ "$PLAYERCOUNT" =~ ^[0-9]+$ ]]; then
        #     PLAYERCOUNT=0
        # fi

        if [ "$PLAYERCOUNT" -lt 1 ]
        then
            echo "$PLAYERCOUNT players connected, $COUNTER out of $SHUTDOWNMIN minutes"
            COUNTER=$((COUNTER+1))
        else
            echo "$PLAYERCOUNT players connected, counter at zero"
            COUNTER=0
        fi
        sleep 1m
    done
}


# Environment variables and other setup
HOST=127.0.0.1
PORT=25575
ADMINPASSWORD=adminpassword
STARTUPMIN=15  # Adjust this as needed
SHUTDOWNMIN=10
# Set other necessary variables here, like QUERYPORT if used

# Call the function
is_server_up_local
are_players_connected

# Add any additional script logic here
