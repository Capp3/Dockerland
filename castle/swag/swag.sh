#!/usr/bin/bash
sudo rm /home/server/data/swag/nginx/proxy-confs/assets.subdomain.conf
sudo rm /home/server/data/swag/nginx/proxy-confs/projects.subdomain.conf
sudo rm /home/server/data/swag/nginx/proxy-confs/requests.subdomain.conf
sudo ln -s assets.conf /home/server/data/swag/nginx/proxy-confs/assets.subdomain.conf
sudo ln -s projects.conf /home/server/data/swag/nginx/proxy-confs/projects.subdomain.conf
sudo ln -s requests.conf /home/server/data/swag/nginx/proxy-confs/requests.subdomain.conf