#!/bin/sh
wget https://www.privateinternetaccess.com/openvpn/openvpn.zip
unzip openvpn.zip -d /pia
cp /pia/france.ovpn /mnt/user/appdata/binhex-delugevpn/openvpn/france.ovpn
cp /pia/crl.rsa.2048.pem /mnt/user/appdata/binhex-delugevpn/openvpn/crl.rsa.2048.pem
cp /pia/ca.rsa.2048.crt /mnt/user/appdata/binhex-delugevpn/openvpn/ca.rsa.2048.crt