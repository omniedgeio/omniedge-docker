#!/bin/sh
set -e

# Setup TUN device
if [ ! -d /dev/net ]; then
    mkdir -p /dev/net
fi
if [ ! -e /dev/net/tun ]; then
    mknod /dev/net/tun c 10 200
fi

# Build command arguments based on mode
build_args() {
    ARGS="start"
    
    # Mode (edge, nucleus, dual)
    if [ -n "${OMNIEDGE_MODE}" ]; then
        ARGS="${ARGS} --mode ${OMNIEDGE_MODE}"
    fi
    
    # Network ID (required for edge and dual modes)
    if [ -n "${OMNIEDGE_NETWORK_ID}" ]; then
        ARGS="${ARGS} --network-id ${OMNIEDGE_NETWORK_ID}"
    fi
    
    # Security key (for authentication)
    if [ -n "${OMNIEDGE_SECURITY_KEY}" ]; then
        ARGS="${ARGS} --security-key ${OMNIEDGE_SECURITY_KEY}"
    fi
    
    # Secret (required for nucleus and dual modes)
    if [ -n "${OMNIEDGE_SECRET}" ]; then
        ARGS="${ARGS} --secret ${OMNIEDGE_SECRET}"
    fi
    
    # Port (for nucleus mode)
    if [ -n "${OMNIEDGE_PORT}" ] && [ "${OMNIEDGE_PORT}" != "51820" ]; then
        ARGS="${ARGS} --port ${OMNIEDGE_PORT}"
    fi
    
    # Exit node options
    if [ "${OMNIEDGE_AS_EXIT_NODE}" = "true" ]; then
        ARGS="${ARGS} --as-exit-node"
    fi
    
    if [ -n "${OMNIEDGE_EXIT_NODE}" ]; then
        ARGS="${ARGS} --exit-node ${OMNIEDGE_EXIT_NODE}"
    fi
    
    # Verbose logging
    if [ "${OMNIEDGE_VERBOSE}" = "true" ]; then
        ARGS="${ARGS} --verbose"
    fi
    
    echo "${ARGS}"
}

# Validate configuration based on mode
validate_config() {
    case "${OMNIEDGE_MODE}" in
        edge)
            if [ -z "${OMNIEDGE_NETWORK_ID}" ]; then
                echo "Error: OMNIEDGE_NETWORK_ID is required for edge mode"
                exit 1
            fi
            if [ -z "${OMNIEDGE_SECURITY_KEY}" ]; then
                echo "Error: OMNIEDGE_SECURITY_KEY is required for edge mode"
                exit 1
            fi
            ;;
        nucleus)
            if [ -z "${OMNIEDGE_SECRET}" ]; then
                echo "Error: OMNIEDGE_SECRET is required for nucleus mode (min 16 characters)"
                exit 1
            fi
            ;;
        dual)
            if [ -z "${OMNIEDGE_NETWORK_ID}" ]; then
                echo "Error: OMNIEDGE_NETWORK_ID is required for dual mode"
                exit 1
            fi
            if [ -z "${OMNIEDGE_SECURITY_KEY}" ]; then
                echo "Error: OMNIEDGE_SECURITY_KEY is required for dual mode"
                exit 1
            fi
            ;;
        *)
            echo "Error: Invalid OMNIEDGE_MODE '${OMNIEDGE_MODE}'. Must be: edge, nucleus, or dual"
            exit 1
            ;;
    esac
}

# Main
echo "=== OmniEdge Docker Container ==="
echo "Mode: ${OMNIEDGE_MODE}"
echo "================================="

validate_config

OMNIEDGE_ARGS=$(build_args)
echo "Starting: omniedge ${OMNIEDGE_ARGS}"

exec omniedge ${OMNIEDGE_ARGS}
