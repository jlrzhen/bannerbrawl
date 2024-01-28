# Pull the minimal Ubuntu image
FROM bannerbrawl-stage-1:v1.0

# Zerotier
ARG ZEROTIER_API_KEY
ENV ZEROTIER_API_KEY=$ZEROTIER_API_KEY
ARG ZEROTIER_NETWORK_ID
ENV ZEROTIER_NETWORK_ID=$ZEROTIER_NETWORK_ID
ARG GAMEKEEPER_MEMBER_ID
ENV GAMEKEEPER_MEMBER_ID=$GAMEKEEPER_MEMBER_ID
RUN echo "api key:$ZEROTIER_API_KEY network id:$ZEROTIER_NETWORK_ID" > /root/zerotier.txt

# Copy and run entrypoint script
COPY scripts/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

# startup script
COPY scripts/bannerbrawl_welcome.sh /etc/profile.d/bannerbrawl_welcome.sh

# Start shell
CMD /bin/bash
