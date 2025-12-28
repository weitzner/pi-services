#!/bin/bash

# below are a few functions to help format the easy-to-maintain formats in
# local_dns.conf and vpn_peers.conf for use the services/.env (../.env) file
# 
# recommended use is to run this script from the services directory and copy
# the output into the services env file. The following commands will format the
# strings without polluting your environment:
#
# bash -c 'source ../scripts/update-funcs.sh; update_local_dns_records local_config/local_dns.conf'
# bash -c 'source ../scripts/update-funcs.sh; update_vpn_peers local_config/vpn_peers.conf'

function concat_non_commented_with_delimiter() {
    local delimiter="$1"
    local quote_result="$2"
    local file="$3"
    # Use grep -v to filter out lines starting with '#' (ignoring leading spaces)
    # and filter out empty lines.
    local filtered_lines=$(grep -Ev '^[[:space:]]*#|^[[:space:]]*$' "$file")

    # Use paste to join lines with a semicolon, then remove the trailing semicolon.
    local result=$(echo "$filtered_lines" | paste -sd $delimiter -)
    
    if [[ "$quote_result" == "true" ]]; then
        # Output the result within single quotes.
        echo "'$result'"
    else
        echo "$result"
    fi
}

function update_vpn_peers() {
    echo $(concat_non_commented_with_delimiter , false $1)
}

function update_local_dns_records() {
    echo $(concat_non_commented_with_delimiter \; true $1)
}
