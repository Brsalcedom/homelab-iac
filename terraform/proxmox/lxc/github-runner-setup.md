# 🏃 GitHub Self-Hosted Runner Setup (LXC Container)

Este documento describe el proceso completo de configuración del contenedor LXC `github-runner-01` como GitHub Self-Hosted Runner para ejecutar workflows de CI/CD del repositorio `homelab-iac`.

---

## 📋 Requisitos Previos

- Contenedor LXC `github-runner-01` desplegado y en ejecución
- Llave SSH privada configurada durante la creación del contenedor
- Token de GitHub para registrar el runner (obtenido desde GitHub)
- Conexión a internet desde el contenedor

---

## 🔌 Acceso al Contenedor

Antes de comenzar, conectarse al contenedor LXC como usuario `root` usando SSH:

```bash
ssh root@<IP_DEL_CONTENEDOR>
```

O si tienes configurada una llave SSH específica:

```bash
ssh -i ~/.ssh/id_ed25519 root@<IP_DEL_CONTENEDOR>
```

**Nota importante**: Los pasos 1, 2 y 3 (instalación de dependencias, Docker y creación de usuario) se ejecutan como `root` directamente, **sin usar `sudo`**. A partir del paso 4, cuando se trabaja con el usuario `github`, se usará `sudo` cuando sea necesario.

---

## 🎯 Propósito

Este runner ejecuta workflows de GitHub Actions que requieren:
- Ejecución de comandos Terraform/OpenTofu
- Acceso a contenedores Docker (jobs que corren en `container:`)
- Integración con Bitwarden Secrets Manager
- Despliegue de infraestructura en Proxmox y Kubernetes

Ver workflows de ejemplo:
- `.github/workflows/tofu-proxmox-lxc.yaml`
- `.github/workflows/tofu-k8s-hyperion.yaml`

---

## 🔧 Instalación y Configuración

> **⚠️ Importante**: Los siguientes pasos (1-3) se ejecutan como usuario `root` sin usar `sudo`.

> **📌 Nota sobre el Sistema Operativo**: Esta guía está basada en **Debian 13**. Si utilizas otro sistema operativo en tu contenedor LXC, consulta la [documentación oficial de Docker](https://docs.docker.com/engine/install/) para las instrucciones específicas de instalación.

### 1. Instalar Dependencias Base

Como `root`, instalar las dependencias necesarias:

```bash
apt update
apt install -y curl git sudo ca-certificates
```

### 2. Instalar Docker

El runner necesita Docker para ejecutar jobs que usan `container:` en los workflows.

#### Agregar la clave GPG oficial de Docker

```bash
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
```

#### Agregar el repositorio de Docker

```bash
tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: $(. /etc/os-release && echo "$VERSION_CODENAME")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF
```

#### Instalar Docker Engine

```bash
apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

#### Verificar instalación

```bash
docker --version
docker run hello-world
```

---

### 3. Crear Usuario para el Runner

Por seguridad, el runner NO debe ejecutarse como root.

```bash
# Crear usuario github
useradd -m -s /bin/bash github

# Establecer contraseña (opcional)
passwd github

# Agregar usuario al grupo docker
usermod -aG docker github

# Agregar permisos sudo (para gestión del servicio)
usermod -aG sudo github
```

---

### 4. Descargar y Configurar GitHub Actions Runner

> **📝 Nota**: A partir de este paso, trabajaremos como usuario `github` y usaremos `sudo` cuando sea necesario.

Cambiar al usuario `github`:

```bash
su - github
```

#### Crear directorio y descargar el runner

> **📌 Nota sobre la versión**: Los comandos a continuación usan la versión **2.331.0** del runner. Para obtener la última versión disponible, consulta la [página de releases de GitHub Actions Runner](https://github.com/actions/runner/releases).

```bash
# Crear directorio para el runner
mkdir -p ~/actions-runner && cd ~/actions-runner

# Descargar la última versión del runner para Linux x64
curl -o actions-runner-linux-x64-2.331.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.331.0/actions-runner-linux-x64-2.331.0.tar.gz

# Validar el hash (opcional pero recomendado)
echo "<hash>  actions-runner-linux-x64-2.331.0.tar.gz" | sha256sum -c

# Extraer el instalador
tar xzf ./actions-runner-linux-x64-2.331.0.tar.gz
```

#### Configurar el runner

Necesitas obtener el token de registro desde GitHub:
1. Ve a tu repositorio en GitHub
2. Settings → Actions → Runners → New self-hosted runner
3. Copia el token que aparece en el comando de configuración

```bash
# Configurar el runner (reemplaza <TOKEN> con tu token real)
./config.sh --url https://github.com/<organization/user>/<repository> --token <TOKEN>
```

Durante la configuración:
- **Runner group**: Presiona Enter (default)
- **Runner name**: `github-runner-01` (o el nombre que prefieras)
- **Labels**: `self-hosted,Linux,X64` (default, presiona Enter)
- **Work folder**: Presiona Enter (default: `_work`)

---

### 5. Configurar el Runner como Servicio Systemd

> **📝 Nota**: Los comandos de gestión del servicio requieren privilegios de root, por eso usamos `sudo`.

> **⚠️ Importante sobre el nombre del servicio**: El nombre del servicio systemd se genera automáticamente con el formato `actions.runner.<USUARIO_U_ORG>-<REPOSITORIO>.<NOMBRE_RUNNER>.service`. Por ejemplo, si tu repositorio es `Brsalcedom/homelab-iac` y el runner se llama `github-runner-01`, el servicio será `actions.runner.Brsalcedom-homelab-iac.github-runner-01.service`.

Salir del usuario `github`:

```bash
exit  # Salir del usuario github
```

#### Instalar el servicio

Como usuario con privilegios sudo (puedes quedarte como `root` o usar cualquier usuario con sudo):

```bash
cd /home/github/actions-runner
sudo ./svc.sh install github
```

El comando mostrará el nombre exacto del servicio creado.

#### Iniciar el servicio

```bash
sudo ./svc.sh start
```

#### Verificar el estado

```bash
sudo ./svc.sh status
```

#### Habilitar inicio automático

```bash
# Reemplaza con el nombre de tu servicio
sudo systemctl enable actions.runner.<USUARIO_U_ORG>-<REPOSITORIO>.<NOMBRE_RUNNER>.service

# Ejemplo:
# sudo systemctl enable actions.runner.Brsalcedom-homelab-iac.github-runner-01.service
```

---

## 🧪 Verificación

### 1. Verificar que el servicio está corriendo

```bash
# Reemplaza con el nombre de tu servicio
sudo systemctl status actions.runner.<USUARIO_U_ORG>-<REPOSITORIO>.<NOMBRE_RUNNER>.service

# Ejemplo:
# sudo systemctl status actions.runner.Brsalcedom-homelab-iac.github-runner-01.service
```

> **💡 Tip**: Puedes obtener el nombre exacto del servicio ejecutando `sudo ./svc.sh status` desde el directorio `/home/github/actions-runner`.

### 2. Verificar en GitHub

1. Ve a tu repositorio en GitHub
2. Settings → Actions → Runners
3. Deberías ver `github-runner-01` con estado "Idle" (verde)

### 3. Probar con un workflow

Ejecuta manualmente uno de los workflows desde GitHub Actions para verificar que el runner toma el job correctamente.

---

## 🔄 Comandos Útiles

### Gestión del servicio

```bash
# Ver estado
sudo ./svc.sh status

# Detener el servicio
sudo ./svc.sh stop

# Iniciar el servicio
sudo ./svc.sh start

# Reiniciar el servicio
sudo ./svc.sh stop && sudo ./svc.sh start

# Desinstalar el servicio
sudo ./svc.sh uninstall
```

### Ver logs del runner

```bash
# Logs del servicio systemd (reemplaza con el nombre de tu servicio)
sudo journalctl -u actions.runner.<USUARIO_U_ORG>-<REPOSITORIO>.<NOMBRE_RUNNER>.service -f

# Ejemplo:
# sudo journalctl -u actions.runner.Brsalcedom-homelab-iac.github-runner-01.service -f

# Logs del runner (como usuario github)
su - github
cd ~/actions-runner
tail -f _diag/*.log
```

### Verificar Docker

```bash
# Como usuario github
su - github
docker ps
docker images
```

---

## 🔐 Seguridad

### Permisos del usuario github

El usuario `github` tiene acceso a:
- Docker socket (`/var/run/docker.sock`) - para ejecutar contenedores
- Directorio de trabajo del runner (`~/actions-runner/_work`)

### Secrets

Los secrets se gestionan mediante:
- **GitHub Secrets**: Configurados en el repositorio
- **Bitwarden Secrets Manager**: Integrado en los workflows mediante `bitwarden/sm-action@v2`

Nunca almacenes secrets en el contenedor o en archivos de configuración.

---

## 🐛 Troubleshooting

### El runner no aparece en GitHub

```bash
# Verificar que el servicio está corriendo (reemplaza con el nombre de tu servicio)
sudo systemctl status actions.runner.<USUARIO_U_ORG>-<REPOSITORIO>.<NOMBRE_RUNNER>.service

# Verificar logs
sudo journalctl -u actions.runner.<USUARIO_U_ORG>-<REPOSITORIO>.<NOMBRE_RUNNER>.service -n 50
```

### Error de permisos con Docker

```bash
# Verificar que el usuario github está en el grupo docker
groups github

# Si no está, agregarlo (como root)
usermod -aG docker github

# Reiniciar el servicio (reemplaza con el nombre de tu servicio)
sudo systemctl restart actions.runner.<USUARIO_U_ORG>-<REPOSITORIO>.<NOMBRE_RUNNER>.service
```

### El runner está "Offline"

```bash
# Verificar conectividad
ping github.com

# Reiniciar el servicio (reemplaza con el nombre de tu servicio)
sudo systemctl restart actions.runner.<USUARIO_U_ORG>-<REPOSITORIO>.<NOMBRE_RUNNER>.service
```

### Actualizar el runner

```bash
# Detener el servicio
cd /home/github/actions-runner
sudo ./svc.sh stop

# Como usuario github, descargar nueva versión
su - github
cd ~/actions-runner
curl -o actions-runner-linux-x64-<VERSION>.tar.gz -L https://github.com/actions/runner/releases/download/v<VERSION>/actions-runner-linux-x64-<VERSION>.tar.gz
tar xzf ./actions-runner-linux-x64-<VERSION>.tar.gz
exit

# Iniciar el servicio
sudo ./svc.sh start
```

---

## 📚 Referencias

- [GitHub Actions Self-Hosted Runners](https://docs.github.com/en/actions/hosting-your-own-runners)
- [Docker Installation on Debian](https://docs.docker.com/engine/install/debian/)
- [GitHub Actions Runner Releases](https://github.com/actions/runner/releases)
- [Bitwarden Secrets Manager Action](https://github.com/bitwarden/sm-action)

---

## 📝 Notas

- Este runner está configurado para ejecutar workflows del repositorio `homelab-iac`
- Los workflows utilizan la imagen `brsalcedom/homelab-ci:2.2.0` que contiene Terraform/OpenTofu y otras herramientas
- El runner puede ejecutar múltiples jobs simultáneamente si se configura con `--disableupdate` y múltiples instancias
- Se recomienda monitorear el uso de recursos (CPU, RAM, disco) del contenedor LXC
