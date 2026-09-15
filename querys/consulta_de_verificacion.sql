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
