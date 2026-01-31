# OmniEdge Docker

> Latest version: 2.0.0

Run OmniEdge CLI in a Docker container with support for all three operational modes.

## Modes

| Mode | Description | Auth Required | VPN Tunnel | Signaling Server |
|------|-------------|---------------|------------|------------------|
| **edge** (default) | Regular VPN client | Yes | Yes | No |
| **nucleus** | Signaling server only | No | No | Yes |
| **dual** | VPN client + signaling | Yes | Yes | Yes |

## Quick Start

### Edge Mode (VPN Client)

```bash
docker run -d \
  --name omniedge \
  --privileged \
  --network host \
  -v /dev/net/tun:/dev/net/tun \
  omniedge/omniedge:latest \
  start --mode edge -n <network_id> -s <security_key>
```

### Nucleus Mode (Signaling Server)

```bash
docker run -d \
  --name omniedge-nucleus \
  --network host \
  omniedge/omniedge:latest \
  start --mode nucleus --secret "YourSecretMin16Chars" --port 51820
```

### Dual Mode (VPN Client + Signaling Server)

```bash
docker run -d \
  --name omniedge-dual \
  --privileged \
  --network host \
  -v /dev/net/tun:/dev/net/tun \
  omniedge/omniedge:latest \
  start --mode dual -n <network_id> -s <security_key> --secret "YourSecretMin16Chars"
```

## CLI Flags

| Flag | Short | Description |
|------|-------|-------------|
| `--mode <MODE>` | `-m` | Operating mode: `edge`, `nucleus`, `dual` |
| `--network-id <ID>` | `-n` | Virtual network ID to join |
| `--security-key <KEY>` | `-s` | Security key for authentication |
| `--secret <SECRET>` | | Cluster secret for nucleus mode (min 16 chars) |
| `--port <PORT>` | `-p` | UDP port for nucleus server (default: 51820) |
| `--as-exit-node` | `-x` | Act as an exit node |
| `--exit-node <IP>` | `-e` | Use a specific exit node IP |
| `--verbose` | `-v` | Enable verbose logging |

## Docker Compose

Create a `.env` file:

```bash
OMNIEDGE_NETWORK_ID=your-network-id
OMNIEDGE_SECURITY_KEY=your-security-key
OMNIEDGE_SECRET=YourSecretMin16Chars
```

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
    command: ["start", "--mode", "edge", "-n", "${OMNIEDGE_NETWORK_ID}", "-s", "${OMNIEDGE_SECURITY_KEY}"]
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
    command: ["start", "--mode", "nucleus", "--secret", "${OMNIEDGE_SECRET}", "--port", "51820"]
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
    command: ["start", "--mode", "dual", "-n", "${OMNIEDGE_NETWORK_ID}", "-s", "${OMNIEDGE_SECURITY_KEY}", "--secret", "${OMNIEDGE_SECRET}"]
    volumes:
      - /dev/net/tun:/dev/net/tun
    cap_add:
      - NET_ADMIN
```

## Exit Node Configuration

### Run as Exit Node

```bash
docker run -d \
  --name omniedge \
  --privileged \
  --network host \
  -v /dev/net/tun:/dev/net/tun \
  omniedge/omniedge:latest \
  start --mode edge -n <network_id> -s <security_key> --as-exit-node
```

### Use Specific Exit Node

```bash
docker run -d \
  --name omniedge \
  --privileged \
  --network host \
  -v /dev/net/tun:/dev/net/tun \
  omniedge/omniedge:latest \
  start --mode edge -n <network_id> -s <security_key> --exit-node 10.0.0.1
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

## Supported Architectures

- `linux/amd64` (x86_64)
- `linux/arm64` (ARM64, Raspberry Pi 4/5)
- `linux/arm/v7` (ARMv7, Raspberry Pi 3)

## License

Apache-2.0 OR MIT
