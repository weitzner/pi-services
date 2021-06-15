# Homebridge – HomeKit support for things that don't support HomeKit

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
```

To start the service, issue `docker-compose up -d` and then navigate to the dashboard at `homebridge.local:8581`.
