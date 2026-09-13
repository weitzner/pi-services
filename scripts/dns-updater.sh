#!/bin/bash
# this script updates a Cloudflare DNS record to the current external IP address

# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

URL="https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records/${DNS_RECORD_ID}"
headers="Authorization: Bearer ${CLOUDFLARE_API_TOKEN}"

# get IP address from Cloudflare's DNS record
record=$(curl -fsS -H "$headers" "$URL")
dnsIP=$(printf '%s\n' "$record" | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b")

# get public IP address by asking the router
currentIP=$(upnpc -s | grep ^ExternalIPAddress | cut -c21-)

# if the two IP addresses differ, update
if [ "$dnsIP" != "$currentIP" ];
then
	request=$(printf '{"content":"%s","ttl":3600}' "$currentIP")
	result=$(curl -fsS -X PATCH \
        -H "$headers" \
        -H "Content-Type: application/json" \
        --data "$request" "$URL")
	printf '%s\n' "$result"
fi
