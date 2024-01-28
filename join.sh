# create the game network
make build ZEROTIER_NETWORK_ID=$1 GAMEKEEPER_MEMBER_ID=$2

make start SERVICE_NAME=gamekeeper
make start SERVICE_NAME=kingtower
echo

PORTS=("5000" "5001")
MEMBER_IDS=()

for port in "${PORTS[@]}"
do
    # wait for gunicorn
    until [[ ! -z $(curl -s localhost:$port) ]]; do sleep 1; done
    echo "container started."

    # get member ids
    until [[ ! -z $(curl -s localhost:$port | jq '.member_id' | tr -d '"') ]]
    do sleep 1; done
    MEMBER_ID=$(curl -s localhost:$port | jq '.member_id' | tr -d '"')
    echo "container has member id $MEMBER_ID"
    echo
    MEMBER_IDS+=($MEMBER_ID)
done

echo "login to kingtower by running: ssh root@localhost"
echo "member ids: ${MEMBER_IDS[@]}"
