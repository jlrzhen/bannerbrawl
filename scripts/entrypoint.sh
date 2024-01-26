#!/bin/sh

# Start the ssh server
service ssh restart

# join zerotier
nohup zerotier-cli join $ZEROTIER_NETWORK_ID &>/dev/null &

# Execute the CMD
exec "$@"
