use db_test;

SHOW TABLES;
SHOW TRIGGERS FROM db_test;
SELECT * FROM tb_users;
SELECT * FROM tb_logs;

SELECT user, host FROM mysql.user WHERE host="%";



select
	FROM_USER AS rol,
    FROM_HOST AS Host_Rol,
    TO_USER AS Usuario,
    TO_HOST AS Host_Usuario
FROM mysql.role_edges
ORDER BY FROM_USER, TO_USER;

-- Consulta para saber qué usuario de la plataforma ecommerce realizó la acción, incluyendo el rol del SGBD
SELECT  u.nickname, u.email, b.db_users AS inserted_by,
        GROUP_CONCAT( DISTINCT re.FROM_USER ORDER BY re.FROM_USER SEPARATOR ', ' ) AS roles,
        b.description AS operation_description, b.operation_date
FROM tb_users u
JOIN tb_logs b
    ON b.description LIKE CONCAT('%', u.nickname, '%')
    AND b.description LIKE CONCAT('%', u.email, '%')
LEFT JOIN mysql.role_edges re
    ON re.TO_USER = SUBSTRING_INDEX(b.db_users, '@', 1)
WHERE b.operation = 'Create'
  AND b.table_name = 'tb_users'
GROUP BY u.nickname, u.email, b.db_users, b.description, b.operation_date
ORDER BY b.operation_date ASC;