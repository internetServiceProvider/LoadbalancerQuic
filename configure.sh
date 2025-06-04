#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")"

cd files

echo "Starting Vagrant..."
vagrant up

cd ..

ansible-playbook -i inventories/development/hosts.ini playbooks/setup_nginx.yml
ansible-playbook -i inventories/development/hosts.ini playbooks/deploy.yml
ansible-playbook -i inventories/development/hosts.ini playbooks/config_quic.yml