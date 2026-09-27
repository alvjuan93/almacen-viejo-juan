# Depósito HyN — entrega Docker portable

Esta carpeta contiene todo lo necesario para ejecutar el catálogo. La web, las fotos, los estilos, los datos públicos del catálogo y la configuración de Nginx quedan incorporados dentro de la imagen Docker.

No requiere base de datos, volúmenes, variables de entorno ni servicios externos. El carrito se conserva en el navegador del visitante.

## Archivos

- `compose.yaml`: servicio listo para Docker Compose y Dokploy.
- `Dockerfile`: construye la imagen autocontenida.
- `nginx.conf`: sirve la web por el puerto interno `8080`.
- `web/`: sitio completo y las imágenes utilizadas.

## Ejecutar localmente

```powershell
docker compose -f compose.yaml -f compose.local.yaml up --build -d
```

Abrir `http://localhost:8080`.

Para usar otro puerto del servidor:

```powershell
$env:WEB_PORT=8090
docker compose -f compose.yaml -f compose.local.yaml up --build -d
```

## Subir a Dokploy

1. Crear un servicio de tipo **Docker Compose**.
2. Subir esta carpeta completa o conectarla mediante un repositorio.
3. Usar solamente `compose.yaml` como archivo Compose. `compose.local.yaml` es exclusivo para pruebas en una PC.
4. Para un dominio gestionado por Dokploy, seleccionar el servicio `deposito-hyn` y el puerto interno `8080`.
5. No crear variables de entorno ni volúmenes para esta versión.

## Publicar cambios con control previo

Después de probar los cambios localmente:

```powershell
.\publicar.ps1 -Mensaje "Descripción breve del cambio"
```

Si Docker está disponible, el script valida el Compose y construye la imagen. En esta PC Docker no está instalado, por lo que Dokploy hará esa validación y construcción. El script siempre muestra los cambios y solo crea el commit y lo envía cuando se escribe exactamente `PUBLICAR`. El `push` a `main` activa el despliegue automático en Dokploy.

El relevamiento y el orden de endurecimiento del servidor están en `RELEVAMIENTO-ZEUS.md`.

## Migrar a otro proveedor

Copiar la carpeta completa al nuevo servidor y ejecutar `docker compose up --build -d`. La imagen resultante contiene todos los datos necesarios para mostrar la web.

## Datos del pedido

La web calcula una seña estimada del 30% y abre WhatsApp con el detalle. No valida transferencias automáticamente: el comercio debe confirmar el comprobante, el stock y el precio antes de preparar el pedido.
