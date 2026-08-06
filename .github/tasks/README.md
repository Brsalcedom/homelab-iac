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
