# Pre-requirement
*Third-party software*
* Oracle VM VirtualBox
* Vagrant by HashiCorp

# Env vars
* `$NEXUS_LOGIN`
* `$NEXUS_PASSWORD`
* `$NEXUS_URL`
* `$PROJECT_URL`
* `$TELEGRAM_BOT_TOKEN`
* `$TELEGRAM_CHAT_ID`

# Deployment
* Start deployment with `vagrant up` command
* To fix postgres node after reboot - start node, stop postgresql service `systemctl stop postgresql` and reinit patroni node `patronictl -c /etc/patroni.yml reinit [cluster_name] [node_name]` or just run `vagrant up` and pgsql cluster will reinit automatically
