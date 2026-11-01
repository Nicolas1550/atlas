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
