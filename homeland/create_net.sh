#!/bin/sh
echo "Setup Marketplace Overlay Network"
docker network create --driver=overlay --attachable marketplace
echo "The Docker Networks On This Machine Are:"
docker network ls