# LXC Monitoring Stack

Stacks de observabilidad desplegados directamente con Docker Compose en el LXC de monitoring.

## Files

- `homepage.yaml`: Homepage compose stack.
- `dozzle.yaml`: Dozzle compose stack.

## Bootstrap

El host se prepara automáticamente con el workflow:

- `.github/workflows/lxc-monitoring-bootstrap.yaml`

El workflow instala Docker y crea los directorios runtime (`/opt/monitoring`).
Requiere solo el secret de repositorio `BW_TOKEN`.

## Deploy de stacks

Una vez bootstrapeado el host, despliegar los stacks manualmente:

```bash
# Homepage
docker compose -f /opt/monitoring/compose/homepage.yaml up -d

# Dozzle
docker compose -f /opt/monitoring/compose/dozzle.yaml up -d
```

## Validación

Tras el deploy verificar:

- Homepage: `http://192.168.100.114:3000`
- Dozzle: `http://192.168.100.114:8088`

Checks opcionales en el host:

```bash
docker ps
docker compose -f /opt/monitoring/compose/homepage.yaml ps
docker compose -f /opt/monitoring/compose/dozzle.yaml ps
```
