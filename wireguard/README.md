# Wireguard VPN

## Set up a dynamically updated DNS for your RPi
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
55 * * * * . /home/pi/pi-services/wireguard/scripts/.env; /bin/bash /home/pi/pi-services/wireguard/scripts/dns-updater.sh
```
This will run the DNS updater script on the 55th minute of every hour.

## Configuring the WireGuard server

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

To start the service, issue `docker-compose up -d` and then check out the QR codes to get set up by issuing `docker logs wireguard`.
To set up with a config file instead of a QR code, navigate to `/opt/wireguard/config` and move the relevant `peer_*/peer_*.conf` file 
to the client machine. Note that accessing the config files requires root access.
