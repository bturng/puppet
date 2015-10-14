#!/usr/bin/env bash

f=`openssl version`

if [[ ! -z ${f} ]]; then
    echo "openssl_version=${f}"
else
    echo "openssl_version=unavailable"
fi
