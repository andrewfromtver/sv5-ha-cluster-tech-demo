# encoding: utf-8
# -*- mode: ruby -*-
# vi: set ft=ruby :


VM_BOX_UBUNTU = 'generic/ubuntu2204'
VM_BOX_DEBIAN = 'generic/debian10'

HA_PROXY_RAM = 2048
HA_PROXY_CPU = 2
DB_NODE_RAM = 2048
DB_NODE_CPU = 2
SV_ELASTIC_RAM = 2048
SV_ELASTIC_CPU = 2
SV_RABBITMQ_RAM = 2048
SV_RABBITMQ_CPU = 2
SV_SERVICES_RAM = 2048
SV_SERVICES_CPU = 2
SV_CONNECTORS_RAM = 2048
SV_CONNECTORS_CPU = 2
SV_WEBPORTAL_RAM = 2048
SV_WEBPORTAL_CPU = 2

HA_PROXY_IP = "192.168.56.110"
MASTER_IP = "192.168.56.111"
SLAVE_1_IP = "192.168.56.112"
SLAVE_2_IP = "192.168.56.113"
SV_ELASTIC_IP = "192.168.56.114"
SV_RABBITMQ_IP = "192.168.56.115"
SV_SERVICES_IP = "192.168.56.116"
SV_CONNECTORS_1_IP = "192.168.56.117"
SV_CONNECTORS_2_IP = "192.168.56.118"
SV_CONNECTORS_3_IP = "192.168.56.119"
SV_WEBPORTAL_IP = "192.168.56.120"

POSTGRES_PASSWORD = "sv5password"

RABBITMQ_USER = "user"
RABBITMQ_PASSWORD = "sv5password"

ETCD_CLUSTER_TOKEN = "etcdtesttoken"


Vagrant.configure(2) do |config|

  $count = 3
  PG_IP_ARRAY = [MASTER_IP, SLAVE_1_IP, SLAVE_2_IP]
  CONNECTORS_IP_ARRAY = [SV_CONNECTORS_1_IP, SV_CONNECTORS_2_IP, SV_CONNECTORS_3_IP]

  (1..$count).each do |i|

    config.vm.define "pgnode#{i}" do |pgnode|
      pgnode.vm.box = VM_BOX_DEBIAN
      pgnode.vm.provider "virtualbox" do |v|
        v.name = "pg node #{i}"
        v.memory = DB_NODE_RAM
        v.cpus = DB_NODE_CPU
      end
      pgnode.vm.hostname = "pgnode#{i}"
      pgnode.vm.network "private_network", ip: PG_IP_ARRAY[i - 1]
      pgnode.vm.provision "shell", path: 'db_node_init.sh', env: {
        "NODE_NAME" => "pgnode#{i}",
        "ETCD_CLUSTER_TOKEN" => ETCD_CLUSTER_TOKEN,
        "POSTGRES_PASSWORD" => POSTGRES_PASSWORD,
        "HA_PROXY_IP" => HA_PROXY_IP,
        "MASTER_IP" => MASTER_IP,
        "SLAVE_1_IP" => SLAVE_1_IP,
        "SLAVE_2_IP" => SLAVE_2_IP,
        "CURRENT_NODE_IP" => PG_IP_ARRAY[i - 1]
      }
      pgnode.trigger.after :up do
        if(i <= $count) then
          pgnode.vm.provision "shell", run: 'always', inline: <<-SHELL
            systemctl enable etcd &
            systemctl start etcd &
            systemctl enable patroni &
            systemctl start patroni &
          SHELL
        end
        if(i == $count) then
          pgnode.vm.provision "shell", run: 'always', inline: <<-SHELL
            # check cluster status
            etcdctl member list
            patronictl -c /etc/patroni.yml list
          SHELL
        end
      end
    end
  end

  config.vm.define "haproxy" do |haproxy|
    haproxy.vm.box = VM_BOX_DEBIAN
    haproxy.vm.hostname = "haproxy"
    haproxy.vm.provider "virtualbox" do |v|
      v.name = "ha proxy"
      v.memory = HA_PROXY_RAM
      v.cpus = HA_PROXY_CPU
    end
    haproxy.vm.network "private_network", ip: HA_PROXY_IP
    haproxy.vm.provision "shell", path: "ha_proxy_init.sh", env: {
      "MASTER_IP" => MASTER_IP,
      "SLAVE_1_IP" => SLAVE_1_IP,
      "SLAVE_2_IP" => SLAVE_2_IP,
      "SV_ELASTIC_IP" => SV_ELASTIC_IP,
      "SV_RABBITMQ_IP" => SV_RABBITMQ_IP,
      "SV_CONNECTORS_1_IP" => SV_CONNECTORS_1_IP,
      "SV_CONNECTORS_2_IP" => SV_CONNECTORS_2_IP,
      "SV_CONNECTORS_3_IP" => SV_CONNECTORS_3_IP,
      "SV_WEBPORTAL_IP" => SV_WEBPORTAL_IP
    }
  end

  config.vm.define "sv5elastic" do |sv5elastic|
    sv5elastic.vm.box = VM_BOX_UBUNTU
    sv5elastic.vm.hostname = "sv5elastic"
    sv5elastic.vm.provider "virtualbox" do |v|
      v.name = "sv5 elastic"
      v.memory = SV_ELASTIC_RAM
      v.cpus = SV_ELASTIC_CPU
    end
    sv5elastic.vm.network "private_network", ip: SV_ELASTIC_IP
    sv5elastic.vm.synced_folder "./distr/", "/distr"
    sv5elastic.vm.provision "shell", inline: <<-SHELL
        dpkg -i /distr/redist/elastic/*.deb
        echo "network.host: 192.168.56.114" >> /etc/elasticsearch/elasticsearch.yml
        echo "discovery.seed_hosts: [192.168.56.110]" >> /etc/elasticsearch/elasticsearch.yml
        systemctl enable elasticsearch.service
        systemctl start elasticsearch.service
        systemctl status elasticsearch.service

    SHELL
  end

  config.vm.define "sv5rabbitmq" do |sv5rabbitmq|
    sv5rabbitmq.vm.box = VM_BOX_UBUNTU
    sv5rabbitmq.vm.hostname = "sv5rabbitmq"
    sv5rabbitmq.vm.provider "virtualbox" do |v|
      v.name = "sv5 rabbitmq"
      v.memory = SV_RABBITMQ_RAM
      v.cpus = SV_RABBITMQ_CPU
    end
    sv5rabbitmq.vm.network "private_network", ip: SV_RABBITMQ_IP
    sv5rabbitmq.vm.synced_folder "./distr/", "/distr"
    sv5rabbitmq.vm.provision "shell", inline: <<-SHELL
      dpkg -i /distr/redist/rabbitmq/*.deb
      rabbitmqctl add_user #{RABBITMQ_USER} #{RABBITMQ_PASSWORD}
      rabbitmqctl set_user_tags #{RABBITMQ_USER} administrator
      rabbitmqctl set_permissions -p / #{RABBITMQ_USER} ".*" ".*" ".*"
      rabbitmqctl authenticate_user #{RABBITMQ_USER} #{RABBITMQ_PASSWORD}
    SHELL
  end

  config.vm.define "sv5services" do |sv5services|
    sv5services.vm.box = VM_BOX_UBUNTU
    sv5services.vm.hostname = 'sv5services'
    sv5services.vm.provider "virtualbox" do |v|
      v.name = "sv5 services"
      v.memory = SV_SERVICES_RAM
      v.cpus = SV_SERVICES_CPU
    end
    sv5services.vm.network "private_network", ip: SV_SERVICES_IP
    sv5services.vm.synced_folder "./distr/", "/distr"
    sv5services.vm.provision "shell", inline: <<-SHELL
        chmod +x /distr/installer-console.v5
        /distr/installer-console.v5 --config /distr/config/services.json
    SHELL
  end

  (1..$count).each do |i|
    config.vm.define "sv5connectors#{i}" do |sv5connectors|
      sv5connectors.vm.box = VM_BOX_UBUNTU
      sv5connectors.vm.hostname = "sv5connectors#{i}"
      sv5connectors.vm.provider "virtualbox" do |v|
        v.name = "sv5 connectors #{i}"
        v.memory = SV_CONNECTORS_RAM
        v.cpus = SV_CONNECTORS_CPU
      end
      sv5connectors.vm.network "private_network", ip: CONNECTORS_IP_ARRAY[i - 1]
      sv5connectors.vm.synced_folder "./distr/", "/distr"
      sv5connectors.vm.provision "shell", inline: <<-SHELL
          chmod +x /distr/installer-console.v5
          /distr/installer-console.v5 --config /distr/config/connectors.json
      SHELL
    end
  end

  config.vm.define "sv5webportal" do |sv5webportal|
    sv5webportal.vm.box = VM_BOX_UBUNTU
    sv5webportal.vm.hostname = "sv5webportal"
    sv5webportal.vm.provider "virtualbox" do |v|
      v.name = "sv5 webportal"
      v.memory = SV_WEBPORTAL_RAM
      v.cpus = SV_WEBPORTAL_CPU
    end
    sv5webportal.vm.network "private_network", ip: SV_WEBPORTAL_IP
    sv5webportal.vm.synced_folder "./distr/", "/distr"
    sv5webportal.vm.provision "shell", inline: <<-SHELL
        chmod +x /distr/installer-console.v5
        /distr/installer-console.v5 --config /distr/config/webportal.json
    SHELL
  end

end
