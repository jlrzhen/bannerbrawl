# create the game network
#make build ZEROTIER_NETWORK_ID=$1 GAMEKEEPER_MEMBER_ID=$2

#make start SERVICE_NAME=gamekeeper
#make start SERVICE_NAME=kingtower
echo

PORTS=("5000" "5001")
MEMBER_IDS=()

spin_list=('⣾' '⣽' '⣻' '⢿' '⡿' '⣟' '⣯' '⣷')
for port in "${PORTS[@]}"
do
    echo -ne '\033[?25l'   # Hide cursor
    # wait for gunicorn
    until [[ ! -z $(curl -s localhost:$port) ]]
    do 
        for spin in "${spin_list[@]}"; do
            echo -ne "$spin loading...\r"
            sleep 0.1
        done
    done
    echo "container started."

    # get member ids
    until [[ ! -z $(curl -s localhost:$port | jq '.member_id' | tr -d '"') ]]
    do 
        for spin in "${spin_list[@]}"; do
            echo -ne "$spin loading...\r"
            sleep 0.1
        done
    done
    echo -ne '\033[?25h'   # Show cursor

    MEMBER_ID=$(curl -s localhost:$port | jq '.member_id' | tr -d '"')
    echo "container has member id $MEMBER_ID"
    echo
    MEMBER_IDS+=($MEMBER_ID)
done

echo "login to kingtower by running: ssh root@localhost"
echo "member ids: ${MEMBER_IDS[@]}"
