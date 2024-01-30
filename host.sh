read -s -p "Enter Zerotier API key: " ZEROTIER_API_KEY; echo

# create the game network
ZEROTIER_NETWORK_ID=$(
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

# build the base image
make build \
ZEROTIER_API_KEY=$ZEROTIER_API_KEY

# start containers
echo "Tell your opponent to run this command:\ncurl https://raw.githubusercontent.com/jlrzhen/bannerbrawl/main/join.sh | bash -s $ZEROTIER_NETWORK_ID"
read -p "Then ask your opponent to give you their member ids and paste them here: " member_ids

# Decode the Base64-encoded string
base64_decoded=$(echo "$member_ids" | base64 -d)

# Split the string into an array using space as the delimiter
IFS=" " read -ra member_ids <<< "$base64_decoded"

# Process the strings as needed
for member_id in "${member_ids[@]}"; do
    echo "Member id: $member_id"
    # Add your processing logic here
done

echo $member_ids
#make start SERVICE_NAME=gamekeeper && make start SERVICE_NAME=kingtower
#echo
#echo "to login to kingtower, run: ssh root@localhost"
