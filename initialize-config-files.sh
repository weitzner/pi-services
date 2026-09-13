#!/bin/bash

initialize_env_file() {
    example=$1
    destination=$2

    if [ -f "$destination" ]; then
        echo "'$destination' exists - skipping initialization"
    else
        install -m 600 "$example" "$destination"
        echo "'$destination' initialized"
    fi
}

# Initialize local runtime files from the tracked, non-secret schemas.
initialize_env_file "scripts/.env.example" "scripts/.env"
initialize_env_file "services/.env.example" "services/.env"

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
