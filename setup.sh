read -p "Enter Zerotier API key: " ZEROTIER_API_KEY
read -p "Enter Zerotier network ID: " ZEROTIER_NETWORK_ID

make build \
ZEROTIER_API_KEY=$ZEROTIER_API_KEY \
ZEROTIER_NETWORK_ID=$ZEROTIER_NETWORK_ID

make start
