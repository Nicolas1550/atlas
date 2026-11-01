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
