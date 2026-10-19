# Tasks

1. `hyperion-bootstrap.yml`
- Objetivo: bootstrap base del entorno Hyperion.
- Que hace: prepara los componentes iniciales requeridos para levantar la infraestructura objetivo.
- Resultado esperado: Hyperion queda listo para continuar con aprovisionamiento y despliegues del stack principal.

2. `lxc-auth-bootstrap.yml`
- Objetivo: dejar operativo el LXC de autenticacion.
- Que hace:
	- instala Docker en el host remoto (si no existe).
	- prepara runtime necesario para Authentik.
	- sincroniza compose y `.env`.
	- despliega el stack de Authentik.
- Resultado esperado: servicios de Authentik levantados y accesibles en el LXC `auth`.

3. `lxc-monitoring-bootstrap.yml`
- Objetivo: dejar el LXC de observabilidad con Docker instalado y listo para despliegues.
- Que hace:
	- instala Docker y dependencias base.
	- prepara directorios de runtime en el host (`/opt/monitoring`).
- Resultado esperado: host con Docker operativo y estructura de directorios lista para desplegar los stacks de monitoring manualmente.

4. `pihole-dns-sync.yml`
- Objetivo: mantener los registros DNS locales de Pi-hole declarados en `pihole/records.yaml`.
- Que hace:
	- valida el archivo (nombres, IPs, destinos de CNAME y ciclos).
	- genera los arrays `dns.hosts` y `dns.cnameRecords`.
	- compara contra Pi-hole por SSH (`diff`) y los reemplaza completos (`apply`).
- Resultado esperado: Pi-hole contiene exactamente los registros del archivo; lo creado a mano en la UI se elimina.
