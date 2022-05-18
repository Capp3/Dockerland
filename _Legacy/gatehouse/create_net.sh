#!/bin/sh
echo "Setup Rollcall"
docker network create -d macvlan \
  --subnet=192.168.1.0/24 \
  --ip-range=192.168.1.111/28 \
  --gateway=192.168.1.1 \
  -o parent=enp1s0 rollcall
echo "List of Docker Networks"
docker network ls