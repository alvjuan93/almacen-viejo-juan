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

## Migrar a otro proveedor

Copiar la carpeta completa al nuevo servidor y ejecutar `docker compose up --build -d`. La imagen resultante contiene todos los datos necesarios para mostrar la web.

## Datos del pedido

La web calcula una seña estimada del 30% y abre WhatsApp con el detalle. No valida transferencias automáticamente: el comercio debe confirmar el comprobante, el stock y el precio antes de preparar el pedido.
