#!/bin/bash

# Nombre del proyecto
PROJECT_NAME="."

# Crear la estructura de carpetas
mkdir -p $PROJECT_NAME/{inventories,roles,playbooks,files}
mkdir -p $PROJECT_NAME/inventories/{development}/{group_vars,host_vars}

# Crear archivos básicos
touch $PROJECT_NAME/{ansible.cfg,README.md,requirements.yml}
touch $PROJECT_NAME/inventories/{development}/hosts.ini
touch $PROJECT_NAME/inventories/{development}/{group_vars}/all.yml
touch $PROJECT_NAME/playbooks/{deploy.yml,setup.yml}

# Crear un rol de ejemplo
ansible-galaxy init $PROJECT_NAME/roles/nginx_quic
ansible-galaxy init $PROJECT_NAME/roles/nginx_http2

echo "Estructura de proyecto Ansible creada en '$PROJECT_NAME'"