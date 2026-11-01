-- ATLAS V2: migración incremental para Research Desk.
-- Ejecutar UNA VEZ en el SQL Editor del MISMO proyecto Neon que ya usás.
-- NO borra usuarios, favoritos, regiones ni otros datos existentes.
-- Seguro para reejecutar: IF NOT EXISTS.

CREATE TABLE IF NOT EXISTS investigations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title VARCHAR(100) NOT NULL,
  notes VARCHAR(2000) NOT NULL DEFAULT '',
  period VARCHAR(8) NOT NULL DEFAULT 'day' CHECK (period IN ('day', 'week')),
  region_id VARCHAR(40) NOT NULL DEFAULT 'global',
  min_magnitude NUMERIC(3,1) NOT NULL DEFAULT 2.5 CHECK (min_magnitude BETWEEN 0 AND 9),
  search_term VARCHAR(120) NOT NULL DEFAULT '',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS investigations_user_created_idx
  ON investigations (user_id, created_at DESC);

-- Comprobar que existe la tabla sin ver datos privados:
SELECT table_name FROM information_schema.tables
WHERE table_schema = 'public' AND table_name = 'investigations';
