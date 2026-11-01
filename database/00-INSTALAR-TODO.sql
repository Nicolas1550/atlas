-- ATLAS: INSTALACIÓN COMPLETA EN UN SOLO PASO
-- Copiá este archivo entero en Neon > SQL Editor y ejecutá Run.
-- No hace falta ejecutar 01 ni 02 si usás este archivo.

-- ATLAS Earth Intelligence / PostgreSQL 15+ / Neon
-- Ejecutar una sola vez desde Neon -> SQL Editor.
-- No borra datos existentes. Seguro volver a ejecutar la creación de tablas.

CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  display_name VARCHAR(60) NOT NULL,
  email VARCHAR(254) NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS favorites (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  earthquake_id VARCHAR(80) NOT NULL,
  title TEXT NOT NULL,
  magnitude NUMERIC(4,1) NOT NULL,
  latitude DOUBLE PRECISION NOT NULL,
  longitude DOUBLE PRECISION NOT NULL,
  depth_km NUMERIC(8,2) NOT NULL,
  occurred_at TIMESTAMPTZ NOT NULL,
  usgs_url TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT favorites_unique_event UNIQUE (user_id, earthquake_id)
);

CREATE INDEX IF NOT EXISTS favorites_user_created_idx
  ON favorites (user_id, created_at DESC);

CREATE TABLE IF NOT EXISTS regions (
  id VARCHAR(40) PRIMARY KEY,
  name VARCHAR(80) NOT NULL,
  min_lat DOUBLE PRECISION NOT NULL,
  max_lat DOUBLE PRECISION NOT NULL,
  min_lon DOUBLE PRECISION NOT NULL,
  max_lon DOUBLE PRECISION NOT NULL,
  CONSTRAINT regions_lat_valid CHECK (min_lat >= -90 AND max_lat <= 90 AND min_lat < max_lat),
  CONSTRAINT regions_lon_valid CHECK (min_lon >= -180 AND max_lon <= 180 AND min_lon < max_lon)
);

-- No hay usuarios precargados: se crean desde la pantalla Registro.
-- Las contraseñas solo se almacenan como hash bcrypt.


-- ATLAS / regiones iniciales de ejemplo.
-- Ejecutar DESPUÉS de 01-schema.sql.
-- Es idempotente: podés ejecutarlo varias veces sin duplicados.
INSERT INTO regions (id, name, min_lat, max_lat, min_lon, max_lon) VALUES
  ('global', 'Todo el planeta', -89.9, 89.9, -179.9, 179.9),
  ('south-america', 'Sudamérica', -56.0, 13.0, -82.0, -34.0),
  ('north-america', 'Norteamérica', 5.0, 72.0, -168.0, -52.0),
  ('europe', 'Europa', 34.0, 72.0, -12.0, 45.0),
  ('asia-pacific', 'Asia / Pacífico', -48.0, 60.0, 95.0, 179.9),
  ('japan', 'Japón', 24.0, 46.0, 123.0, 147.0)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  min_lat = EXCLUDED.min_lat,
  max_lat = EXCLUDED.max_lat,
  min_lon = EXCLUDED.min_lon,
  max_lon = EXCLUDED.max_lon;
