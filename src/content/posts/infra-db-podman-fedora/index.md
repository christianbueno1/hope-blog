---
title: "Infraestructura Local de Base de Datos con Podman y Shell Scripts en Fedora Workstation"
description: "Automatizando PostgreSQL para Desarrollo Local con Podman, Pods y Bash Scripts"
pubDate: 2026-09-29
category: "sistemas-infrastructura"
image: "/og/infra-db-podman-fedora.webp"
---

# Infraestructura Local de Base de Datos con Podman y Shell Scripts en Fedora Workstation

En el entorno de desarrollo moderno, tener una infraestructura local rápida, aislada y fácil de recrear es clave para mantener la productividad. Aunque Docker Compose es una herramienta ampliamente extendida, **Podman** ofrece una alternativa nativa en distribuciones basadas en Red Hat como **Fedora Workstation**, destacando por su arquitectura *rootless* (sin necesidad de demonio como root) y el soporte nativo para el concepto de **Pods** (similar a Kubernetes).

En este artículo, explicaremos cómo automatizar el despliegue de una base de datos PostgreSQL local utilizando Podman, redes dedicadas, volúmenes persistentes y scripts en Bash desacoplados mediante archivos de variables de entorno (`.env`).

---

## Estructura del Proyecto

Para mantener el código organizado, utilizamos la siguiente jerarquía de archivos:

```text
clinicflow-api/
├── .env.example
├── .env.db.example
└── scripts/
    └── podman/
        ├── setup-db.sh
        └── teardown-db.sh
```

- **`.env.db.example`**: Configuración técnica para Podman y PostgreSQL.
- **`.env.example`**: Variables requeridas por la aplicación backend.
- **`setup-db.sh`**: Script para inicializar red, volumen, pod y contenedor.
- **`teardown-db.sh`**: Script para limpiar el entorno local sin perder datos no deseados.

---

## 1. Configuración del Entorno (`.env.db.example`)

Definimos la versión de la imagen, los nombres de los componentes de Podman y las credenciales iniciales de la base de datos:

```bash
DB_IMAGE=docker.io/library/postgres:18.6-trixie

PROJECT_NAME=clinicflow

NETWORK_NAME=clinicflow-net
DB_VOL_NAME=clinicflow-db-data
DB_POD_NAME=clinicflow-db-pod
DB_BOX_NAME=clinicflow-db-box

POSTGRES_USER=krs
POSTGRES_PASSWORD=change-me
POSTGRES_DB=clinicflow_db

DB_PORT=5432
```

> **Tip de seguridad:** Copia `.env.db.example` a `.env.db` y añade `.env.db` al `.gitignore` de tu proyecto para evitar subir contraseñas locales al repositorio.

### Agrega los valores en `.env.example`

Agrega los valores de conexión a la base de datos en el archivo `.env.example` para que la aplicación backend pueda conectarse correctamente:

```bash
# Variables de entorno para la aplicación backend
DATABASE_HOST=localhost
DATABASE_PORT=5432
DATABASE_USER=krs
DATABASE_PASSWORD=change-me
DATABASE_NAME=clinicflow_db
DEBUG=false
API_BASE_URL=http://localhost:8000
```

> **Tip de seguridad:** Copia `.env.example` a `.env` y añade `.env` al `.gitignore` para proteger tus credenciales de la base de datos.

---

## 2. Script de Despliegue (`setup-db.sh`)

El script principal se encarga de orquestar la creación paso a paso. Se implementa `set -euo pipefail` para asegurar que el script falle inmediatamente si ocurre algún error no controlado.

```bash
#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
ENV_FILE="$PROJECT_ROOT/.env.db"

if [[ ! -f "$ENV_FILE" ]]; then
    echo "Error: $ENV_FILE not found."
    echo "Create it from .env.db.example:"
    echo "  cp .env.db.example .env.db"
    exit 1
fi

set -a
source "$ENV_FILE"
set +a

echo "==> Creating network..."
podman network create "$NETWORK_NAME" 2>/dev/null || true

echo "==> Creating volume..."
podman volume create "$DB_VOL_NAME" 2>/dev/null || true

echo "==> Creating pod..."
podman pod create \
    --name "$DB_POD_NAME" \
    -p "${DB_PORT}:5432" \
    --network "$NETWORK_NAME" \
    2>/dev/null || true

echo "==> Creating PostgreSQL container..."
podman run -d \
    --name "$DB_BOX_NAME" \
    --pod "$DB_POD_NAME" \
    --restart=always \
    -e POSTGRES_USER="$POSTGRES_USER" \
    -e POSTGRES_PASSWORD="$POSTGRES_PASSWORD" \
    -e POSTGRES_DB="$POSTGRES_DB" \
    -v "${DB_VOL_NAME}:/var/lib/postgresql" \
    "$DB_IMAGE"

echo
echo "PostgreSQL container created:"
echo "  Pod:       $DB_POD_NAME"
echo "  Container: $DB_BOX_NAME"
echo "  Database:  $POSTGRES_DB"
echo "  User:      $POSTGRES_USER"
echo "  Port:      $DB_PORT"
```

### Conceptos clave expuestos:
1. **Network (`podman network create`)**: Aísla la comunicación de red para esta instancia de aplicación.
2. **Volume (`podman volume create`)**: Garantiza la persistencia de los datos en la máquina anfitriona (Fedora), evitando pérdida de información al reiniciar o destruir contenedores.
3. **Pod (`podman pod create`)**: Agrupa uno o más contenedores bajo el mismo namespace de red. La exposición de puertos (`-p 5432:5432`) se realiza a nivel del Pod, no del contenedor individual.
4. **Container (`podman run --pod ...`)**: Lanza la base de datos dentro del Pod configurado.

---

## 3. Limpieza y Desmantelamiento (`teardown-db.sh`)

Un buen entorno local debe ser tan fácil de destruir como de construir. El script de desmantelamiento remueve el Pod y la red, manteniendo el volumen por seguridad para prevenir pérdidas accidentales de datos durante el desarrollo.

```bash
#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
ENV_FILE="$PROJECT_ROOT/.env.db"

if [[ ! -f "$ENV_FILE" ]]; then
    echo "Error: $ENV_FILE not found."
    echo "Create it from .env.db.example:"
    echo "  cp .env.db.example .env.db"
    exit 1
fi

set -a
source "$ENV_FILE"
set +a

echo "==> Removing PostgreSQL pod..."
podman pod rm -f "$DB_POD_NAME" 2>/dev/null || true

echo "==> Removing network..."
podman network rm "$NETWORK_NAME" 2>/dev/null || true

echo
echo "PostgreSQL container, pod and network removed."
echo "Volume preserved: $DB_VOL_NAME"
echo
echo "To remove the database data permanently:"
echo "  podman volume rm $DB_VOL_NAME"
```

---

## Flujo de Trabajo Diario

Para iniciar el entorno por primera vez:

```bash
# 1. Copiar las variables de entorno
cp .env.db.example .env.db

# darle al script permisos de ejecución
chmod +x ./scripts/podman/setup-db.sh
chmod +x ./scripts/podman/teardown-db.sh

# 2. Ejecutar el script de setup
./scripts/podman/setup-db.sh
```

Para reiniciar desde cero o apagar el entorno conservando la data:

```bash
./scripts/podman/teardown-db.sh
```

Si necesitas borrar completamente los datos de la base de datos:

```bash
podman volume rm clinicflow-db-data
```

## Conclusión

Integrar Podman junto con scripts en Bash sencillos permite gestionar dependencias locales en Linux sin sobrecargar la máquina de desarrollo ni depender de herramientas externas complejas. Este enfoque modular facilita el mantenimiento y permite adaptar rápidamente la infraestructura local para cualquier proyecto de API o backend.
