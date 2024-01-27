# Pull the minimal Ubuntu image
FROM ubuntu

# Install packages
RUN apt-get -y update
RUN apt-get -y install curl nano git openssh-server iproute2 jq figlet

# Zerotier
ARG ZEROTIER_API_KEY
ENV ZEROTIER_API_KEY=$ZEROTIER_API_KEY
ARG ZEROTIER_NETWORK_ID
ENV ZEROTIER_NETWORK_ID=$ZEROTIER_NETWORK_ID
ARG GAMEKEEPER_MEMBER_ID
ENV GAMEKEEPER_MEMBER_ID=$GAMEKEEPER_MEMBER_ID
RUN echo "api key:$ZEROTIER_API_KEY network id:$ZEROTIER_NETWORK_ID" > /root/zerotier.txt

# Configure SSH server
RUN echo 'root:root' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Expose port 22 for SSH
EXPOSE 22/tcp

# Copy and run entrypoint script
COPY scripts/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

# startup script
COPY scripts/bannerbrawl_welcome.sh /etc/profile.d/bannerbrawl_welcome.sh

# Start shell
CMD /bin/bash
