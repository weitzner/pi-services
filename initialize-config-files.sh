#!/bin/bash

# initialize env file for dynamic dns script
FILE="scripts/.env"
if [ -f "$FILE" ]; then
    echo "'$FILE' exists - skipping initialization"
else
    cat <<'END_CONFIG' > $FILE
# Go to the Cloudflare dashboard and create an api token with edit permissions for Zone.DNS
#
# https://developers.cloudflare.com/api/resources/dns/subresources/records/
# Look up zone id and dns record id - record ids are found by calling 'List DNS Records'
# Update theese 3 variables with your information
export ZONE_ID=""               # zone id (domain name)
export DNS_RECORD_ID=""         # id of A record to update
export CLOUDFLARE_API_TOKEN=""  # token for cloudflare API
END_CONFIG
    echo "'$FILE' initialized"
    fi

# initialize env file for docker compose - expects two additional files for config: 
# 1. local_dns.conf and 2. vpn_peers.conf - initialized below
FILE="services/.env"
if [ -f "$FILE" ]; then
    echo "'$FILE' exists - skipping initialization"
else
    cat <<'END_CONFIG' > $FILE
# shared
TZ=
PGID=
PUID=
RPI_IP=
#nginx
NGINX_PORT=
# homebridge
HOMEBRIDGE_CONFIG_UI_PORT=
# wireguard
DOMAIN=
INTERNAL_SUBNET=
PEERS=
SERVERPORT=
# pi-hole
PIHOLE_UI_PORT=
WEBPASSWORD=
LOCAL_DNS=
END_CONFIG
    echo "'$FILE' initialized"
fi

# initialize local dns config file
mkdir -p services/local_config
FILE="services/local_config/local_dns.conf"
if [ -f "$FILE" ]; then
    echo "'$FILE' exists - skipping initialization"
else
    cat <<'END_CONFIG' > $FILE
# list the IP address and hostnames separated
# by a space for each record on a new line
END_CONFIG
    echo "'$FILE' initialized"
fi

# initialize vpn peers file
FILE="services/local_config/vpn_peers.conf"
if [ -f "$FILE" ]; then
    echo "'$FILE' exists - skipping initialization"
else
    cat <<'END_CONFIG' > $FILE
# list a name for each VPN peer on its own line
END_CONFIG
    echo "'$FILE' initialized"
fi

# initialize reverse proxy defaults
mkdir -p services/nginx
FILE="services/nginx/default.conf.template"
if [ -f "$FILE" ]; then
    echo "'$FILE' exists - skipping initialization"
else
    cat <<'END_CONFIG' > $FILE
server {
    listen       ${NGINX_PORT};
    server_name  home-bridge.internal;
    location / {
        proxy_pass http://${NGINX_HOST}:${HOMEBRIDGE_PORT};
    }
}

server {
    listen       ${NGINX_PORT};
    server_name  pi-hole.internal;
    location / {
        proxy_pass http://${NGINX_HOST}:${PIHOLE_PORT};
    }
}

server {
    # permanent redirect pi.hole to pi-hole.internal
    server_name pi.hole;
    return 301 http://pi-hole.internal;
 }
END_CONFIG
    echo "'$FILE' initialized"
fi

# make mount directories for containers
mkdir -p services/homebridge
mkdir -p services/pihole/pihole
mkdir -p services/pihole/dnsmasq.d
mkdir -p services/wireguard
echo "Don't forget to configure these files with your information!"
