#!/bin/sh
set -e

# Setup TUN device
setup_tun() {
    if [ ! -d /dev/net ]; then
        mkdir -p /dev/net
    fi
    if [ ! -e /dev/net/tun ]; then
        mknod /dev/net/tun c 10 200
    fi
}

# Build command from environment variables
build_command_from_env() {
    CMD="start"
    
    # Mode (default: edge)
    MODE="${OMNIEDGE_MODE:-edge}"
    CMD="$CMD --mode $MODE"
    
    # Network ID
    if [ -n "$OMNIEDGE_NETWORK_ID" ]; then
        CMD="$CMD -n $OMNIEDGE_NETWORK_ID"
    fi
    
    # Security key
    if [ -n "$OMNIEDGE_SECURITY_KEY" ]; then
        CMD="$CMD -s $OMNIEDGE_SECURITY_KEY"
    fi
    
    # Secret (for nucleus/dual)
    if [ -n "$OMNIEDGE_SECRET" ]; then
        CMD="$CMD --secret $OMNIEDGE_SECRET"
    fi
    
    # Port
    if [ -n "$OMNIEDGE_PORT" ]; then
        CMD="$CMD --port $OMNIEDGE_PORT"
    fi
    
    # Exit node options
    if [ "$OMNIEDGE_AS_EXIT_NODE" = "true" ] || [ "$OMNIEDGE_AS_EXIT_NODE" = "1" ]; then
        CMD="$CMD --as-exit-node"
    fi
    
    if [ -n "$OMNIEDGE_EXIT_NODE" ]; then
        CMD="$CMD --exit-node $OMNIEDGE_EXIT_NODE"
    fi
    
    # Verbose
    if [ "$OMNIEDGE_VERBOSE" = "true" ] || [ "$OMNIEDGE_VERBOSE" = "1" ]; then
        CMD="$CMD --verbose"
    fi
    
    echo "$CMD"
}

# Validate configuration
validate_config() {
    MODE="${OMNIEDGE_MODE:-edge}"
    
    case "$MODE" in
        edge)
            if [ -z "$OMNIEDGE_NETWORK_ID" ]; then
                echo "Error: OMNIEDGE_NETWORK_ID is required for edge mode"
                return 1
            fi
            if [ -z "$OMNIEDGE_SECURITY_KEY" ]; then
                echo "Error: OMNIEDGE_SECURITY_KEY is required for edge mode"
                return 1
            fi
            ;;
        nucleus)
            if [ -z "$OMNIEDGE_SECRET" ]; then
                echo "Error: OMNIEDGE_SECRET is required for nucleus mode (min 16 chars)"
                return 1
            fi
            ;;
        dual)
            if [ -z "$OMNIEDGE_NETWORK_ID" ]; then
                echo "Error: OMNIEDGE_NETWORK_ID is required for dual mode"
                return 1
            fi
            if [ -z "$OMNIEDGE_SECURITY_KEY" ]; then
                echo "Error: OMNIEDGE_SECURITY_KEY is required for dual mode"
                return 1
            fi
            ;;
    esac
    return 0
}

# Show help
show_help() {
    echo "OmniEdge Docker Container"
    echo ""
    echo "Usage:"
    echo "  1. Using environment variables (recommended for docker-compose):"
    echo "     OMNIEDGE_MODE=edge|nucleus|dual"
    echo "     OMNIEDGE_NETWORK_ID=<network-id>     (edge/dual)"
    echo "     OMNIEDGE_SECURITY_KEY=<key>          (edge/dual)"
    echo "     OMNIEDGE_SECRET=<secret>             (nucleus/dual, min 16 chars)"
    echo "     OMNIEDGE_PORT=51820                  (nucleus, optional)"
    echo "     OMNIEDGE_AS_EXIT_NODE=true           (optional)"
    echo "     OMNIEDGE_EXIT_NODE=<ip>              (optional)"
    echo "     OMNIEDGE_VERBOSE=true                (optional)"
    echo ""
    echo "  2. Using CLI flags:"
    echo "     docker run omniedge/omniedge start --mode edge -n <id> -s <key>"
    echo "     docker run omniedge/omniedge start --mode nucleus --secret <secret>"
    echo "     docker run omniedge/omniedge start --mode dual -n <id> -s <key> --secret <secret>"
    echo ""
    echo "  3. Other commands:"
    echo "     docker run omniedge/omniedge status"
    echo "     docker run omniedge/omniedge --help"
}

# Main
setup_tun

echo "=== OmniEdge Docker ==="

# If CLI arguments provided (not just "start"), pass directly to omniedge
if [ $# -gt 0 ]; then
    # Check if it's a bare "start" command (from CMD default)
    if [ "$1" = "start" ] && [ $# -eq 1 ]; then
        # Check if env vars are set for auto-configuration
        if [ -n "$OMNIEDGE_NETWORK_ID" ] || [ -n "$OMNIEDGE_SECRET" ]; then
            if validate_config; then
                CMD=$(build_command_from_env)
                echo "Mode: ${OMNIEDGE_MODE:-edge}"
                echo "Running: omniedge $CMD"
                exec omniedge $CMD
            else
                echo ""
                show_help
                exit 1
            fi
        else
            echo "No configuration provided."
            echo ""
            show_help
            exit 1
        fi
    else
        # User provided explicit arguments
        echo "Running: omniedge $@"
        exec omniedge "$@"
    fi
fi

# No arguments at all
show_help
exit 1
