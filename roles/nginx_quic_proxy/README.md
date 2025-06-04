# Ansible Role: Nginx QUIC Proxy

Este rol configura Nginx (asumiendo que ya está instalado con soporte QUIC/HTTP3) como un reverse proxy y balanceador de carga. Está diseñado para ser probado usando la IP del servidor proxy en lugar de un nombre de dominio, generando certificados SSL autofirmados.

## Requisitos

- Nginx instalado con el módulo `--with-http_v3_module`.
- Acceso root o con `sudo` en el nodo gestionado.
- Colecciones de Ansible:
  - `community.crypto` (para generar SSL)
  - `community.general` (para el módulo `ufw`, si se usa)
  - `ansible.posix` (para el módulo `firewalld`, si se usa)
    Instálalas con:
  ```bash
  ansible-galaxy collection install community.crypto community.general ansible.posix
  ```

## Variables del Rol

Ver `defaults/main.yml` para la lista completa de variables y sus valores por defecto. Las más importantes a sobrescribir son:

- `nginx_proxy_ip`: La IP pública o accesible de este servidor Nginx proxy. Se usa para el `server_name` y el CN del certificado SSL.
- `nginx_backend_servers`: Una lista de diccionarios, cada uno con `ip` y `port` de los servidores web backend.
  ```yaml
  nginx_backend_servers:
    - ip: "192.168.1.11"
      port: 80
    - ip: "192.168.1.12"
      port: 80
  ```
- `nginx_load_balancing_method`: (Opcional) Define el método de balanceo de Nginx. Ejemplos: `least_conn`, `ip_hash`. Por defecto es round-robin (vacío).

## Playbook de Ejemplo

```yaml
---
- name: Configurar Nginx QUIC Proxy
  hosts: nginx_proxy_server # El host donde correrá el proxy
  become: yes
  vars:
    nginx_proxy_ip: "YOUR_NGINX_PROXY_SERVER_IP" # Reemplaza con la IP real
    nginx_backend_servers:
      - { ip: "IP_WEBSERVER_1", port: 80 }
      - { ip: "IP_WEBSERVER_2", port: 80 }
  roles:
    - role: nginx_quic_proxy
```
