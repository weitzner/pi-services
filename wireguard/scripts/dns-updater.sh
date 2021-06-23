#!/bin/bash
# this script updates a GoDaddy DNS record to the current external IP address

#http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

URL="https://api.godaddy.com/v1/domains/${DOMAIN}/records/A/${NAME}"
headers="Authorization: sso-key ${API_KEY}:${SECRET}"

set -x

# get IP address from GoDaddy's DNS record
record=$(curl -s -X GET -H "$headers" "${URL}")
dnsIP=$(echo $record | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b")

# get public IP address by asking the router
currentIP=$(upnpc -s | grep ^ExternalIPAddress | cut -c21-)

# if the two IP addresses differ, update
if [ $dnsIP != $currentIP ];
then
	request='{"data":"'$currentIP'","ttl":3600}'
	result=$(curl -i -s -X PUT \
 -H "$headers" \
 -H "Content-Type: application/json" \
 -d [$request] "${URL}")
	echo $result
fi
