#!/usr/bin/bash
sudo rm /home/server/data/swag/nginx/proxy-confs/assets.subdomain.conf
sudo rm /home/server/data/swag/nginx/proxy-confs/projects.subdomain.conf
sudo rm /home/server/data/swag/nginx/proxy-confs/requests.subdomain.conf
sudo ln -s /home/server/data/swag/nginx/proxy-confs/assets.subdomain.conf ./assets.conf
sudo ln -s /home/server/data/swag/nginx/proxy-confs/projects.subdomain.conf ./projects.conf
sudo ln -s /home/server/data/swag/nginx/proxy-confs/requests.subdomain.conf ./requests.conf