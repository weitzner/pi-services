# Wireguard VPN

## Set up a dynamically updated DNS for your RPi
Your ISP periodically changes your IP address, which will break your DNS lookup
of your domain. The `scripts/dns-updater.sh` script will check your current IP
and the DNS IP and update the DNS record if necessary. To ensure there is 
minimal downtime when your IP address changes, run that script in a cron job 
every hour by adding the following to your crontab:
```bash
55 * * * * . /home/pi/pi-services/wireguard/scripts/.env; /bin/bash /home/pi/pi-services/wireguard/scripts/dns-updater.sh
```
This will run the DNS updater script on the 55th minute of every hour.
