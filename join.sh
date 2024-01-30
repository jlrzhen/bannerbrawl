source scripts/spinners.sh

# create the game network
make build ZEROTIER_NETWORK_ID=$1 GAMEKEEPER_MEMBER_ID=$2

make start SERVICE_NAME=gamekeeper
make start SERVICE_NAME=kingtower
echo

# get member ids from flask
PORTS=("5000" "5001")
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
echo "Login to kingtower by running: ssh root@localhost"
echo

# Join the array into a space-separated string
member_ids_str=$(IFS=" " ; echo "${MEMBER_IDS[*]}")

# Encode the string in Base64
base64_encoded=$(echo -n "$member_ids_str" | base64)

# Print the command for the user to copy
echo "Your response code: $base64_encoded"
