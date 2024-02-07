source $BANNERBRAWL_PATH/scripts/spinners.sh

# Decode the Base64-encoded string
base64_decoded=$(echo "$1" | base64 -d)

# Split the string into an array using space as the delimiter
IFS=" " read -ra join_params <<< "$base64_decoded"
echo "join params: ${join_params[@]}"
GAMEKEEPER_IP=$(echo ${join_params[1]} | sed -e 's/\/*//g')

# create the game network
make build ZEROTIER_NETWORK_ID="${join_params[0]}" GAMEKEEPER_IP="$GAMEKEEPER_IP"

make start SERVICE_NAME=kingtower
#make start SERVICE_NAME=archertower1
#make start SERVICE_NAME=archertower2
echo

# get member ids from flask
PORTS=("5001")
MEMBER_IDS=()
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

    MEMBER_ID=$(curl -s localhost:$port | jq '.member_id' | tr -d '"')
    MEMBER_IDS+=($MEMBER_ID)
done

echo "Member ids: ${MEMBER_IDS[@]}"
echo "Login to kingtower by running: ssh -L localhost:8080:$GAMEKEEPER_IP:5000 root@localhost -p 30023"
echo "Dashboard: http://localhost:8080/dashboard"
echo

# Join the array into a space-separated string
member_ids_str=$(IFS=" " ; echo "${MEMBER_IDS[*]}")

# Encode the string in Base64
base64_encoded=$(echo -n "$member_ids_str" | base64)

# Print the command for the user to copy
echo "Your response code: $base64_encoded"
