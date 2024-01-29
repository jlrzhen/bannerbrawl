# create the game network
make build ZEROTIER_NETWORK_ID=$1 GAMEKEEPER_MEMBER_ID=$2

make start SERVICE_NAME=gamekeeper
make start SERVICE_NAME=kingtower
echo

PORTS=("5000" "5001")
MEMBER_IDS=()

spinner() {
    for spin in "${spin_list[@]}"; do
        echo -ne "$spin Waiting for containers to respond...\r"
        sleep 0.05
    done
}

spin_list=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
for port in "${PORTS[@]}"
do
    echo -ne '\033[?25l'   # Hide cursor
    
    # wait for gunicorn start
    until [[ ! -z $(curl -s localhost:$port) ]]
    do spinner; done
    echo -ne "\x1b[2K\r"

    # get member ids
    until [[ ! -z $(curl -s localhost:$port | jq '.member_id' | tr -d '"') ]]
    do spinner; done
    
    echo -ne '\033[?25h'   # Show cursor

    MEMBER_ID=$(curl -s localhost:$port | jq '.member_id' | tr -d '"')
    MEMBER_IDS+=($MEMBER_ID)
done

echo "login to kingtower by running: ssh root@localhost"
echo "Member ids: ${MEMBER_IDS[@]}"
