read -s -p "Enter Zerotier API key: " ZEROTIER_API_KEY; echo

# get game network id
ZEROTIER_ENDPOINT="https://api.zerotier.com/api/v1"
ZEROTIER_NETWORK_ID=$(
    curl $ZEROTIER_ENDPOINT/network \
    -X GET \
    -H "Authorization: token $ZEROTIER_API_KEY" \
    --silent \
    | jq '.[] | select(.config.name == "bannerbrawl").config.id' | tr -d '"'
)

# delete the network
curl https://api.zerotier.com/api/v1/network/$ZEROTIER_NETWORK_ID \
-X DELETE \
-H "Authorization: token $ZEROTIER_API_KEY" \
--silent \
