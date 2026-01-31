#!/bin/sh
set -e

# Setup TUN device
if [ ! -d /dev/net ]; then
    mkdir -p /dev/net
fi
if [ ! -e /dev/net/tun ]; then
    mknod /dev/net/tun c 10 200
fi

echo "=== OmniEdge Docker Container ==="

# If arguments passed, run omniedge directly with those arguments
if [ $# -gt 0 ]; then
    echo "Running: omniedge $@"
    exec omniedge "$@"
fi

# Fallback: no arguments provided
echo "No arguments provided. Use:"
echo "  docker run omniedge/omniedge start --mode edge -n <network_id> -s <security_key>"
echo "  docker run omniedge/omniedge start --mode nucleus --secret <secret>"
echo "  docker run omniedge/omniedge start --mode dual -n <network_id> -s <security_key>"
exit 1
