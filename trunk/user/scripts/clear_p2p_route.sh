#!/bin/bash

ip route flush cache

if [ $# -gt 0 ]; then
    ip route flush dev $1 scope global
else
    if [ $(nvram get vpnc_ov_mode) == "0" ]; then
        ip route flush dev tap0 scope global
    else
        ip route flush dev tun0 scope global
    fi
fi