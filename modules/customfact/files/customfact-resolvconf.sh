#!/usr/bin/env bash

f=`grep -v '^#' /etc/resolv.conf 2>/dev/null | tr '\n' ';' | tr $'\t' ' ' | tr -s ' '`

if [[ ! -z ${f} ]]; then
    echo "resolvconf=${f}"
else
    echo "resolvconf=unavailable"
fi
