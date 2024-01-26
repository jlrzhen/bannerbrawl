#!/bin/sh

# Start the ssh server
service ssh restart

# install ZeroTier
curl -s https://install.zerotier.com | bash || true
# start manually (no systemd in containers)
nohup zerotier-one -d > /dev/null 2>&1 & 
# wait for zerotier-one to come online before joining
until zerotier-cli status | grep ONLINE; do sleep 1; done
/usr/sbin/zerotier-cli join $ZEROTIER_NETWORK_ID

# Execute the CMD
exec "$@"
