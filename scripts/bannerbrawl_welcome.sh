figlet "bannerbrawl"
until ip a | grep ': zt' -A3 | grep inet; do sleep 1; done &>/dev/null
echo your in-game IP is $(ip a | grep ': zt' -A3 | awk '/inet/ {print $2}'); echo
