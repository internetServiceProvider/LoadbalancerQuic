# Proyecto Load Balancer con QUIC/HTTP3 usando Nginx, Ansible y Vagrant

## 1. Descripción General

Este proyecto automatiza la creación de una infraestructura web compuesta por dos servidores web backend (Nginx con HTTP/2) y un servidor proxy Nginx que actúa como balanceador de carga con soporte para HTTP/3 (QUIC). La infraestructura se aprovisiona utilizando Vagrant para la creación de máquinas virtuales (VMs) y Ansible para la configuración y gestión automatizada de los servidores.

El objetivo principal es demostrar y facilitar la configuración de HTTP/3 en un entorno de pruebas local.

**Diagrama de la Infraestructura:**

```

                              +-------------------------+
                              |      Usuario Final      |
                              +-----------+-------------+
                                          |
                                          | (HTTPS - TCP/443)
                                          | (HTTP/3 - UDP/443)
                                          | (Acceso via yourdomain.test)
                                          v

+-------------------------------------------------------------------------------------------+
| Máquina Virtual: Proxy Nginx (Load Balancer) |
| IP: 192.168.50.20 |
| |
| +------------------------+ +-------------------------------------------------+ |
| | Interfaz de Red | ----> | Nginx Service (en Proxy) | |
| | (Escucha en 443/tcp | | - Terminación SSL/TLS (Certificado Autofirmado) | |
| | y 443/udp) | | - Soporte HTTP/1.1, HTTP/2, HTTP/3 (QUIC) | |
| +------------------------+ | - Balanceo de carga (ej. Round-Robin) | |
| | - Proxy Reverso hacia los Web Servers Backend | |
| +-----------------------+-------------------------+ |
| | | |
+-------------------------------------------------------------|----------|------------------+
| |
(Tráfico interno, ej. HTTP/2 o HTTP) | | (Tráfico interno, ej. HTTP/2 o HTTP)
v v
+-------------------------------------------+ +-------------------------------------------+
| Máquina Virtual: Web Server 1 | | Máquina Virtual: Web Server 2 |
| IP: 192.168.50.21 | | IP: 192.168.50.22 |
| | | |
| +-------------------------------+ | | +-------------------------------+ |
| | Nginx Service (Backend) | | | | Nginx Service (Backend) | |
| | - Sirve contenido estático | | | | - Sirve contenido estático | |
| | (ej. index.html) | | | | (ej. index.html) | |
| | - Escucha en puerto interno | | | | - Escucha en puerto interno | |
| | (ej. 80 o 8080) | | | | (ej. 80 o 8080) | |
| +-------------------------------+ | | +-------------------------------+ |
+-------------------------------------------+ +-------------------------------------------+

```

## 2. Prerrequisitos

Antes de comenzar, asegúrate de tener instalado el siguiente software:

- **Vagrant:** (Última versión estable recomendada) - [Descargar Vagrant](https://www.vagrantup.com/downloads)
- **Ansible:** (Versión 2.9 o superior recomendada) - [Instalar Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
- **Hipervisor para Vagrant:**
  - VirtualBox (Recomendado y comúnmente usado con Vagrant) - [Descargar VirtualBox](https://www.virtualbox.org/wiki/Downloads)
  - Otras opciones: VMware, Hyper-V (pueden requerir ajustes en el `Vagrantfile`).
- **Git:** (Para clonar este repositorio, si aplica) - [Descargar Git](https://git-scm.com/downloads)
- **Navegador web moderno** (para pruebas, ej. Google Chrome)
- **cURL con soporte HTTP/3** (para pruebas por línea de comandos)

## 3. Estructura del Proyecto

El proyecto está organizado de la siguiente manera:

```

.
├── ansible.cfg # Configuración de Ansible para este proyecto
├── configure.sh # Script principal para aprovisionar y configurar el entorno
├── files # Archivos estáticos (ej. scripts, Vagrantfile base)
│ ├── createProject.sh # Script auxiliar (si existe, detallar su función)
│ └── Vagrantfile # Define las VMs (proxy, web1, web2) y su configuración básica
├── inventories # Definiciones de inventario de Ansible
│ └── development # Entorno de desarrollo
│ ├── group_vars/ # Variables para grupos de hosts
│ ├── hosts.ini # Define los hosts gestionados y sus grupos
│ └── host_vars/ # Variables específicas para hosts individuales
│ ├── proxy.yml # Variables para el servidor proxy
│ ├── web1.yml # Variables para el servidor web1
│ └── web2.yml # Variables para el servidor web2
├── playbooks # Playbooks de Ansible para orquestar la configuración
│ ├── config_quic.yml # Playbook para tareas específicas de QUIC (parte de nginx_quic_proxy)
│ ├── deploy.yml # Playbook para desplegar la aplicación/sitio web
│ ├── orchestrator.yml # Playbook principal que ejecuta todos los roles necesarios
│ └── setup_nginx.yml # Playbook para la configuración base de Nginx
├── README.md # Este archivo
└── roles # Roles de Ansible para modularizar la configuración
├── nginx_http2 # Configura los servidores web backend con Nginx y HTTP/2
├── nginx_install # Instala Nginx (compilado desde fuentes con QUIC)
└── nginx_quic_proxy # Configura el Nginx proxy con soporte QUIC/HTTP3 y SSL

```

## 4. Configuración y Ejecución

Sigue estos pasos para levantar y configurar el entorno:

1.  **Clonar el Repositorio (si aplica):**

    ```bash
    git clone <URL_DEL_REPOSITORIO>
    cd nombre-del-directorio-del-proyecto
    ```

2.  **Ejecutar el Script de Configuración:**
    El script `configure.sh` está diseñado para automatizar el proceso de levantamiento de las VMs con Vagrant y la ejecución de los playbooks de Ansible.

    ```bash
    bash configure.sh
    ```

    Este script típicamente realizará las siguientes acciones:

    - Verificará dependencias (opcional).
    - Ejecutará `vagrant up` para crear y aprovisionar las máquinas virtuales definidas en el `Vagrantfile` (proxy, web1, web2).
    - Ejecutará el playbook principal de Ansible (ej. `ansible-playbook playbooks/orchestrator.yml -i inventories/development/hosts.ini`) para configurar los servicios en las VMs.

3.  **Acceso a las VMs (Opcional):**
    Puedes acceder a cada VM individualmente usando Vagrant:
    ```bash
    vagrant ssh proxy
    vagrant ssh web1
    vagrant ssh web2
    ```

**Variables Importantes:**

- **IPs de las VMs:** Estas IPs deben estar configuradas en tu `Vagrantfile` y/o en el inventario de Ansible (`inventories/development/hosts.ini`). Para este proyecto, las IPs son:
  - `proxy`: `192.168.50.20`
  - `web1`: `192.168.50.21`
  - `web2`: `192.168.50.22`
- **Dominio de Prueba:** El proxy Nginx se configurará para un nombre de dominio. Este suele estar definido en las variables de Ansible (ej. `roles/nginx_quic_proxy/vars/main.yml` o `inventories/development/host_vars/proxy.yml`). Para las pruebas, usaremos `yourdomain.test` como ejemplo. Deberás añadirlo a tu archivo `/etc/hosts` local:
  ```
  # Añadir esta línea a tu archivo /etc/hosts (o C:\Windows\System32\drivers\etc\hosts en Windows)
  192.168.50.20 yourdomain.test
  ```
- **Certificados SSL:** El rol `nginx_quic_proxy` (específicamente la tarea `01_setup_ssl.yml`) genera un certificado SSL autofirmado para el dominio de prueba. Estos se almacenan típicamente en `/etc/nginx/ssl/` dentro de la VM del proxy (ej. `nginx.crt` y `nginx.key`).

## 5. Pruebas de QUIC / HTTP3

Una vez que el entorno esté configurado, puedes probar la conexión HTTP/3.

### A. Preparación

- Asegúrate de que el script `configure.sh` haya finalizado correctamente.
- Verifica que el dominio de prueba (ej. `yourdomain.test`) esté añadido a tu archivo `/etc/hosts` local y apunte a la IP de la VM del proxy (`192.168.50.20`).

### B. Pruebas con Google Chrome

1.  **Habilitar QUIC (si es necesario):**

    - Abre Chrome y ve a `chrome://flags/`.
    - Busca "Experimental QUIC protocol" (`#enable-quic`) y configúralo como "Enabled".
    - Reinicia Chrome.

2.  **Forzar QUIC para un Origen Específico (Recomendado para Pruebas Locales):**
    Puedes iniciar Chrome con un flag para indicarle que intente QUIC para tu dominio de prueba. Cierra todas las instancias de Chrome antes de ejecutar este comando.

    - **Linux:**
      ```bash
      google-chrome --origin-to-force-quic-on=yourdomain.test:443
      # o si usas chromium:
      # chromium-browser --origin-to-force-quic-on=yourdomain.test:443
      ```
    - **macOS:**
      ```bash
      /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --origin-to-force-quic-on=yourdomain.test:443
      ```
    - **Windows:**
      Crea un acceso directo a Chrome y en las propiedades, añade el flag al final del campo "Destino":
      `"C:\Program Files\Google\Chrome\Application\chrome.exe" --origin-to-force-quic-on=yourdomain.test:443`

    _Nota: El puerto `:443` es el puerto UDP estándar para HTTP/3. Asegúrate que tu Nginx proxy esté configurado para escuchar QUIC en este puerto._

3.  **Ignorar Errores de Certificado (para certificados autofirmados):**
    Dado que se usa un certificado autofirmado, Chrome mostrará una advertencia de seguridad. Para pruebas locales, puedes:

    - Simplemente aceptar la advertencia (haciendo clic en "Avanzado" y "Continuar a yourdomain.test (no seguro)").
    - O, para una solución más robusta con el hash SPKI (opcional y más complejo para este setup):
      1.  Copia el certificado público del servidor proxy (`/etc/nginx/ssl/nginx.crt` en la VM del proxy) a tu máquina local.
      2.  Extrae el hash SPKI:
          ```bash
          openssl x509 -in /ruta/a/tu/nginx.crt -pubkey -noout | openssl rsa -pubin -outform der | openssl dgst -sha256 -binary | base64
          ```
      3.  Inicia Chrome con el hash:
          ```bash
          google-chrome --ignore-certificate-errors-spki-list=TU_HASH_SPKI_AQUI [https://yourdomain.test](https://yourdomain.test)
          ```

4.  **Verificar la Conexión HTTP/3:**
    - Con Chrome abierto (idealmente con el flag `--origin-to-force-quic-on`), navega a `https://yourdomain.test`.
    - Abre las Herramientas de Desarrollador (F12 o Cmd+Opt+I).
    - Ve a la pestaña "Network".
    - Recarga la página (F5 o Cmd+R).
    - Busca la columna "Protocol". Debería mostrar `h3` o `http/2+quic/46` (o similar, indicando HTTP/3). Si no ves la columna "Protocol", haz clic derecho en las cabeceras de la tabla (ej. "Name", "Status") y actívala.
    - También puedes visitar `chrome://net-internals/#http3` (o buscar en `chrome://net-export/` después de capturar logs) para ver estadísticas de sesiones QUIC/HTTP3 activas.

### C. Pruebas con cURL

1.  **Verificar Soporte HTTP/3 en cURL:**
    Asegúrate de que tu versión de cURL fue compilada con soporte HTTP/3.

    ```bash
    curl -V
    ```

    Busca `HTTP3` en la lista de "Features". Si no está, necesitarás instalar una versión de cURL que lo incluya (esto puede implicar compilarlo desde fuentes o usar un gestor de paquetes que ofrezca una versión moderna).

2.  **Ejecutar la Prueba:**

    ```bash
    curl --http3 [https://yourdomain.test/](https://yourdomain.test/) --insecure -v -o /dev/null
    ```

    - `--http3`: Intenta la conexión usando HTTP/3. Dependiendo de la versión de curl y la librería HTTP/3 subyacente, podrías necesitar `--http3-direct` o similar si el descubrimiento por Alt-Svc no funciona como se espera para pruebas locales.
    - `https://yourdomain.test/`: La URL de tu sitio.
    - `--insecure`: Necesario para omitir la validación del certificado autofirmado.
    - `-v`: Modo verboso para ver detalles de la conexión.
    - `-o /dev/null`: Para descartar la salida del cuerpo de la respuesta y solo ver las cabeceras y detalles de conexión.

    En la salida verbosa, busca líneas que indiquen el uso de HTTP/3:

    ```
    * ALPN: offers h3
    * ALPN: server accepted h3
    * Using HTTP/3 Stream ID: 1 (easy handle 0x...)
    > GET / HTTP/3
    > Host: yourdomain.test
    >
    < HTTP/3 200
    ...
    ```

## 6. Contenido Servido (Página Web de Ejemplo)

Los servidores web backend (`web1`, `web2`) son configurados por el rol `nginx_http2`. Este rol utiliza una plantilla `index.html.j2` (ubicada en `roles/nginx_http2/templates/index.html.j2`) como página de inicio por defecto. Esta es la página que se servirá cuando accedas a `https://yourdomain.test/`.

Si deseas servir la página del ISP "NovaLink" que se desarrolló anteriormente, puedes:

1.  Reemplazar el contenido de `roles/nginx_http2/templates/index.html.j2` con el HTML de la página NovaLink.
2.  O, modificar el playbook `deploy.yml` (o el rol `nginx_http2`) para copiar el archivo HTML de NovaLink al directorio raíz de los servidores web (ej. `/var/www/html/`).

Asegúrate de volver a ejecutar Ansible (`bash configure.sh` o el playbook específico) si realizas cambios en las plantillas o archivos a desplegar.

## 7. Solución de Problemas (Troubleshooting)

- **Problemas con Vagrant:**
  - Verifica los logs de `vagrant up`.
  - Asegúrate de que tu hipervisor esté funcionando correctamente.
  - Intenta `vagrant destroy -f && vagrant up` para una reconstrucción limpia.
- **Problemas con Ansible:**
  - Revisa la salida del playbook. Aumenta la verbosidad con `-v`, `-vv`, o `-vvv`.
  - Verifica la sintaxis de los archivos YAML.
  - Asegúrate de que las VMs sean accesibles por SSH desde donde ejecutas Ansible.
- **Problemas con Nginx o QUIC:**
  - Conéctate a la VM del proxy (`vagrant ssh proxy`) y revisa los logs de Nginx:
    - `sudo tail -f /var/log/nginx/access.log`
    - `sudo tail -f /var/log/nginx/error.log`
  - Verifica la configuración de Nginx: `sudo nginx -t`.
  - Asegúrate de que los puertos UDP/TCP (usualmente 443) estén abiertos en el firewall de la VM (el rol `nginx_quic_proxy` debería manejar esto con `03_firewall.yml`).
  - Si Chrome no muestra `h3`, verifica `chrome://flags` y que el flag `--origin-to-force-quic-on` esté correctamente aplicado. Cierra _todas_ las instancias de Chrome antes de lanzarlo con flags.
- **Conflicto de Puertos:** Asegúrate de que el puerto 443 (TCP y UDP) no esté siendo utilizado por otro servicio en tu máquina anfitriona si estás usando un `Vagrantfile` con reenvío de puertos directos (aunque el ejemplo común usa IPs privadas para las VMs).
