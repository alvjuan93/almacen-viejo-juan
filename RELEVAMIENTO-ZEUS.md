# Relevamiento de Zeus y publicación de Depósito HyN

Fecha del relevamiento: 27 de septiembre de 2026.

Este documento no contiene contraseñas, claves, tokens, correos privados ni direcciones públicas completas. Está pensado para guardarse y poder pegarse en otra conversación como contexto técnico.

## Resumen ejecutivo

- La tienda **Depósito HyN** está desplegada en Dokploy como un servicio Docker Compose y responde correctamente.
- Acceso interno verificado: `http://almacen-viejo-juan.192.168.1.105.traefik.me`.
- El contenedor está saludable y expone solamente el puerto interno `8080/tcp`.
- La aplicación no usa base de datos ni volúmenes persistentes. El sitio y sus imágenes quedan incorporados en la imagen Docker.
- GitHub está conectado, la rama de producción es `main`, el despliegue automático por cada `push` está activado y Dokploy usa `./compose.yaml`.
- El dominio `zeuslab.com.ar` está registrado y delegado a Cloudflare, pero al cierre de este relevamiento Cloudflare todavía esperaba la propagación de los servidores de nombres.
- No se publicó aún la tienda en Internet. La arquitectura recomendada es Cloudflare Tunnel hacia Dokploy, sin abrir puertos en el router.

## Inventario comprobado

### Servidor y Dokploy

- Un único nodo Docker Swarm, activo, líder y con TLS del clúster disponible.
- Motor Docker 29.5.3.
- Dokploy instalado: `v0.29.11`.
- Dokploy informa que hay una actualización disponible.
- Solo existe un usuario propietario en Dokploy.
- La consola de Dokploy funciona por HTTP dentro de la red local.
- El puerto de administración `3000` responde dentro de la red local.
- No hay servidores remotos agregados.
- No hay claves SSH cargadas en Dokploy.
- No hay registros privados de Docker configurados.
- No hay destinos S3 configurados y, por lo tanto, no existen copias de seguridad automáticas de Dokploy.
- No hay certificados personalizados cargados.
- No hay notificaciones configuradas.
- Los registros de auditoría completos requieren la edición Enterprise y no están disponibles en la instalación actual.

### Aplicación Depósito HyN

- Proyecto: **Almacen HyN**.
- Entorno: **production**.
- Servicio Compose: **Almacen Viejo Juan**.
- Repositorio privado: `alvjuan93/almacen-viejo-juan`.
- Rama: `main`.
- Ruta Compose: `./compose.yaml`.
- Disparador: `On Push`.
- Autodeploy: activado.
- Servicio interno: `deposito-hyn:8080`.
- Contenedor: saludable.
- Dominio local creado y validado mediante un redespliegue controlado.
- No hay puertos del contenedor publicados directamente al anfitrión en el archivo de producción.
- Sistema de archivos del contenedor en solo lectura.
- `no-new-privileges` activado.
- Directorios temporales montados como `tmpfs`.
- Healthcheck HTTP activo.
- No contiene secretos ni necesita variables de entorno.

## Superficie de red observada desde la PC local

- Respondieron en la red local: SSH `22`, HTTP `80`, HTTPS `443` y panel Dokploy `3000`.
- No respondieron: `53`, `8080`, `8443`, `9000` y `9443`.
- Esta comprobación se hizo desde la LAN. No demuestra por sí sola qué puertos están publicados en Internet ni reemplaza la revisión del router o firewall.

## Hallazgos de seguridad

### Prioridad crítica

1. **Actualizar Dokploy después de crear y probar una copia de seguridad.** La versión instalada es anterior a correcciones de seguridad publicadas en versiones posteriores. No actualizar sin respaldo y procedimiento de recuperación.
2. **Activar 2FA en la cuenta propietaria.** Actualmente está desactivado. El propietario debe escanear el QR y guardar los códigos de recuperación fuera del servidor y del repositorio.
3. **Configurar copias de seguridad externas.** No hay destino S3. Se recomienda Cloudflare R2 o Backblaze B2 para respaldar la base PostgreSQL de Dokploy y `/etc/dokploy`.
4. **No exponer el panel de Dokploy a Internet.** Mantener el puerto `3000` limitado a LAN/VPN. Para sitios públicos utilizar Cloudflare Tunnel.

### Prioridad alta

1. Verificar en el sistema operativo actualizaciones automáticas de seguridad.
2. Verificar que SSH use claves, que el ingreso por contraseña esté deshabilitado y que `root` no pueda iniciar sesión directamente.
3. Instalar/configurar Fail2Ban o CrowdSec si todavía no existe.
4. Revisar el firewall del host teniendo en cuenta que Docker puede eludir reglas UFW normales; usar reglas compatibles con Docker.
5. Confirmar en el router/firewall que no haya redirecciones públicas innecesarias ni UPnP habilitado para el servidor.
6. Configurar rotación de registros de Docker y, si corresponde, `live-restore`.

Estos puntos del sistema operativo quedaron **pendientes de comprobación** porque esta PC no tiene acceso SSH por clave a Zeus. No se debe asumir que están mal o bien hasta ingresar al host.

### Prioridad media

- La cuenta tenía una credencial temporal de API/CLI próxima a vencer. Dejar que expire y después confirmar que ya no aparezca; eliminarla manualmente si siguiera activa.
- Quitar las variables heredadas `NODE_ENV` y `PORT` del panel del Compose si se confirma que no son usadas. El `compose.yaml` actual no las consume.
- Mantener el aislamiento de cada futura web: un Compose por proyecto, sin `ports:` públicos, con `expose`, `read_only`, `tmpfs`, `no-new-privileges` y healthcheck.

## Arquitectura de publicación recomendada

```text
Visitante -> Cloudflare (DNS, HTTPS, WAF básico, caché)
          -> Cloudflare Tunnel saliente desde Zeus
          -> servicio deposito-hyn:8080 en la red Docker
```

Ventajas:

- No exige IP pública fija.
- No requiere abrir `80`, `443`, `3000` ni `8080` en el router para Internet.
- Certificado HTTPS automático en Cloudflare.
- Oculta la IP de origen y permite reglas gratuitas de seguridad y caché.
- Facilita migrar Zeus a otro proveedor: se mueve el Compose y se cambia el destino del túnel.

Nombre público recomendado: `almacen.zeuslab.com.ar`. El dominio raíz `zeuslab.com.ar` puede redirigir allí más adelante.

El token de Cloudflare Tunnel debe guardarse únicamente como secreto/variable protegida en Dokploy. Nunca debe entrar en GitHub, archivos Markdown, capturas ni mensajes.

## Flujo local a producción

1. Editar y probar en la PC con `compose.yaml` + `compose.local.yaml`.
2. Revisar la web en computadora y en vista móvil.
3. Ejecutar `./publicar.ps1 -Mensaje "descripción del cambio"`.
4. El script muestra los cambios, pide una confirmación explícita y recién entonces crea el commit y hace `push`. Si Docker estuviera disponible también valida y construye localmente; en esta PC esa construcción la realiza Dokploy.
5. Dokploy recibe el `push`, reconstruye la imagen y reemplaza el contenedor.
6. Verificar healthcheck, registro del despliegue y página pública.

## Estado y próximos pasos seguros

1. Esperar activación de los NS en Cloudflare.
2. Activar 2FA con Juan presente.
3. Crear destino de backup y obtener una copia restaurable.
4. Actualizar Dokploy a la versión estable actual y verificar todos los servicios.
5. Obtener acceso SSH por clave y completar la auditoría del host.
6. Crear Cloudflare Tunnel y publicar `almacen.zeuslab.com.ar`.
7. Probar desde datos móviles, revisar HTTPS, encabezados, imágenes, carrito y WhatsApp.

## Referencias oficiales

- Endurecimiento de Dokploy: https://docs.dokploy.com/docs/core/guides/production-hardening
- Copias de seguridad de Dokploy: https://docs.dokploy.com/docs/core/backups
- Cloudflare Tunnel con Dokploy: https://docs.dokploy.com/docs/core/guides/cloudflare-tunnels
- Versiones de Dokploy: https://github.com/Dokploy/dokploy/releases
- Documentación de Cloudflare Tunnel: https://developers.cloudflare.com/tunnel/
