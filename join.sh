# create the game network
make build ZEROTIER_NETWORK_ID=$1 GAMEKEEPER_MEMBER_ID=$2

make start SERVICE_NAME=gamekeeper && \
echo && \
echo "container has started" && \
echo && \
echo "login to kingtower by running: ssh root@localhost"
