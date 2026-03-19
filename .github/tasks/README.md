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
- Objetivo: dejar operativo el LXC de observabilidad.
- Que hace:
	- instala Docker y dependencias base.
	- prepara directorios de runtime en el host.
	- sincroniza `komodo.yaml` y `.env`.
	- despliega stack de Komodo (Core, Periphery y base de datos).
- Resultado esperado: panel de Komodo disponible y host listo para gestionar deploys GitOps de monitoring.
