#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
apt-get -y install haproxy

echo "\
global
  maxconn 5000

defaults
  log global
  mode tcp
  retries 2
  timeout client 30m
  timeout connect 4s
  timeout server 30m
  timeout check 5s

listen stats
  mode http
  bind *:80
  stats enable
  stats uri /

listen sv5postgres
  bind *:5432
  option httpchk
  http-check expect status 200
  default-server inter 3s fall 3 rise 2 on-marked-down shutdown-sessions
  server pgnode1 $MASTER_IP:5432 maxconn 100 check port 8008
  server pgnode2 $SLAVE_1_IP:5432 maxconn 100 check port 8008
  server pgnode3 $SLAVE_2_IP:5432 maxconn 100 check port 8008

listen sv5elastic
  bind *:9200
  option httpchk
  http-check expect status 200
  server sv5elastic $SV_ELASTIC_IP:9200 maxconn 100 check port 9200

listen  sv5rabbitmq 
  bind *:5672
  server sv5rabbitmq $SV_RABBITMQ_IP:5672 maxconn 1000 check port 5672

listen sv5connectors
  bind *:9210
  server sv5connector1 $SV_CONNECTORS_1_IP:9210 maxconn 100 check port 9210
  server sv5connector2 $SV_CONNECTORS_2_IP:9210 maxconn 100 check port 9210
  server sv5connector3 $SV_CONNECTORS_3_IP:9210 maxconn 100 check port 9210

listen sv5webportal
  bind *:443
  server sv5webportal $SV_WEBPORTAL_IP:443 maxconn 100 check port 443

" > /etc/haproxy/haproxy.cfg

systemctl restart haproxy
