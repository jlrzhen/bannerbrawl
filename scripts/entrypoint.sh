#!/bin/sh

# Start the ssh server
service ssh restart

# install ZeroTier
ZEROTIER_ENDPOINT="https://api.zerotier.com/api/v1"
curl -s https://install.zerotier.com | bash || true
# start manually (no systemd in containers)
nohup zerotier-one -d > /dev/null 2>&1 & 
# join network once zerotier-one comes online
until zerotier-cli status | grep ONLINE; do sleep 1; done
ZEROTIER_NETWORK_ID=$(
    curl $ZEROTIER_ENDPOINT/network \
    -X GET \
    -H "Authorization: token $ZEROTIER_API_KEY" \
    --silent \
    | jq '.[] | select(.config.name == "bannerbrawl").config.id' | tr -d '"'
)
echo $ZEROTIER_NETWORK_ID
/usr/sbin/zerotier-cli join $ZEROTIER_NETWORK_ID

# approve new member after joining
until zerotier-cli listnetworks | grep ACCESS_DENIED; do sleep 1; done
ZEROTIER_MEMBER_ID=$(zerotier-cli info | awk '{print$3}')
curl \
$ZEROTIER_ENDPOINT/network/$ZEROTIER_NETWORK_ID/member/$ZEROTIER_MEMBER_ID \
-X POST \
-H "Authorization: token $ZEROTIER_API_KEY" \
-d '{"config":{"authorized":true}}' \
--silent \
| jq '.config.id' | tr -d '"'

# create list of members
until zerotier-cli listnetworks | grep "OK PRIVATE"; do sleep 1; done
curl \
$ZEROTIER_ENDPOINT/network/$ZEROTIER_NETWORK_ID/member \
-X GET \
-H "Authorization: token $ZEROTIER_API_KEY" \
--silent \
> /root/members.json

# Execute the CMD
exec "$@"
