# Pull the minimal Ubuntu image
FROM bannerbrawl-stage-1:v1.0

# Zerotier
ARG ZEROTIER_API_KEY
ENV ZEROTIER_API_KEY=$ZEROTIER_API_KEY
ARG ZEROTIER_NETWORK_ID
ENV ZEROTIER_NETWORK_ID=$ZEROTIER_NETWORK_ID
ARG GAMEKEEPER_IP
ENV GAMEKEEPER_IP=$GAMEKEEPER_IP
RUN echo \
"api key:$ZEROTIER_API_KEY network id:$ZEROTIER_NETWORK_ID gamekeeper ip: $GAMEKEEPER_IP" \
> /root/zerotier.txt

# install Flask app
COPY src /srv/bannerbrawl
EXPOSE 5000

# Copy dashboard script
COPY scripts/box/bannerbrawl /bin/bannerbrawl
RUN chmod +x /bin/bannerbrawl

# Copy and run entrypoint script
COPY scripts/entrypoint_gamekeeper.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

# startup script
COPY scripts/bannerbrawl_welcome.sh /etc/profile.d/bannerbrawl_welcome.sh

# Start shell
CMD /bin/bash
