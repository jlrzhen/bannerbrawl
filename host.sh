read -s -p "Enter Zerotier API key: " ZEROTIER_API_KEY; echo

# create the game network
export ZEROTIER_NETWORK_ID=$(
    curl https://api.zerotier.com/api/v1/network \
    -X POST \
    -H "Authorization: token $ZEROTIER_API_KEY" \
    -d "{}" \
    --silent \
    | jq '.config.id' | tr -d '"'
)
echo "created network $ZEROTIER_NETWORK_ID"

# configure the network
curl https://api.zerotier.com/api/v1/network/$ZEROTIER_NETWORK_ID \
-X POST \
-H "Authorization: token $ZEROTIER_API_KEY" \
-d '{"config":{"name":"bannerbrawl","private":true,"routes":[{"target":"10.0.0.0/24"}],"ipAssignmentPools":[{"ipRangeStart":"10.0.0.1","ipRangeEnd":"10.0.0.255"}]}}' \
--silent \
| jq '.config.id' | tr -d '"'

make build \
ZEROTIER_API_KEY=$ZEROTIER_API_KEY

make start && \
echo && \
echo "tell your opponent to run this command: curl https://raw.githubusercontent.com/jlrzhen/bannerbrawl/main/join.sh | bash -s $ZEROTIER_NETWORK_ID" && \
echo && \
echo "to login to kingtower, run: ssh root@localhost"
