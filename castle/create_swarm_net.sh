#!/bin/sh
echo "Setup Marketplace Overlay Network"
docker network create --driver=overlay --attachable --gateway=192.168.90.1 --subnet=192.168.90.0/24 marketplace
echo "Setup Warehouse Overlay Network"
docker network create --driver=overlay --attachable --gateway=192.168.91.1 --subnet=192.168.91.0/24 warehouse
docker network create --driver=overlay --attachable --gateway=192.168.92.1 --subnet=192.168.92.0/24 socket_proxy
echo "The Docker Networks On This Machine Are:"
docker network ls