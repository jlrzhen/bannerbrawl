# Pull the minimal Ubuntu image
FROM ubuntu

# Install packages
RUN apt-get -y update
RUN apt-get -y install curl nano git openssh-server iproute2 jq figlet
RUN apt-get -y install python3 python3.10-venv python3-pip

# Configure SSH server
RUN echo 'root:root' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Expose port 22 for SSH
EXPOSE 22/tcp
