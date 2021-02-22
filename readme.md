


<!-- Run on Server 1 -->

docker run -d --name keepalived --restart=always \
  --cap-add=NET_ADMIN --cap-add=NET_BROADCAST --cap-add=NET_RAW --net=host \
  -e KEEPALIVED_UNICAST_PEERS="#PYTHON2BASH:['192.168.1.2', '192.168.1.3']" \
  -e KEEPALIVED_VIRTUAL_IPS=192.168.1.7 \
  -e KEEPALIVED_PRIORITY=200 \
  osixia/keepalived:2.0.20

<!-- Run on Server 2 -->