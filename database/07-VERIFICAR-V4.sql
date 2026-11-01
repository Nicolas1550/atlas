-- Consultas de SOLO LECTURA para comprobar ATLAS V4.
SELECT table_name FROM information_schema.tables
WHERE table_schema='public' AND table_name IN
('users','favorites','investigations','investigation_events','alert_rules',
 'notifications','earthquake_history','generated_reports','sync_runs','auth_login_attempts')
ORDER BY table_name;

SELECT COUNT(*) AS total_investigaciones FROM investigations;
SELECT COUNT(*) AS total_favoritos FROM favorites;
SELECT COUNT(*) AS eventos_vinculados FROM investigation_events;
SELECT COUNT(*) AS eventos_archivados FROM earthquake_history;
SELECT status, scanned, archived, notifications_created, started_at
FROM sync_runs ORDER BY started_at DESC LIMIT 5;
