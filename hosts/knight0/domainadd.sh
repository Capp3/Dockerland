#!/bin/bash
# add_subdomain.sh
# Usage: sudo ./add_subdomain.sh <subdomain> <port> [ip]
# Example: sudo ./add_subdomain.sh myapp 12345 192.168.1.211
# If IP is not provided, defaults to 192.168.1.210

CONFIG_FILE=/etc/cloudflared/config.yml
TUNNEL_NAME=knight0
SUBDOMAIN=$1
PORT=$2
IP=${3:-192.168.1.210}

# Help tag
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo "Usage: sudo $0 <subdomain> <port> [ip]"
    echo "  <subdomain> : subdomain name to add"
    echo "  <port>      : local service port"
    echo "  [ip]        : optional local IP (default 192.168.1.210)"
    exit 0
fi

if [[ -z "$SUBDOMAIN" || -z "$PORT" ]]; then
    echo "Error: Subdomain and port are required. Use --help for usage."
    exit 1
fi

# 1. Check for duplicate hostname in config.yml
if grep -q "$SUBDOMAIN" "$CONFIG_FILE"; then
    echo "Error: $SUBDOMAIN already exists in $CONFIG_FILE"
    exit 1
fi

# 2. Check if DNS route exists
if cloudflared tunnel route dns "$TUNNEL_NAME" | grep -q "$SUBDOMAIN"; then
    echo "Error: DNS route for $SUBDOMAIN.capparelli.ie already exists"
    exit 1
fi

# 3. Check for port conflict in config.yml
if grep -q ":$PORT" "$CONFIG_FILE"; then
    echo "Error: Port $PORT is already used in the config.yml. Choose a different port."
    exit 1
fi

# 4. Optional: Check if local service is responding
if ! curl -s --head "http://$IP:$PORT" | head -n 1 | grep -q "HTTP"; then
    echo "Warning: Service on $IP:$PORT might not be available"
fi

# 5. Append ingress entry above fallback rule
sudo sed -i "/http_status:404/i \\  - hostname: $SUBDOMAIN\\n    service: http://$IP:$PORT" "$CONFIG_FILE"

echo "Ingress entry for $SUBDOMAIN added to $CONFIG_FILE"

# 6. Add DNS route
cloudflared tunnel route dns "$TUNNEL_NAME" "$SUBDOMAIN.capparelli.ie"

# 7. Restart tunnel service
sudo systemctl restart cloudflared-tunnel

# 8. Confirm
systemctl status cloudflared-tunnel --no-pager | head -n 10

echo "Subdomain $SUBDOMAIN.capparelli.ie added successfully and tunnel restarted."
