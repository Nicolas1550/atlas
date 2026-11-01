-- ATLAS / ejecutar para comprobar que las tablas existen
SELECT 'users' AS tabla, COUNT(*) AS registros FROM users
UNION ALL SELECT 'favorites', COUNT(*) FROM favorites
UNION ALL SELECT 'regions', COUNT(*) FROM regions;

-- Ver regiones cargadas
SELECT id, name FROM regions ORDER BY name;
