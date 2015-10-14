#!/usr/bin/env bash

gw=`/sbin/ip route | /bin/egrep default | /bin/awk {'print $3'}`

if [[ ! -z ${gw} ]]; then
    echo "gateway=${gw}"
else
    echo "gateway=not found"
fi
