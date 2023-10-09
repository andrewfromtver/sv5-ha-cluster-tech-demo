#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
apt-get -y install haproxy

echo "\
global
  maxconn 1000

defaults
  log global
  mode tcp
  retries 2
  timeout client 30m
  timeout connect 2s
  timeout server 30m
  timeout check 3s

listen stats
  mode http
  bind *:80
  stats enable
  stats uri /

listen postgres
  bind *:5432
  http-check expect status 200
  option httpchk
  default-server inter 3s fall 3 rise 2 on-marked-down shutdown-sessions
  server pgnode1 $PG_NODE_1_IP:5432 maxconn 100 check port 8008
  server pgnode2 $PG_NODE_2_IP:5432 maxconn 100 check port 8008
  server pgnode3 $PG_NODE_3_IP:5432 maxconn 100 check port 8008

listen elastic
  bind *:9200
  http-check expect status 200
  option httpchk
  server sv5elastic1 $ELASTIC_1_IP:9200 maxconn 100 check port 9200
  server sv5elastic2 $ELASTIC_2_IP:9200 backup maxconn 100 check port 9200

listen  rabbitmq 
  bind *:5672
  server sv5rabbitmq1 $RABBITMQ_1_IP:5672 maxconn 100 check port 5672
  server sv5rabbitmq2 $RABBITMQ_2_IP:5672 backup maxconn 100 check port 5672

listen sv5webportal
  bind *:9210
  server sv5services1 $SV_SERVICES_1_IP:9210 maxconn 100 check port 9210
  server sv5services2 $SV_SERVICES_2_IP:9210 backup maxconn 100 check port 9210

listen sv5webportal
  bind *:443
  server sv5webportal1 $SV_WEBPORTAL_1_IP:443 maxconn 100 check port 443
  server sv5webportal2 $SV_WEBPORTAL_2_IP:443 backup maxconn 100 check port 443

" > /etc/haproxy/haproxy.cfg

systemctl restart haproxy
