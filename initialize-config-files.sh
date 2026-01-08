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
TZ=""                           # find your TZ here: https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
PGID=""                         # current user's gid
PUID=""                         # current user's uid
#nginx
RPI_IP=""                       # IP address of the docker host - make this static or set a DHCP reservation
NGINX_PORT=""                   # probably 80
# homebridge
HOMEBRIDGE_CONFIG_UI_PORT=""   # port to run the homebridge UI on
# wireguard
DOMAIN=""                       # subdomain you set to update with scripts/dns_updater.sh (e.g. vpn.whatever.com)
INTERNAL_SUBNET=""              # must be different from your home network
PEERS=""                        # unique key pairs to create as integer or list of names - e.g. "3" or "phone,laptop,tablet"
SERVERPORT=""                   # port to use - you will need to forward this from your rou8ter. Default is 51820
# pi-hole
PIHOLE_UI_PORT=""               # port to run the pi-hole dashboard UI on
PIHOLE_UI_PORT_HTTPS=""         # port to run the pi-hole dashboard UI on HTTPS
WEBPASSWORD=""                  # passwrod used to log in to pi-hole dashboard UI
LOCAL_DNS=""                    # list of local DNS entries (i.e. IP address hostname pairs)
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
