-- ATLAS V3 · MIGRACION INCREMENTAL / Neon PostgreSQL
-- Ejecutar en la misma base 'neondb' DESPUES de 04-ATLAS-V2.sql.
-- No altera ni elimina tablas, usuarios, favoritos o investigaciones existentes.
-- Reejecutable: CREATE ... IF NOT EXISTS.

BEGIN;

CREATE TABLE IF NOT EXISTS alert_rules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  name VARCHAR(80) NOT NULL,
  region_id VARCHAR(40) NOT NULL DEFAULT 'global',
  min_magnitude NUMERIC(3,1) NOT NULL DEFAULT 5.0 CHECK (min_magnitude BETWEEN 0 AND 9),
  max_depth_km NUMERIC(8,2) CHECK (max_depth_km IS NULL OR max_depth_km BETWEEN 0 AND 800),
  is_enabled BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS alert_rules_user_idx ON alert_rules (user_id, created_at DESC);

CREATE TABLE IF NOT EXISTS notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  rule_id UUID REFERENCES alert_rules(id) ON DELETE SET NULL,
  earthquake_id VARCHAR(80) NOT NULL,
  title VARCHAR(220) NOT NULL,
  magnitude NUMERIC(4,1) NOT NULL,
  occurred_at TIMESTAMPTZ NOT NULL,
  is_read BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT notifications_unique_rule_event UNIQUE (user_id, rule_id, earthquake_id)
);
CREATE INDEX IF NOT EXISTS notifications_user_idx ON notifications (user_id, is_read, created_at DESC);

CREATE TABLE IF NOT EXISTS earthquake_history (
  earthquake_id VARCHAR(80) PRIMARY KEY,
  title VARCHAR(220) NOT NULL,
  magnitude NUMERIC(4,1) NOT NULL,
  latitude DOUBLE PRECISION NOT NULL,
  longitude DOUBLE PRECISION NOT NULL,
  depth_km NUMERIC(8,2) NOT NULL,
  occurred_at TIMESTAMPTZ NOT NULL,
  usgs_url TEXT,
  fetched_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS earthquake_history_occurred_idx ON earthquake_history (occurred_at DESC);

CREATE TABLE IF NOT EXISTS generated_reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title VARCHAR(100) NOT NULL,
  source VARCHAR(12) NOT NULL CHECK (source IN ('usgs', 'demo')),
  event_count INTEGER NOT NULL CHECK (event_count BETWEEN 0 AND 10000),
  max_magnitude NUMERIC(4,1),
  summary JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS generated_reports_user_idx ON generated_reports (user_id, created_at DESC);

CREATE TABLE IF NOT EXISTS user_preferences (
  user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  default_region_id VARCHAR(40) NOT NULL DEFAULT 'global',
  min_magnitude NUMERIC(3,1) NOT NULL DEFAULT 2.5 CHECK (min_magnitude BETWEEN 0 AND 9),
  default_period VARCHAR(8) NOT NULL DEFAULT 'day' CHECK (default_period IN ('day', 'week')),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMIT;

-- Solo lectura: confirma las 5 tablas nuevas sin exponer datos privados.
SELECT table_name FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name IN ('alert_rules','notifications','earthquake_history','generated_reports','user_preferences')
ORDER BY table_name;
