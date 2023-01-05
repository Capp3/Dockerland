#!/bin/sh
apt update
apt install python3 -y
curl -sSl https://raw.githubusercontent.com/mmotti/pihole-regex/master/install.py | sudo python3
git clone https://github.com/anudeepND/whitelist.git
python3 whitelist/scripts/whitelist.py
git clone https://github.com/anudeepND/whitelist.git
./whitelist/scripts/referral.sh
pihole -g