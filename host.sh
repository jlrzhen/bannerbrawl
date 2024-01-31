source /bannerbrawl/scripts/spinners.sh

read -s -p "Enter Zerotier API key: " ZEROTIER_API_KEY; echo
ZEROTIER_ENDPOINT="https://api.zerotier.com/api/v1"

# create the game network
ZEROTIER_NETWORK_ID=$(
    curl $ZEROTIER_ENDPOINT/network \
    -X POST \
    -H "Authorization: token $ZEROTIER_API_KEY" \
    -d "{}" \
    --silent \
    | jq '.config.id' | tr -d '"'
)
echo "created network $ZEROTIER_NETWORK_ID"

# configure the network
printf "configured network "
curl $ZEROTIER_ENDPOINT/network/$ZEROTIER_NETWORK_ID \
-X POST \
-H "Authorization: token $ZEROTIER_API_KEY" \
-d '{"config":{"name":"bannerbrawl","private":true,"routes":[{"target":"10.0.0.0/24"}],"ipAssignmentPools":[{"ipRangeStart":"10.0.0.1","ipRangeEnd":"10.0.0.255"}]}}' \
--silent \
| jq '.config.id' | tr -d '"'

# build the base image
make build \
ZEROTIER_API_KEY=$ZEROTIER_API_KEY

# start containers
make start SERVICE_NAME=gamekeeper && \
make start SERVICE_NAME=kingtower

# get member ids and gamekeeper ip from flask
PORTS=("5000" "5001")
ACTIVE_MEMBER_IDS=()
for port in "${PORTS[@]}"
do
    echo -ne '\033[?25l' # Hide cursor
    
    # wait for gunicorn start
    until [[ ! -z $(curl -s localhost:$port) ]]
    do spinner; done
    echo -ne "\x1b[2K\r" # clear line

    # get member ids
    until [[ ! -z $(curl -s localhost:$port | jq '.member_id' | tr -d '"') ]]
    do spinner; done
    
    echo -ne '\033[?25h' # Show cursor

    ACTIVE_MEMBER_ID=$(curl -s localhost:$port | jq '.member_id' | tr -d '"')
    ACTIVE_MEMBER_IDS+=($ACTIVE_MEMBER_ID)
done
echo "Member ids: ${ACTIVE_MEMBER_IDS[@]}"

gamekeeper_ip=$(
    curl \
    $ZEROTIER_ENDPOINT/network/$ZEROTIER_NETWORK_ID/member \
    -X GET \
    -H "Authorization: token $ZEROTIER_API_KEY" \
    --silent \
    | jq --arg member_id "${ACTIVE_MEMBER_IDS[0]}" \
    '.[] | select(.config.id == $member_id).config.ipAssignments[0]' \
    | tr -d '"'
)
echo
echo "gamekeeper ip: $gamekeeper_ip"

join_params=("$ZEROTIER_NETWORK_ID" "$gamekeeper_ip")

# Join the array into a space-separated string
join_params_str=$(IFS=" " ; echo "${join_params[*]}")

# Encode the string in Base64
join_params_base64_encoded=$(echo -n "$join_params_str" | base64)

echo
echo "Tell your opponent to install bannerbrawl and run this command:"
echo
echo "bannerbrawl join $join_params_base64_encoded"
echo
read -p "Then ask your opponent to give you their response code and paste it here: " member_ids

# Decode the Base64-encoded string
base64_decoded=$(echo "$member_ids" | base64 -d)

# Split the string into an array using space as the delimiter
IFS=" " read -ra member_ids <<< "$base64_decoded"

echo "Member ids: ${member_ids[@]}"

for member_id in "${member_ids[@]}"
do network_member=''
    # wait for guest containers to join
    until [[ ! -z "${network_member}" ]]
    do network_member=$(
            curl \
            $ZEROTIER_ENDPOINT/network/$ZEROTIER_NETWORK_ID/member \
            -X GET \
            -H "Authorization: token $ZEROTIER_API_KEY" \
            --silent \
            | jq --arg member_id "$member_id" \
            '.[] | select(.config.id == $member_id).config.id' \
            | tr -d '"'
        )
        echo "waiting for $member_id to join..."
        sleep 1
    done
    
    # approve guest containers
    curl \
    $ZEROTIER_ENDPOINT/network/$ZEROTIER_NETWORK_ID/member/$member_id \
    -X POST \
    -H "Authorization: token $ZEROTIER_API_KEY" \
    -d '{"config":{"authorized":true}}' \
    --silent \
    | jq '.config.id' | tr -d '"' 1>/dev/null
    echo "Approved member id: $member_id"
done

echo "Login to kingtower by running: ssh root@localhost"
echo
