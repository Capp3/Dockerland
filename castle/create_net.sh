#!/bin/sh
echo "Setup Marketplace Overlay Network"
docker network create --driver=overlay --attachable marketplace
echo "Setup Warehouse Overlay Network"
docker network create --driver=overlay --attachable warehouse
docker network create --driver=overlay --attachable socket_proxy
echo "The Docker Networks On This Machine Are:"
docker network ls