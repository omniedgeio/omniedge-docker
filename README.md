# OmniEdge Docker

> Latest version: 2.0.0

Run OmniEdge CLI in a Docker container with support for all three operational modes.

## Modes

| Mode | Description | Auth Required | VPN Tunnel | Signaling Server |
|------|-------------|---------------|------------|------------------|
| **edge** (default) | Regular VPN client | Yes | Yes | No |
| **nucleus** | Signaling server only | No | No | Yes |
| **dual** | VPN client + signaling | Yes | Yes | Yes |

## Environment Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `OMNIEDGE_MODE` | No | `edge` | Operating mode: `edge`, `nucleus`, or `dual` |
| `OMNIEDGE_NETWORK_ID` | edge/dual | - | Virtual network ID to join |
| `OMNIEDGE_SECURITY_KEY` | edge/dual | - | Security key for authentication |
| `OMNIEDGE_SECRET` | nucleus/dual | - | Cluster secret (min 16 characters) |
| `OMNIEDGE_PORT` | No | `51820` | UDP port for nucleus server |
| `OMNIEDGE_AS_EXIT_NODE` | No | `false` | Act as an exit node |
| `OMNIEDGE_EXIT_NODE` | No | - | Use a specific exit node IP |
| `OMNIEDGE_VERBOSE` | No | `false` | Enable verbose logging |

## Quick Start

### Edge Mode (VPN Client)

```bash
docker run -d \
  --name omniedge \
  --privileged \
  --network host \
  -e OMNIEDGE_MODE=edge \
  -e OMNIEDGE_NETWORK_ID="your-network-id" \
  -e OMNIEDGE_SECURITY_KEY="your-security-key" \
  -v /dev/net/tun:/dev/net/tun \
  omniedge/omniedge:latest
```

### Nucleus Mode (Signaling Server)

```bash
docker run -d \
  --name omniedge-nucleus \
  --network host \
  -e OMNIEDGE_MODE=nucleus \
  -e OMNIEDGE_SECRET="YourSecretMin16Chars" \
  -e OMNIEDGE_PORT=51820 \
  omniedge/omniedge:latest
```

### Dual Mode (VPN Client + Signaling Server)

```bash
docker run -d \
  --name omniedge-dual \
  --privileged \
  --network host \
  -e OMNIEDGE_MODE=dual \
  -e OMNIEDGE_NETWORK_ID="your-network-id" \
  -e OMNIEDGE_SECURITY_KEY="your-security-key" \
  -e OMNIEDGE_SECRET="YourSecretMin16Chars" \
  -v /dev/net/tun:/dev/net/tun \
  omniedge/omniedge:latest
```

## Docker Compose

### Edge Mode

```yaml
version: "3.8"
services:
  omniedge:
    image: omniedge/omniedge:latest
    container_name: omniedge
    privileged: true
    network_mode: host
    restart: unless-stopped
    environment:
      - OMNIEDGE_MODE=edge
      - OMNIEDGE_NETWORK_ID=your-network-id
      - OMNIEDGE_SECURITY_KEY=your-security-key
    volumes:
      - /dev/net/tun:/dev/net/tun
    cap_add:
      - NET_ADMIN
```

### Nucleus Mode

```yaml
version: "3.8"
services:
  omniedge-nucleus:
    image: omniedge/omniedge:latest
    container_name: omniedge-nucleus
    network_mode: host
    restart: unless-stopped
    environment:
      - OMNIEDGE_MODE=nucleus
      - OMNIEDGE_SECRET=YourSecretMin16Chars
      - OMNIEDGE_PORT=51820
```

### Dual Mode

```yaml
version: "3.8"
services:
  omniedge-dual:
    image: omniedge/omniedge:latest
    container_name: omniedge-dual
    privileged: true
    network_mode: host
    restart: unless-stopped
    environment:
      - OMNIEDGE_MODE=dual
      - OMNIEDGE_NETWORK_ID=your-network-id
      - OMNIEDGE_SECURITY_KEY=your-security-key
      - OMNIEDGE_SECRET=YourSecretMin16Chars
    volumes:
      - /dev/net/tun:/dev/net/tun
    cap_add:
      - NET_ADMIN
```

## Build

```bash
# Build for current architecture
docker build -t omniedge/omniedge:latest .

# Build with specific version
docker build --build-arg VERSION=2.0.0 -t omniedge/omniedge:2.0.0 .

# Multi-arch build
docker buildx build --platform linux/amd64,linux/arm64,linux/arm/v7 \
  -t omniedge/omniedge:latest --push .
```

## Exit Node Configuration

### Run as Exit Node

```bash
docker run -d \
  --name omniedge \
  --privileged \
  --network host \
  -e OMNIEDGE_MODE=edge \
  -e OMNIEDGE_NETWORK_ID="your-network-id" \
  -e OMNIEDGE_SECURITY_KEY="your-security-key" \
  -e OMNIEDGE_AS_EXIT_NODE=true \
  -v /dev/net/tun:/dev/net/tun \
  omniedge/omniedge:latest
```

### Use Specific Exit Node

```bash
docker run -d \
  --name omniedge \
  --privileged \
  --network host \
  -e OMNIEDGE_MODE=edge \
  -e OMNIEDGE_NETWORK_ID="your-network-id" \
  -e OMNIEDGE_SECURITY_KEY="your-security-key" \
  -e OMNIEDGE_EXIT_NODE="10.0.0.1" \
  -v /dev/net/tun:/dev/net/tun \
  omniedge/omniedge:latest
```

## Supported Architectures

- `linux/amd64` (x86_64)
- `linux/arm64` (ARM64, Raspberry Pi 4/5)
- `linux/arm/v7` (ARMv7, Raspberry Pi 3)

## License

Apache-2.0 OR MIT
