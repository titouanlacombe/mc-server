#!/usr/bin/env bash

# Function to execute the tunnel script on the remote server
manage_tunnel() {
    local action=$1
    # ACTION=$action envsubst < ./tunnel-server.sh
    ACTION=$action envsubst < ./tunnel-server.sh | ssh $TUNNEL_SSH_HOST "sudo bash -s"
}

# Clean up function
cleanup() {
    echo -e "\nCleaning up..."
    manage_tunnel "-D"
    exit 0
}

# Trap SIGINT to call the cleanup function
trap cleanup INT

echo "Launching tunnel script on the server..."
manage_tunnel "-A"

echo -e "\nTunnel is running. Press Ctrl+C to exit."
while true; do
    sleep 1
done
