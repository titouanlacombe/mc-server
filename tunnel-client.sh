#!/usr/bin/env bash

# Clean up
cleanup() {
	echo "Cleaning up..."
	envsubst < ./tunnel-server-cleanup.sh | ssh $TUNNEL_SSH_HOST "bash -s"
}

# Trap SIGINT
trap "cleanup" INT

# Launch ./tunnel-server.sh on the server using ssh
envsubst < ./tunnel-server.sh | ssh $TUNNEL_SSH_HOST "bash -s"

# Wait for SIGINT
wait
