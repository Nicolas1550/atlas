# ATLAS V4 — Qué está probado y qué falta validar

## Ejecutado en el entorno de generación

- `node scripts/verify.mjs`: presencia de fuentes, migraciones y assets; sin secretos `.env.local`.
- `NODE_PATH=$(npm root -g) node scripts/syntax.mjs`: parseo TypeScript/TSX con el compilador global.
- `npm run test`: pruebas Node 22 de lógica de coincidencias sísmicas, autenticación del cron, contratos de autorización y migración no destructiva.
- ZIP inspeccionado tras empaquetado, sin `.env.local`, `node_modules` ni `.next`.

## No ejecutado aquí

- `npm ci` completo: el entorno de generación no dispone de todos los paquetes npm en caché ni acceso estable al registro.
- `npm run typecheck` y `npm run build`: requieren instalar las dependencias.
- Integración real con Neon, USGS o Vercel Cron: requiere credenciales privadas, acceso a red y despliegue del usuario.

**Antes de publicar**, ejecutá todos los comandos del README en tu PC y probá los flujos con Neon. Si alguno falla, no consideres la versión lista para producción.
