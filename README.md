# Pi-services
This repository provides configuration files, scripts and instructions to run the follwoing services on a Raspberry Pi:
1. [nginx](#nginx)
2. [Homebridge](#homebridge)
3. [Unbound](#unbound)
4. [Pi-hole](#pi-hole)
5. [WireGuard](#wireguard)

This Readme is organized into three main sections:
1. [Initial setup](#initial-setup) - details how to install docker and dsescribes relevant configuration files
2. [Configuration](#configuration) - describes how to customize this installation for your environment
3. [Container descriptions](#container-descriptions) - short description and links to projects with some instructions for common operations



# Initial setup
## Install docker and docker-compose
To use these services, make sure you have docker and docker-compose installed on your raspberry pi

```bash
sudo apt-get update && sudo apt-get upgrade
curl -sSL https://get.docker.com | sh

# add current (i.e. non-root) user to docker group
sudo usermod -aG docker ${USER}

# optionally check groups with the following command
# groups ${USER}

# install tools needed to install docker-compose
sudo apt-get install libffi-dev libssl-dev
sudo apt install python3-dev
sudo apt-get install -y python3 python3-pip

# install docker-compose and enable service
sudo pip3 install docker-compose
sudo systemctl enable docker

# test with hello world container
docker run hello-world
```
## Initialize conguration and environment files
After installing docker and cloning this repository, you can create stubs for configuation files by running `initialize-config-files.sh` fom the `pi-services` directory. This script will create the following untracked files:

### `services/.env`
```bash
# shared
TZ=""                           # find your TZ here: https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
PGID=""                         # current user's gid
PUID=""                         # current user's uid
#nginx
RPI_IP=""                       # IP address of the docker host - make this static or set a DHCP reservation
NGINX_PORT=""                   # probably 80
# homebridge
HOMEBRIDGE_CONFIG_UI_PORT=""    # port to run the homebridge UI on
# wireguard
DOMAIN=""                       # subdomain you set to update with scripts/dns_updater.sh (e.g. vpn.whatever.com)
INTERNAL_SUBNET=""              # must be different from your home network
PEERS=""                        # unique key pairs to create as integer or list of names - e.g. "3" or "phone,laptop,tablet"
SERVERPORT=""                   # port to use - you will need to forward this from your rou8ter. Default is 51820
# pi-hole
PIHOLE_UI_PORT=""               # port to run the pi-hole dashboard UI on
WEBPASSWORD=""                  # passwrod used to log in to pi-hole dashboard UI
LOCAL_DNS=""                    # list of local DNS entries (i.e. IP address hostname pairs)
```

### `scripts/.env` - see [Dynamic DNS](#dynamic-dns) 

```bash
# Go to the Cloudflare dashboard and create an api token with edit permissions for Zone.DNS
#
# https://developers.cloudflare.com/api/resources/dns/subresources/records/
# Look up zone id and dns record id - record ids are found by calling 'List DNS Records'
# Update theese 3 variables with your information
export ZONE_ID=""               # zone id (domain name)
export DNS_RECORD_ID=""         # id of A record to update
export CLOUDFLARE_API_TOKEN=""  # token for cloudflare API
```

### `services/nginx/default.conf.template`
```bash
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
```

### `services/local_config/local_dns.conf` - see [Formatting local DNS records](#formatting-local-dns-records)
```bash
# list the IP address and hostnames separated
# by a space for each record on a new line
```

### `services/local_config/vpn_peers.conf` - see [Formatting VPN peer list](#formatting-vpn-peer-list)
```bash
# list a name for each VPN peer on its own line
```

# Configuration
## Dynamic DNS
Your ISP periodically changes your IP address, which will break your DNS lookup
of your domain. The `scripts/dns-updater.sh` script will check your current IP
and the DNS IP and update the DNS record if necessary. I use Cloudflare as my domain
name registrar; this script expects to use the Cloudflare REST api. First, go to the
[Cloudflare developer site](https://developers.cloudflare.com/api/) to create an api
token with permissions to edit Zone.DNS and then update the three variables in 
`scripts/.env`.

To ensure there is minimal downtime when your IP address changes, run that script in 
a cron job every hour by adding the following to your crontab:
```bash
55 * * * * . /home/pi/pi-services/scripts/.env; /bin/bash /home/pi/pi-services/scripts/dns-updater.sh
```
This will run the DNS updater script on the 55th minute of every hour.

## Pi-hole
### Formatting local DNS records
If your DHCP server isn't accessible to pi-hole, you can set local DNS records by entering them into the `.env` file as a semicolon-separated list of IP address-hostname pairs.
You can use `local_config/local_dns.conf` to list each record on its 
own line and then issue `bash -c 'source ../scripts/update-funcs.sh; update_local_dns_records local_config/local_dns.conf'` from the `services` directory to generate the correctly formatted string to set `LOCAL_DNS` to in the `.env` file.

## WireGuard
### Formatting VPN peer list
If you are configuring many peers it may be inconvenient to type them into the `.env` file 
as a comma-separated list. You can use `local_config/vpn_peers.conf` to list each peer on 
its own line and then issue `bash -c 'source ../scripts/update-funcs.sh; update_vpn_peers 
local_config/vpn_peers.conf'` from the `services` directory to generate the correctly 
formatted string to set `PEERS` to in the `.env` file.

# Container descriptions
## nginx
Web server and reverse proxy. This container runs the [nginx](https://nginx.org) webserver using the [official docker image](https://hub.docker.com/_/nginx).
The `initialize-config-files.sh` script creates server blocks for both `home-bridge.internal` and `pi-hole.internal` and you can modify `services/nginx/default.conf.template` or add new templates as needed.

## Homebridge
HomeKit support for the impatient. This container runs [homebridge](https://homebridge.io) on the host network using the [official docker image](https://hub.docker.com/r/homebridge/homebridge/).

## Unbound
Validating, recursive, caching DNS resolver. This container runs [unbound](https://nlnetlabs.nl/projects/unbound/about/) using the [RPi docker image](https://hub.docker.com/r/mvance/unbound-rpi) maintained by [Matthew Vance](https://github.com/MatthewVance/). Unbound is configured to forward DNS requests to Cloudflare over DoT with DNSSEC enabled. IPv6 is disabled.

## Pi-hole
Network-wide ad blocking. This container runs [pi-hole](https://pi-hole.net) using the [official docker image](https://hub.docker.com/r/pihole/pihole).
The container is configured to use the unbound container as its upstream DNS resolver.

## WireGuard
Fast, modern, secure VPN tunnel. [WireGuard](https://wireguard.com) VPN server using the [docker image](https://hub.docker.com/r/linuxserver/wireguard) maintained by the [Linux Server](https://www.linuxserver.io) project.

You can use QR codes or config files to set up peers for VPN access:
1. QR codes: issue `docker exec -it wireguard /app/show-peer PEER-NAME` or check the logs  with `docker logs wireguard` if you didn't use peer names.
2. Config files: navigate to `wireguard/config` and move the relevant `peer_*/peer_*.conf` file to the client machine.
