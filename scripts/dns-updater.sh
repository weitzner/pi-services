#!/bin/bash
# this script updates a Cloudflare DNS record to the current external IP address

# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

URL="https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records/${DNS_RECORD_ID}"
headers="Authorization: Bearer ${CLOUDFLARE_API_TOKEN}"

set -x

# get IP address from Cloudflare's DNS record
record=$(curl -s -H "$headers" "${URL}")
dnsIP=$(echo $record | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b")

# get public IP address by asking the router
currentIP=$(upnpc -s | grep ^ExternalIPAddress | cut -c21-)

# if the two IP addresses differ, update
if [ $dnsIP != $currentIP ];
then
	request='{"content": "'$currentIP'", "ttl": 3600}'
	result=$(curl -i -s -X PATCH \
 -H "$headers" \
 -H "Content-Type: application/json" \
 -d $request "${URL}")
	echo $result
fi
