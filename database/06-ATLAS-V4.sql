-- ATLAS V4 · MIGRACIÓN INCREMENTAL PARA NEON
-- Ejecutar SOLO después de 04-ATLAS-V2.sql y 05-ATLAS-V3.sql.
-- Conservar la misma base de datos. No borra tablas ni filas existentes.
-- Seguro para repetir: IF NOT EXISTS y columnas nuevas opcionales.
BEGIN;

-- Un expediente puede incluir varios terremotos verificados por USGS.
CREATE TABLE IF NOT EXISTS investigation_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  investigation_id UUID NOT NULL REFERENCES investigations(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  earthquake_id VARCHAR(80) NOT NULL,
  title VARCHAR(220) NOT NULL,
  magnitude NUMERIC(4,1) NOT NULL,
  latitude DOUBLE PRECISION NOT NULL,
  longitude DOUBLE PRECISION NOT NULL,
  depth_km NUMERIC(8,2) NOT NULL,
  occurred_at TIMESTAMPTZ NOT NULL,
  usgs_url TEXT,
  note VARCHAR(1000) NOT NULL DEFAULT '',
  added_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT investigation_events_unique UNIQUE (investigation_id, earthquake_id)
);
CREATE INDEX IF NOT EXISTS investigation_events_owner_idx
  ON investigation_events (user_id, investigation_id, added_at DESC);

-- Estado auditable de las sincronizaciones automáticas.
CREATE TABLE IF NOT EXISTS sync_runs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  status VARCHAR(12) NOT NULL DEFAULT 'running'
    CHECK (status IN ('running', 'success', 'failed')),
  source VARCHAR(20) NOT NULL DEFAULT 'usgs-daily',
  scanned INTEGER NOT NULL DEFAULT 0,
  archived INTEGER NOT NULL DEFAULT 0,
  notifications_created INTEGER NOT NULL DEFAULT 0,
  rules_checked INTEGER NOT NULL DEFAULT 0,
  truncated BOOLEAN NOT NULL DEFAULT FALSE,
  started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  completed_at TIMESTAMPTZ
);
CREATE INDEX IF NOT EXISTS sync_runs_started_idx ON sync_runs (started_at DESC);

-- Límite de intentos de inicio de sesión; solo guarda HMAC, no correos.
CREATE TABLE IF NOT EXISTS auth_login_attempts (
  email_digest CHAR(64) PRIMARY KEY,
  attempts INTEGER NOT NULL DEFAULT 0,
  last_attempt TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  locked_until TIMESTAMPTZ
);
CREATE INDEX IF NOT EXISTS auth_login_attempts_last_idx
  ON auth_login_attempts (last_attempt);

-- Enlaces públicos de SOLO LECTURA para informes existentes.
ALTER TABLE generated_reports
  ADD COLUMN IF NOT EXISTS is_public BOOLEAN NOT NULL DEFAULT FALSE;
ALTER TABLE generated_reports
  ADD COLUMN IF NOT EXISTS share_token UUID;
CREATE UNIQUE INDEX IF NOT EXISTS generated_reports_share_token_idx
  ON generated_reports (share_token) WHERE share_token IS NOT NULL;

COMMIT;

-- Comprobación sin modificar datos.
SELECT table_name FROM information_schema.tables
WHERE table_schema = 'public' AND table_name IN
('investigation_events', 'sync_runs', 'auth_login_attempts')
ORDER BY table_name;
