# Docker Services Structure

This document provides an overview of all Docker services running across different hosts in the infrastructure.

## Host: castle0

### Services

| Service Name | Description                               | Port Mappings                                                | Network  | Notes                                         |
| ------------ | ----------------------------------------- | ------------------------------------------------------------ | -------- | --------------------------------------------- |
| socket-proxy | Docker socket proxy for secure API access | 2375:2375                                                    | c0_proxy | Security critical - do not expose to internet |
| open-webui   | Web UI for AI services                    | 3000:8080                                                    | c0_proxy | GPU enabled, connects to Ollama               |
| syncthing    | File synchronization service              | 8384:8384, 22000:22000/tcp, 22000:22000/udp, 21027:21027/udp | default  | File synchronization                          |

### Networks

- c0_proxy: 192.168.92.0/24

## Host: knight0

### Services

#### Docker Management (docker.yml)

| Service Name | Description                  | Port Mappings | Network      | Notes                               |
| ------------ | ---------------------------- | ------------- | ------------ | ----------------------------------- |
| portainer    | Docker management UI         | 9000:9000     | socket_proxy | Uses socket-proxy for secure access |
| socket-proxy | Docker socket proxy          | 2375:2375     | socket_proxy | IP: 192.168.91.254                  |
| docker-gc    | Automatic garbage collection | -             | socket_proxy | Runs daily at midnight              |

#### DNS Services (dns.yml)

| Service Name    | Description         | Port Mappings | Network         | Notes              |
| --------------- | ------------------- | ------------- | --------------- | ------------------ |
| adguardhome     | DNS and ad blocking | -             | macvlan_network | IP: 192.168.1.254  |
| cloudflare-ddns | Dynamic DNS updater | -             | k0_proxy        | IP: 192.168.90.101 |

#### Media Services (plex.yml)

| Service Name | Description  | Port Mappings                                      | Network  | Notes                |
| ------------ | ------------ | -------------------------------------------------- | -------- | -------------------- |
| plex         | Media server | host network                                       | host     | Uses host networking |
| jellyfin     | Media server | 8096:8096, 8920:8920, 7359:7359/udp, 1900:1900/udp | k0_proxy | IP: 192.168.90.104   |

#### Web Services (webservices.yml)

| Service Name | Description   | Port Mappings                                                | Network  | Notes                |
| ------------ | ------------- | ------------------------------------------------------------ | -------- | -------------------- |
| homepage     | Dashboard     | 3000:3000                                                    | k0_proxy | IP: 192.168.90.111   |
| syncthing    | File sync     | 8384:8384, 22000:22000/tcp, 22000:22000/udp, 21027:21027/udp | default  | File synchronization |
| swag         | Reverse proxy | 4443:443, 4480:80                                            | k0_proxy | IP: 192.168.90.112   |
| authelia     | SSO & 2FA     | 9091:9091                                                    | k0_proxy | IP: 192.168.90.113   |
| redis        | Auth database | -                                                            | k0_proxy | IP: 192.168.90.114   |

#### Media Management (media.yml)

| Service Name | Description      | Port Mappings        | Network           | Notes              |
| ------------ | ---------------- | -------------------- | ----------------- | ------------------ |
| gluetun      | VPN container    | Various ports        | k0_proxy          | IP: 192.168.90.102 |
| deluge       | Torrent client   | Uses gluetun         | container:gluetun | Depends on gluetun |
| flaresolverr | Captcha solver   | Uses gluetun         | container:gluetun | Depends on gluetun |
| prowlarr     | Indexer manager  | Uses gluetun         | container:gluetun | Depends on gluetun |
| radarr       | Movie manager    | Uses gluetun         | container:gluetun | Depends on gluetun |
| sonarr       | TV manager       | Uses gluetun         | container:gluetun | Depends on gluetun |
| bazarr       | Subtitle manager | Uses gluetun         | container:gluetun | Depends on gluetun |
| tdarr        | Media transcoder | 8265:8265, 8266:8266 | bridge            | GPU enabled        |
| jellyseerr   | Media requests   | Uses gluetun         | container:gluetun | Depends on gluetun |

#### Streaming (rtmp.yml)

| Service Name | Description    | Port Mappings | Network | Notes             |
| ------------ | -------------- | ------------- | ------- | ----------------- |
| nginx-rtmp   | RTMP streaming | 1935:1935     | default | Basic RTMP server |

### Networks

- local1: 192.168.10.0/24
- socket_proxy: 192.168.91.0/24
- k0_proxy: 192.168.90.0/24
- macvlan_network: 192.168.1.0/24 (parent: enp0s31f6)

### Important Notes for knight0

1. **VPN Integration**

   - Most media services run through gluetun VPN container
   - Services using VPN are in container:gluetun network mode
   - Ports are exposed through gluetun container

2. **Media Management**

   - Comprehensive media stack with automated downloading
   - Includes transcoding capabilities (tdarr)
   - Multiple media servers (Plex, Jellyfin)

3. **Security**

   - Authelia provides SSO and 2FA
   - Redis backend for authentication
   - SWAG reverse proxy with Let's Encrypt

4. **Storage**
   - Media directories mounted from external storage
   - Configurations stored in persistent volumes
   - Temporary storage for downloads and transcoding

## Host: knight1

### Services

| Service Name | Description                  | Port Mappings          | Network | Notes                             |
| ------------ | ---------------------------- | ---------------------- | ------- | --------------------------------- |
| readsb       | ADS-B receiver               | 8090:8080, 30005:30005 | local1  | RTLSDR device, IP: 192.168.10.102 |
| adsbexchange | ADS-B data sharing           | -                      | local1  | IP: 192.168.10.103                |
| socket-proxy | Docker socket proxy          | 2375:2375              | local1  | Security critical                 |
| docker-gc    | Automatic garbage collection | -                      | local1  | Runs daily at midnight            |

### Networks

- local1: 192.168.10.0/24

## Host: scout1

### Services

| Service Name | Description                  | Port Mappings        | Network | Notes                    |
| ------------ | ---------------------------- | -------------------- | ------- | ------------------------ |
| tvheadend    | TV streaming server          | 9981:9981, 9982:9982 | default | DVB device support       |
| dozzle       | Docker log viewer            | ${DOZZLE_PORT}:8080  | s1proxy | Real-time log monitoring |
| socket-proxy | Docker socket proxy          | 2375:2375            | s1proxy | Security critical        |
| docker-gc    | Automatic garbage collection | -                    | s1proxy | Runs daily at midnight   |

### Networks

- s1proxy: 192.168.20.0/24

## Common Services Across Hosts

Several services are deployed across multiple hosts with similar configurations:

1. **socket-proxy**

   - Purpose: Secure Docker API access
   - Port: 2375:2375
   - Security: Critical - should not be exposed to internet
   - Common configuration across all hosts

2. **docker-gc**
   - Purpose: Automatic Docker garbage collection
   - Schedule: Daily at midnight
   - Common configuration across knight1 and scout1

## Important Notes

1. **Security**

   - Docker socket proxies (2375) should never be exposed to the internet
   - Each host maintains its own isolated networks
   - Security options are enforced (no-new-privileges)

2. **Networking**

   - Each host has its own subnet for internal communication
   - Some hosts use macvlan for direct network access
   - Network isolation is maintained between hosts

3. **Resource Management**

   - GPU resources are allocated where needed (e.g., open-webui)
   - Automatic garbage collection is implemented
   - Resource limits and reservations are specified where critical

4. **Storage**
   - Persistent volumes are used for critical data
   - Some services use tmpfs for temporary storage
   - External storage mounts are configured where needed
