# pi-services
The things I run on my raspberry pi
1. [pi-hole](https://pi-hole.net)
2. [homebridge](https://homebridge.io)
3. [wireguard](https://www.wireguard.com)
4. [nginx](https://nginx.org)

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

**NOTE** all of the environment variables below should go into a single `.env` file in the
`services` directory. They are split up by service below to show which variables configure
each service.

## Pi-hole – ad blocking across the whole network

This container runs [pi-hole](https://pi-hole.net) alongside a local (in the same container) unbound installation that recursively resolves DNS requests using cloudfare via DoT.
It uses the docker image created by [@juampe](https://github.com/juampe) that can be found [here](https://hub.docker.com/r/juampe/pihole-dot).

The docker compose file is set up to use environment variables to set sensitive or configurable information.
To set your environment variables, create a `.env` in this directory. The following variables need to be set:

```
ServerIP=192.168.1.2         # the raspberry pi's IP -- make this static or set a DHCP reservation!
TZ=America/Los_Angeles       # find your TZ here: https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
WEBPASSWORD=YR_PASSWORD_HERE # use this to log in to dashboard
HOSTNAME=pihole              # not accessible outside of container
DOMAIN_NAME=pihole.local.    # not super important if you aren't trying to access from outside
DOT_UPSTREAM=1.1.1.1,1.0.0.1 # cloudflare, DoT
VIRTUAL_HOST=pihole          # set to same as HOSTNAME
```

Create a secondary macvlan interface to allow the host to communicate with the container by setting the IP addresses in and executing `scripts/pihole_network_shim.sh`.

To start the service, issue `docker-compose up -d` in the services directory and then
navigate to the dashboard at `pi.hole`.


## Homebridge – HomeKit support for things that don't support HomeKit

This container runs [homebridge](https://homebridge.io) without needing to use the host network interface.
It uses the docker image created by [@oznu](https://github.com/oznu) that can be found [here](https://hub.docker.com/r/oznu/homebridge/).

The docker compose file is set up to use environment variables to set sensitive or configurable information.
To set your environment variables, create a `.env` in this directory. The following variables need to be set:

```
TZ=America/Los_Angeles       # find your TZ here: https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
PGID=$(id -g)                # current user's gid
PUID=$(id -u)                # current user's uid
IPV4_ADDRESS=192.168.1.254   # IP address that is not in use and will not be assigned by your DHCP server
SUBNET=192.168.1.0/24        # subnet, CIDR (broadcast_address/network_prefix_bits)
GATEWAY=192.168.1.1          # router's IP address
HOMEBRIDGE_CONFIG_UI_PORT=42 # port to run the homebridge UI on
```

To start the service, issue `docker-compose up -d` in the services directory and then
and then navigate to the dashboard at `homebridge.local:8581`.

## Wireguard VPN

### Set up a dynamically updated DNS for your RPi
Your ISP periodically changes your IP address, which will break your DNS lookup
of your domain. The `scripts/dns-updater.sh` script will check your current IP
and the DNS IP and update the DNS record if necessary. I use GoDaddy as my domain
name registrar; this script expects to use the GoDaddy REST api. First, go to the
[GoDaddy developer site](https://developer.godaddy.com/getstarted) to create an api
key and secret for a production server and then update the four variables below as
appropriate. and put them in `scripts/.env`

```
export DOMAIN="whatever.com" # domain name
export NAME="vpn"            # name of A record to update
export API_KEY=YR_KEY        # key for godaddy developer API
export SECRET=YR_SECRET      # secret for godaddy developer API
```

To ensure there is
minimal downtime when your IP address changes, run that script in a cron job
every hour by adding the following to your crontab:
```bash
55 * * * * . /home/pi/pi-services/scripts/.env; /bin/bash /home/pi/pi-services/scripts/dns-updater.sh
```
This will run the DNS updater script on the 55th minute of every hour.

### Configuring the WireGuard server

This container runs a [wireguard](https://wireguard.com) server to enable a secure connection to your home network when you're on the go.
It uses the docker image created by the [Linux Server](https://www.linuxserver.io) project that can be found [here](https://hub.docker.com/r/linuxserver/wireguard).

The docker compose file is set up to use environment variables to set sensitive or configurable information.
To set your environment variables, create a `.env` in this directory. The following variables need to be set:

```
TZ=America/Los_Angeles       # find your TZ here: https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
PGID=$(id -g)                # current user's gid
PUID=$(id -u)                # current user's uid
DOMAIN=YR_DOMAIN_HERE        # subdomain you set to update with scripts/dns_updater.sh (e.g. vpn.whatever.com)
INTERNAL_SUBNET=10.13.13.0   # should be different from your home network - ok to leave as is
PEERS=INTEGER_OR_LIST        # how many unique key pairs to create - e.g. "3" or "phone,laptop,tablet"
```

To start the service, issue `docker-compose up -d` in the services directory and then
and then check out the QR codes to get set up by issuing `docker logs wireguard`.
To set up with a config file instead of a QR code, navigate to `/opt/wireguard/config` and move the relevant `peer_*/peer_*.conf` file
to the client machine. Note that accessing the config files requires root access.

## nginx web server

This container runs the [nginx](https://nginx.org) webserver set up as a reverse proxy for the hombridge web client.
It uses the official docker image that can be found [here](https://hub.docker.com/_/nginx).

The docker compose file is set up to use environment variables to set sensitive or configurable information.
To set your environment variables, create a `.env` in this directory. The following variables need to be set:

```
NGINX_PORT=80                # port nginx to listen on
NGINX_HOST=192.168.1.2       # the raspberry pi's IP -- make this static or set a DHCP reservation!
DEST_PORT=9999               # port to forward to; set to use HOMEBRIDGE_CONFIG_UI_PORT
```

To start the service, issue `docker-compose up -d` in the services directory and then
and then navigate to the homebridge dashboard at `home.bridge`, after setting up a local
DNS record in the `pi.hole` interface to point to the IP address `NGINX_HOST`.
