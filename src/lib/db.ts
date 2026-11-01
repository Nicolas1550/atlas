import { neon } from '@neondatabase/serverless';

export function isDatabaseConfigured() {
  const value = process.env.DATABASE_URL;
  return Boolean(value && value.startsWith('postgres') && !value.includes('USUARIO:CONTRASENA'));
}

export function getDb() {
  const url = process.env.DATABASE_URL;
  if (!isDatabaseConfigured() || !url) {
    throw new Error('DATABASE_URL no configurada. Revisá .env.local.');
  }
  return neon(url);
}
