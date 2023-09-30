# Pre-requirement
*Third-party software*
* Oracle VM VirtualBox
* Vagrant by HashiCorp

*SecurityVision installer*
* redist folder (unpack and put in `distr` folder of this project)
* installer-console.v5 (rename downloaded installer and put in `distr` folder of this project)

# Deployment
* Start deployment with `vagrant up` command
* To fix postgres node after reboot - start node, stop postgresql service `systemctl stop postgresql` and reinit patroni node `patronictl -c /etc/patroni.yml reinit [cluster_name] [node_name]` or just run `vagrant up` and pgsql cluster will reinit automatically

# Env vars
* `$NEXUS_LOGIN`
* `$NEXUS_PASSWORD`
* `$NEXUS_URL`
