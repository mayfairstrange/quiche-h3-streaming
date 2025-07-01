#!/usr/bin/env bash
set -e

# Read shaping params from env or defaults
TC_RATE="${TC_RATE:-1mbit}"
TC_DELAY="${TC_DELAY:-50ms}"
TC_JITTER="${TC_JITTER:-0ms}"
TC_LOSS="${TC_LOSS:-0%}"

# Shape eth0 with netem
tc qdisc add dev eth0 root netem \
    rate   "${TC_RATE}" \
    delay  "${TC_DELAY}" "${TC_JITTER}" \
    loss   "${TC_LOSS}"

# Copy in your htdocs (already done in Dockerfile), ensure dir exists
mkdir -p /srv/quiche/htdocs


# Exec the HTTP/3 server
exec quiche-server \
     --cert  /srv/quiche/htdocs/cert.pem \
     --key   /srv/quiche/htdocs/key.pem \
     --root  /srv/quiche/htdocs \
     --index test.html \
     --listen 0.0.0.0:4433 \
	 --no-retry
