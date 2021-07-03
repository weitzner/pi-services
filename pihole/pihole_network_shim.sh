#!/bin/bash

# create a secondary macvlan interface to allow the host to communicate with
# the container. requires root privileges to run

# https://blog.oddbit.com/post/2018-03-12-using-docker-macvlan-networks/

# adjust these varaibles for your network
IP_ADDRESS_THAT_ROUTER_WILL_NOT_ASSIGN="192.168.1.254/32"
IP_ADDRESS_ASSIGNED_TO_PIHOLE="192.168.1.2"

ip link add pihole-shim link eth0 type macvlan mode bridge
ip addr add "${IP_ADDRESS_THAT_ROUTER_WILL_NOT_ASSIGN}" dev pihole-shim
ip link set pihole-shim up
ip route add "${IP_ADDRESS_ASSIGNED_TO_PIHOLE}" dev pihole-shim
