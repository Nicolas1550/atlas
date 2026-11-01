# ATLAS — API Backend

Todas las rutas son relativas a `http://localhost:3000`.

| Método | Endpoint | Descripción | Sesión |
|---|---|---|---|
| GET | `/api/health` | Estado de la app y DB | No |
| GET | `/api/earthquakes?range=day` | Eventos USGS 24 h | No |
| GET | `/api/earthquakes?range=week` | Eventos USGS 7 días | No |
| GET | `/api/regions` | Regiones de PostgreSQL o fallback | No |
| POST | `/api/auth/register` | Registrar cuenta | No |
| POST | `/api/auth/login` | Iniciar sesión | No |
| GET | `/api/auth/me` | Usuario autenticado | Sí |
| POST | `/api/auth/logout` | Cerrar sesión | Sí |
| GET | `/api/favorites` | Listar favoritos del usuario | Sí |
| POST | `/api/favorites` | Guardar evento USGS | Sí |
| DELETE | `/api/favorites/:id` | Eliminar favorito | Sí |

## Registrar usuario

```json
POST /api/auth/register
Content-Type: application/json

{"name":"Ejemplo","email":"ejemplo@correo.com","password":"clave-larga-de-ejemplo"}
```

La respuesta crea una cookie de sesión HTTP-only. No almacenes contraseñas en el frontend.

## Guardar favorito

```json
POST /api/favorites
Content-Type: application/json

{
  "id":"us00000000",
  "title":"Evento de ejemplo",
  "magnitude":4.8,
  "latitude":-32.1,
  "longitude":-71.2,
  "depth":25,
  "time":1760000000000,
  "url":"https://earthquake.usgs.gov/"
}
```

Este JSON es solo una **muestra de estructura**, no un evento sísmico real. El botón Guardar del frontend envía los datos obtenidos de USGS.

## Base de datos

El cliente PostgreSQL `@neondatabase/serverless` se ejecuta **solo en backend**. Todas las consultas usan parámetros seguros con tagged templates. `DATABASE_URL` y `JWT_SECRET` nunca deben tener el prefijo `NEXT_PUBLIC_`.

## Notas de seguridad

- bcrypt con costo 12 para contraseñas.
- JWT firmado HS256 en cookie HTTP-only, SameSite Lax, Secure en producción.
- Acceso a favoritos limitado al usuario de la sesión.
- No se expone el hash de contraseña.
- Para una app pública con usuarios reales faltan: verificación de correo, recuperación de contraseña, limitación distribuida de solicitudes, controles de abuso y pruebas de seguridad.

## ATLAS V4 — nuevas rutas

| Método | Ruta | Autenticación | Función |
|---|---|---|---|
| `GET` | `/api/cron/sync` | `Authorization: Bearer CRON_SECRET` | Sincroniza USGS, archiva M4+ y evalúa reglas globales (tarea diaria) |
| `GET` | `/api/sync/status` | Pública (solo métricas) | Última ejecución del cron |
| `GET` | `/api/archive?start=YYYY-MM-DD&end=YYYY-MM-DD&mag=4` | Pública | Consulta read-only de eventos USGS previamente archivados en Neon |
| `GET` | `/api/investigations/:id/events` | Sesión + propiedad | Eventos vinculados a la investigación |
| `POST` | `/api/investigations/:id/events` | Sesión + propiedad | Vincula ID USGS verificado (`{ "earthquakeId": "us..." }`) |
| `PATCH` | `/api/investigations/:id/events/:eventId` | Sesión + propiedad | Actualiza `{ "note": "..." }` |
| `DELETE` | `/api/investigations/:id/events/:eventId` | Sesión + propiedad | Desvincula evento |
| `PATCH` | `/api/investigations/:id` | Sesión + propiedad | Actualiza título y notas generales |
| `PATCH` | `/api/reports/:id/share` | Sesión + propiedad | Publica/revoca enlace (`{ "enabled": true/false }`) |
| `GET` | `/report/:token` | Pública si se compartió | Informe estadístico de solo lectura |

**Privacidad:** todas las rutas de escritura usan el usuario autenticado. El endpoint público del informe no expone nombres, emails, favoritos ni investigaciones. `CRON_SECRET` nunca debe aparecer en frontend ni GitHub.
