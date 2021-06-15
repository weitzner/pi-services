# Pi-hole – ad blocking across the whole network

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

To start the service, issue `docker-compose up -d` and then navigate to the dashboard at `ServerIP:8080/admin`, 
where `ServerIP` is whatever your raspberry pi's IP is or its local hostname (e.g. `raspberrypi.local:8080/admin`).
