if docker ps > /dev/null
then echo docker already installed.
else
    ### Install Docker
    # remove conflicting packages
    for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done
    # Add Docker's official GPG key:
    sudo apt-get update
    sudo apt-get install ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc
    # Add the repository to Apt sources:
    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    # add user to group
    sudo groupadd docker
    sudo usermod -aG docker $USER
    newgrp docker
fi
sudo apt install jq make git

if ls /bannerbrawl > /dev/null
then
    sudo rm -r /bannerbrawl
    sed -i '/export PATH=\$PATH:\/bannerbrawl\/run/d' ~/.bashrc
    cd /bannerbrawl && make build_stage_1
else
    sudo git clone https://github.com/jlrzhen/bannerbrawl.git /bannerbrawl
    echo 'export PATH=$PATH:/bannerbrawl/run' >> ~/.bashrc
fi
echo bannerbrawl installed. Run 'bannerbrawl host' to start a new game.
