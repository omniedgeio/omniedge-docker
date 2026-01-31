#!/bin/sh
set -e

# Setup TUN device
if [ ! -d /dev/net ]; then
    mkdir -p /dev/net
fi
if [ ! -e /dev/net/tun ]; then
    mknod /dev/net/tun c 10 200
fi

# Show help
show_help() {
    echo "OmniEdge Docker"
    echo ""
    echo "Usage:"
    echo "  Edge mode (VPN client):"
    echo "    docker run --privileged --network host -v /dev/net/tun:/dev/net/tun \\"
    echo "      omniedge/omniedge edge -n <network-id> -s <security-key>"
    echo ""
    echo "  Nucleus mode (signaling server):"
    echo "    docker run --network host \\"
    echo "      omniedge/omniedge nucleus --secret <secret-min-16-chars>"
    echo ""
    echo "  Dual mode (VPN + signaling):"
    echo "    docker run --privileged --network host -v /dev/net/tun:/dev/net/tun \\"
    echo "      omniedge/omniedge dual -n <network-id> -s <security-key> --secret <secret>"
    echo ""
    echo "Options:"
    echo "  -n, --network-id <ID>    Network ID (edge/dual)"
    echo "  -s, --security-key <KEY> Security key (edge/dual)"
    echo "  --secret <SECRET>        Cluster secret (nucleus/dual, min 16 chars)"
    echo "  -p, --port <PORT>        UDP port (default: 51820)"
    echo "  -x, --as-exit-node       Act as exit node"
    echo "  -e, --exit-node <IP>     Use specific exit node"
    echo "  -v, --verbose            Enable debug logging"
}

# Main
if [ $# -eq 0 ]; then
    show_help
    exit 1
fi

MODE="$1"
shift

case "$MODE" in
    edge|nucleus|dual)
        echo "=== OmniEdge: $MODE mode ==="
        exec omniedge start --mode "$MODE" "$@"
        ;;
    start)
        # Allow direct 'start' command for advanced users
        echo "=== OmniEdge ==="
        exec omniedge start "$@"
        ;;
    status|stop|--help|-h|help)
        exec omniedge "$MODE" "$@"
        ;;
    *)
        echo "Error: Unknown mode '$MODE'"
        echo ""
        show_help
        exit 1
        ;;
esac
