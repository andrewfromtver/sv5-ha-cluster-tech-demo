# encoding: utf-8
# -*- mode: ruby -*-
# vi: set ft=ruby :


VM_BOX = 'generic/debian10'

HA_PROXY_RAM = 1024
HA_PROXY_CPU = 1
DB_NODE_RAM = 2048
DB_NODE_CPU = 2
SV_ELASTIC_RAM = 2048
SV_ELASTIC_CPU = 2
SV_RABBITMQ_RAM = 2048
SV_RABBITMQ_CPU = 2
SV_SERVICES_RAM = 2048
SV_SERVICES_CPU = 2
SV_WEBPORTAL_RAM = 1024
SV_WEBPORTAL_CPU = 1

HA_PROXY_IP = "192.168.56.110"
PG_NODE_1_IP = "192.168.56.111"
PG_NODE_2_IP = "192.168.56.112"
PG_NODE_3_IP = "192.168.56.113"
ELASTIC_1_IP = "192.168.56.114"
ELASTIC_2_IP = "192.168.56.115"
RABBITMQ_1_IP = "192.168.56.116"
RABBITMQ_2_IP = "192.168.56.117"
SV_SERVICES_1_IP = "192.168.56.118"
SV_SERVICES_2_IP = "192.168.56.119"
SV_WEBPORTAL_1_IP = "192.168.56.120"
SV_WEBPORTAL_2_IP = "192.168.56.121"

POSTGRES_MAJOR_VERSION = 14
RABBITMQ_USER = "user"
POSTGRES_PASSWORD = "sv5password"
POSTGRES_DATABASE = "SecurityVision"

RABBITMQ_USER="sv5user"
RABBITMQ_PASSWORD = "sv5password"

ETCD_CLUSTER_TOKEN = "etcdtesttoken"


Vagrant.configure(2) do |config|

  $pg_count = 3
  PG_IP_ARRAY = [PG_NODE_1_IP, PG_NODE_2_IP, PG_NODE_3_IP]

  (1..$pg_count).each do |i|
    config.vm.define "pgnode#{i}" do |pgnode|
      pgnode.vm.box = VM_BOX
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
        "POSTGRES_MAJOR_VERSION" => POSTGRES_MAJOR_VERSION,
        "POSTGRES_PASSWORD" => POSTGRES_PASSWORD,
        "HA_PROXY_IP" => HA_PROXY_IP,
        "PG_NODE_1_IP" => PG_NODE_1_IP,
        "PG_NODE_2_IP" => PG_NODE_2_IP,
        "PG_NODE_3_IP" => PG_NODE_3_IP,
        "CURRENT_NODE_IP" => PG_IP_ARRAY[i - 1]
      }
      pgnode.trigger.after :up do
        if(i <= $pg_count) then
          pgnode.vm.provision "shell", run: 'always', inline: <<-SHELL
            systemctl enable etcd &
            systemctl start etcd &
            systemctl enable patroni &
            systemctl start patroni &
          SHELL
        end
        if(i == $pg_count) then
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
    haproxy.vm.box = VM_BOX
    haproxy.vm.hostname = "haproxy"
    haproxy.vm.provider "virtualbox" do |v|
      v.name = "ha proxy"
      v.memory = HA_PROXY_RAM
      v.cpus = HA_PROXY_CPU
    end
    haproxy.vm.network "private_network", ip: HA_PROXY_IP
    haproxy.vm.provision "shell", path: "ha_proxy_init.sh", env: {
      "PG_NODE_1_IP" => PG_NODE_1_IP,
      "PG_NODE_2_IP" => PG_NODE_2_IP,
      "PG_NODE_3_IP" => PG_NODE_3_IP,
      "ELASTIC_1_IP" => ELASTIC_1_IP,
      "ELASTIC_2_IP" => ELASTIC_2_IP,
      "RABBITMQ_1_IP" => RABBITMQ_1_IP,
      "RABBITMQ_2_IP" => RABBITMQ_2_IP,
      "SV_SERVICES_1_IP" => SV_SERVICES_1_IP,
      "SV_SERVICES_2_IP" => SV_SERVICES_2_IP,
      "SV_WEBPORTAL_1_IP" => SV_WEBPORTAL_1_IP,
      "SV_WEBPORTAL_2_IP" => SV_WEBPORTAL_2_IP
    }
  end

  $elastic_count = 2
  ELASTIC_IP_ARRAY = [ELASTIC_1_IP, ELASTIC_2_IP]

  (1..$elastic_count).each do |i|
    config.vm.define "sv5elastic" do |sv5elastic|
      sv5elastic.vm.box = VM_BOX
      sv5elastic.vm.hostname = "sv5elastic"
      sv5elastic.vm.provider "virtualbox" do |v|
        v.name = "sv5 elastic"
        v.memory = SV_ELASTIC_RAM
        v.cpus = SV_ELASTIC_CPU
      end
      sv5elastic.vm.network "private_network", ip: ELASTIC_IP_ARRAY[i - 1]
      sv5elastic.vm.synced_folder "./distr/", "/distr"
      sv5elastic.vm.provision "shell", inline: <<-SHELL
        apt-get update
        apt-get install -y gnupg2 apt-transport-https
        curl  -fsSL https://artifacts.elastic.co/GPG-KEY-elasticsearch | gpg --dearmor -o /etc/apt/trusted.gpg.d/elastic.gpg
        echo "deb https://artifacts.elastic.co/packages/oss-7.x/apt stable main" | sudo tee  /etc/apt/sources.list.d/elastic-7.x.list
        apt update
        apt install elasticsearch-oss
        echo "network.host: "#{ELASTIC_IP_ARRAY[i - 1]} >> /etc/elasticsearch/elasticsearch.yml
        echo "discovery.seed_hosts: ["#{SV_WEBPORTAL_1_IP}","#{SV_WEBPORTAL_2_IP}"]" >> /etc/elasticsearch/elasticsearch.yml
        systemctl enable elasticsearch.service
        systemctl start elasticsearch.service
        systemctl status elasticsearch.service
      SHELL
    end
  end


  $rabbit_count = 2
  RABBIT_IP_ARRAY = [RABBIT_1_IP, RABBIT_2_IP]

  (1..$rabbit_count).each do |i|
    config.vm.define "sv5rabbitmq" do |sv5rabbitmq|
      sv5rabbitmq.vm.box = VM_BOX
      sv5rabbitmq.vm.hostname = "sv5rabbitmq"
      sv5rabbitmq.vm.provider "virtualbox" do |v|
        v.name = "sv5 rabbitmq"
        v.memory = SV_RABBITMQ_RAM
        v.cpus = SV_RABBITMQ_CPU
      end
      sv5rabbitmq.vm.network "private_network", ip: RABBIT_IP_ARRAY[i - 1]
      sv5rabbitmq.vm.synced_folder "./distr/", "/distr"
      sv5rabbitmq.vm.provision "shell", inline: <<-SHELL
        wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb
        dpkg -i erlang-solutions_1.0_all.deb
        apt-get update
        apt-get install -y erlang erlang-nox
        add-apt-repository 'deb http://www.rabbitmq.com/debian/ testing main'
        wget -O- https://www.rabbitmq.com/rabbitmq-release-signing-key.asc | apt-key add -
        apt-get update
        apt-get install rabbitmq-server
        rabbitmqctl add_user #{RABBITMQ_USER} #{RABBITMQ_PASSWORD}
        rabbitmqctl set_user_tags #{RABBITMQ_USER} administrator
        rabbitmqctl set_permissions -p / #{RABBITMQ_USER} ".*" ".*" ".*"
        rabbitmqctl authenticate_user #{RABBITMQ_USER} #{RABBITMQ_PASSWORD}
        rabbitmq-plugins enable rabbitmq_management
      SHELL
    end
  end


  # config.vm.define "sv5services" do |sv5services|
  #   sv5services.vm.box = VM_BOX
  #   sv5services.vm.hostname = 'sv5services'
  #   sv5services.vm.provider "virtualbox" do |v|
  #     v.name = "sv5 services"
  #     v.memory = SV_SERVICES_RAM
  #     v.cpus = SV_SERVICES_CPU
  #   end
  #   sv5services.vm.network "private_network", ip: SV_SERVICES_1_IP
  #   sv5services.vm.synced_folder "./config/", "/config"
  #   sv5services.vm.synced_folder "./distr/", "/distr"
  #   sv5services.vm.provision "shell", path: "downloader.sh", env: {
  #     "NEXUS_LOGIN" => ENV["NEXUS_LOGIN"],
  #     "NEXUS_PASSWORD" => ENV["NEXUS_PASSWORD"],
  #     "NEXUS_URL" => ENV["NEXUS_URL"],
  #     "NEXUS_FILE" => "SecurityVisionPlatform-console.v5",
  #     "FILE_PATH" => "/distr/installer-console.v5"
  #   }
  #   sv5services.vm.provision "shell", inline: <<-SHELL
  #     chmod +x /distr/installer-console.v5
  #     /distr/installer-console.v5 --config /config/services.json
  #   SHELL
  # end


  # config.vm.define "sv5webportal" do |sv5webportal|
  #   sv5webportal.vm.box = VM_BOX
  #   sv5webportal.vm.hostname = "sv5webportal"
  #   sv5webportal.vm.provider "virtualbox" do |v|
  #     v.name = "sv5 webportal"
  #     v.memory = SV_WEBPORTAL_RAM
  #     v.cpus = SV_WEBPORTAL_CPU
  #   end
  #   sv5webportal.vm.network "private_network", ip: SV_WEBPORTAL_1_IP
  #   sv5webportal.vm.synced_folder "./config/", "/config"
  #   sv5webportal.vm.synced_folder "./distr/", "/distr"
  #   sv5webportal.vm.provision "shell", inline: <<-SHELL
  #       chmod +x /distr/installer-console.v5
  #       /distr/installer-console.v5 --config /config/webportal.json
  #   SHELL
  # end

end
