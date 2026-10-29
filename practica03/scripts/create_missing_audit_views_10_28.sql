-- Vistas de trazabilidad faltantes segun backups/respaldo10_28.sql.
-- MySQL 8.0.36: 26 tablas, 25 de negocio; 13 vistas canonicas existentes, 12 faltantes.
-- tb_logs es el origen de auditoria y se excluye de las vistas por tabla.
-- Conserva cualquier tabla o vista que ya ocupe el nombre; no reemplaza objetos.
-- Requiere CREATE VIEW y SELECT sobre tb_logs y mysql.role_edges.
-- SQL SECURITY INVOKER: quien consulta necesita SELECT sobre ambos origenes.
-- Roles directos actuales agrupados por nombre, no historicos ni efectivos;
-- pueden mezclar cuentas homonimas de diferentes hosts.
-- No instala triggers, no genera eventos ni reconstruye operaciones anteriores.
-- record_id puede ser NULL si el texto del log no contiene ID=numero,.
-- Estas 12 tablas no tienen triggers en el respaldo del 28/10.
-- Ejecutar en una conexion autenticada a db_test, sin ignorar errores.
USE db_test;
SET NAMES utf8mb4;

-- vw_trazabilidad_tb_order_cancellations
SET @trazabilidad_sql = IF(
    EXISTS (SELECT 1 FROM information_schema.TABLES
            WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'vw_trazabilidad_tb_order_cancellations'),
    'SELECT ''Se conserva el objeto existente: vw_trazabilidad_tb_order_cancellations'' AS resultado',
    'CREATE SQL SECURITY INVOKER VIEW `vw_trazabilidad_tb_order_cancellations` AS
SELECT
    l.ID AS log_id,
    l.table_name,
    CASE
        WHEN l.description REGEXP ''ID=[0-9]+,'' THEN
            CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(l.description, '', datos='', 1), ''ID='', -1), '','', 1) AS UNSIGNED)
        ELSE NULL
    END AS record_id,
    l.operation,
    l.db_users AS db_user,
    SUBSTRING_INDEX(l.db_users, ''@'', 1) AS username,
    COALESCE((
        SELECT GROUP_CONCAT(DISTINCT re.FROM_USER ORDER BY re.FROM_USER SEPARATOR '', '')
        FROM mysql.role_edges AS re
        WHERE re.TO_USER = SUBSTRING_INDEX(l.db_users, ''@'', 1)
    ), ''Sin rol directo actual'') AS roles_actuales_por_nombre,
    l.description AS operation_description,
    l.operation_date,
    CAST(l.operation_status AS UNSIGNED) AS operation_status
FROM tb_logs AS l
WHERE l.table_name = ''tb_order_cancellations'''
);
PREPARE trazabilidad_stmt FROM @trazabilidad_sql;
EXECUTE trazabilidad_stmt;
DEALLOCATE PREPARE trazabilidad_stmt;

-- vw_trazabilidad_tb_payment_methods
SET @trazabilidad_sql = IF(
    EXISTS (SELECT 1 FROM information_schema.TABLES
            WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'vw_trazabilidad_tb_payment_methods'),
    'SELECT ''Se conserva el objeto existente: vw_trazabilidad_tb_payment_methods'' AS resultado',
    'CREATE SQL SECURITY INVOKER VIEW `vw_trazabilidad_tb_payment_methods` AS
SELECT
    l.ID AS log_id,
    l.table_name,
    CASE
        WHEN l.description REGEXP ''ID=[0-9]+,'' THEN
            CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(l.description, '', datos='', 1), ''ID='', -1), '','', 1) AS UNSIGNED)
        ELSE NULL
    END AS record_id,
    l.operation,
    l.db_users AS db_user,
    SUBSTRING_INDEX(l.db_users, ''@'', 1) AS username,
    COALESCE((
        SELECT GROUP_CONCAT(DISTINCT re.FROM_USER ORDER BY re.FROM_USER SEPARATOR '', '')
        FROM mysql.role_edges AS re
        WHERE re.TO_USER = SUBSTRING_INDEX(l.db_users, ''@'', 1)
    ), ''Sin rol directo actual'') AS roles_actuales_por_nombre,
    l.description AS operation_description,
    l.operation_date,
    CAST(l.operation_status AS UNSIGNED) AS operation_status
FROM tb_logs AS l
WHERE l.table_name = ''tb_payment_methods'''
);
PREPARE trazabilidad_stmt FROM @trazabilidad_sql;
EXECUTE trazabilidad_stmt;
DEALLOCATE PREPARE trazabilidad_stmt;

-- vw_trazabilidad_tb_payment_transaction
SET @trazabilidad_sql = IF(
    EXISTS (SELECT 1 FROM information_schema.TABLES
            WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'vw_trazabilidad_tb_payment_transaction'),
    'SELECT ''Se conserva el objeto existente: vw_trazabilidad_tb_payment_transaction'' AS resultado',
    'CREATE SQL SECURITY INVOKER VIEW `vw_trazabilidad_tb_payment_transaction` AS
SELECT
    l.ID AS log_id,
    l.table_name,
    CASE
        WHEN l.description REGEXP ''ID=[0-9]+,'' THEN
            CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(l.description, '', datos='', 1), ''ID='', -1), '','', 1) AS UNSIGNED)
        ELSE NULL
    END AS record_id,
    l.operation,
    l.db_users AS db_user,
    SUBSTRING_INDEX(l.db_users, ''@'', 1) AS username,
    COALESCE((
        SELECT GROUP_CONCAT(DISTINCT re.FROM_USER ORDER BY re.FROM_USER SEPARATOR '', '')
        FROM mysql.role_edges AS re
        WHERE re.TO_USER = SUBSTRING_INDEX(l.db_users, ''@'', 1)
    ), ''Sin rol directo actual'') AS roles_actuales_por_nombre,
    l.description AS operation_description,
    l.operation_date,
    CAST(l.operation_status AS UNSIGNED) AS operation_status
FROM tb_logs AS l
WHERE l.table_name = ''tb_payment_transaction'''
);
PREPARE trazabilidad_stmt FROM @trazabilidad_sql;
EXECUTE trazabilidad_stmt;
DEALLOCATE PREPARE trazabilidad_stmt;

-- vw_trazabilidad_tb_payments
SET @trazabilidad_sql = IF(
    EXISTS (SELECT 1 FROM information_schema.TABLES
            WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'vw_trazabilidad_tb_payments'),
    'SELECT ''Se conserva el objeto existente: vw_trazabilidad_tb_payments'' AS resultado',
    'CREATE SQL SECURITY INVOKER VIEW `vw_trazabilidad_tb_payments` AS
SELECT
    l.ID AS log_id,
    l.table_name,
    CASE
        WHEN l.description REGEXP ''ID=[0-9]+,'' THEN
            CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(l.description, '', datos='', 1), ''ID='', -1), '','', 1) AS UNSIGNED)
        ELSE NULL
    END AS record_id,
    l.operation,
    l.db_users AS db_user,
    SUBSTRING_INDEX(l.db_users, ''@'', 1) AS username,
    COALESCE((
        SELECT GROUP_CONCAT(DISTINCT re.FROM_USER ORDER BY re.FROM_USER SEPARATOR '', '')
        FROM mysql.role_edges AS re
        WHERE re.TO_USER = SUBSTRING_INDEX(l.db_users, ''@'', 1)
    ), ''Sin rol directo actual'') AS roles_actuales_por_nombre,
    l.description AS operation_description,
    l.operation_date,
    CAST(l.operation_status AS UNSIGNED) AS operation_status
FROM tb_logs AS l
WHERE l.table_name = ''tb_payments'''
);
PREPARE trazabilidad_stmt FROM @trazabilidad_sql;
EXECUTE trazabilidad_stmt;
DEALLOCATE PREPARE trazabilidad_stmt;

-- vw_trazabilidad_tb_people
SET @trazabilidad_sql = IF(
    EXISTS (SELECT 1 FROM information_schema.TABLES
            WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'vw_trazabilidad_tb_people'),
    'SELECT ''Se conserva el objeto existente: vw_trazabilidad_tb_people'' AS resultado',
    'CREATE SQL SECURITY INVOKER VIEW `vw_trazabilidad_tb_people` AS
SELECT
    l.ID AS log_id,
    l.table_name,
    CASE
        WHEN l.description REGEXP ''ID=[0-9]+,'' THEN
            CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(l.description, '', datos='', 1), ''ID='', -1), '','', 1) AS UNSIGNED)
        ELSE NULL
    END AS record_id,
    l.operation,
    l.db_users AS db_user,
    SUBSTRING_INDEX(l.db_users, ''@'', 1) AS username,
    COALESCE((
        SELECT GROUP_CONCAT(DISTINCT re.FROM_USER ORDER BY re.FROM_USER SEPARATOR '', '')
        FROM mysql.role_edges AS re
        WHERE re.TO_USER = SUBSTRING_INDEX(l.db_users, ''@'', 1)
    ), ''Sin rol directo actual'') AS roles_actuales_por_nombre,
    l.description AS operation_description,
    l.operation_date,
    CAST(l.operation_status AS UNSIGNED) AS operation_status
FROM tb_logs AS l
WHERE l.table_name = ''tb_people'''
);
PREPARE trazabilidad_stmt FROM @trazabilidad_sql;
EXECUTE trazabilidad_stmt;
DEALLOCATE PREPARE trazabilidad_stmt;

-- vw_trazabilidad_tb_products
SET @trazabilidad_sql = IF(
    EXISTS (SELECT 1 FROM information_schema.TABLES
            WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'vw_trazabilidad_tb_products'),
    'SELECT ''Se conserva el objeto existente: vw_trazabilidad_tb_products'' AS resultado',
    'CREATE SQL SECURITY INVOKER VIEW `vw_trazabilidad_tb_products` AS
SELECT
    l.ID AS log_id,
    l.table_name,
    CASE
        WHEN l.description REGEXP ''ID=[0-9]+,'' THEN
            CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(l.description, '', datos='', 1), ''ID='', -1), '','', 1) AS UNSIGNED)
        ELSE NULL
    END AS record_id,
    l.operation,
    l.db_users AS db_user,
    SUBSTRING_INDEX(l.db_users, ''@'', 1) AS username,
    COALESCE((
        SELECT GROUP_CONCAT(DISTINCT re.FROM_USER ORDER BY re.FROM_USER SEPARATOR '', '')
        FROM mysql.role_edges AS re
        WHERE re.TO_USER = SUBSTRING_INDEX(l.db_users, ''@'', 1)
    ), ''Sin rol directo actual'') AS roles_actuales_por_nombre,
    l.description AS operation_description,
    l.operation_date,
    CAST(l.operation_status AS UNSIGNED) AS operation_status
FROM tb_logs AS l
WHERE l.table_name = ''tb_products'''
);
PREPARE trazabilidad_stmt FROM @trazabilidad_sql;
EXECUTE trazabilidad_stmt;
DEALLOCATE PREPARE trazabilidad_stmt;

-- vw_trazabilidad_tb_refunds
SET @trazabilidad_sql = IF(
    EXISTS (SELECT 1 FROM information_schema.TABLES
            WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'vw_trazabilidad_tb_refunds'),
    'SELECT ''Se conserva el objeto existente: vw_trazabilidad_tb_refunds'' AS resultado',
    'CREATE SQL SECURITY INVOKER VIEW `vw_trazabilidad_tb_refunds` AS
SELECT
    l.ID AS log_id,
    l.table_name,
    CASE
        WHEN l.description REGEXP ''ID=[0-9]+,'' THEN
            CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(l.description, '', datos='', 1), ''ID='', -1), '','', 1) AS UNSIGNED)
        ELSE NULL
    END AS record_id,
    l.operation,
    l.db_users AS db_user,
    SUBSTRING_INDEX(l.db_users, ''@'', 1) AS username,
    COALESCE((
        SELECT GROUP_CONCAT(DISTINCT re.FROM_USER ORDER BY re.FROM_USER SEPARATOR '', '')
        FROM mysql.role_edges AS re
        WHERE re.TO_USER = SUBSTRING_INDEX(l.db_users, ''@'', 1)
    ), ''Sin rol directo actual'') AS roles_actuales_por_nombre,
    l.description AS operation_description,
    l.operation_date,
    CAST(l.operation_status AS UNSIGNED) AS operation_status
FROM tb_logs AS l
WHERE l.table_name = ''tb_refunds'''
);
PREPARE trazabilidad_stmt FROM @trazabilidad_sql;
EXECUTE trazabilidad_stmt;
DEALLOCATE PREPARE trazabilidad_stmt;

-- vw_trazabilidad_tb_returns
SET @trazabilidad_sql = IF(
    EXISTS (SELECT 1 FROM information_schema.TABLES
            WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'vw_trazabilidad_tb_returns'),
    'SELECT ''Se conserva el objeto existente: vw_trazabilidad_tb_returns'' AS resultado',
    'CREATE SQL SECURITY INVOKER VIEW `vw_trazabilidad_tb_returns` AS
SELECT
    l.ID AS log_id,
    l.table_name,
    CASE
        WHEN l.description REGEXP ''ID=[0-9]+,'' THEN
            CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(l.description, '', datos='', 1), ''ID='', -1), '','', 1) AS UNSIGNED)
        ELSE NULL
    END AS record_id,
    l.operation,
    l.db_users AS db_user,
    SUBSTRING_INDEX(l.db_users, ''@'', 1) AS username,
    COALESCE((
        SELECT GROUP_CONCAT(DISTINCT re.FROM_USER ORDER BY re.FROM_USER SEPARATOR '', '')
        FROM mysql.role_edges AS re
        WHERE re.TO_USER = SUBSTRING_INDEX(l.db_users, ''@'', 1)
    ), ''Sin rol directo actual'') AS roles_actuales_por_nombre,
    l.description AS operation_description,
    l.operation_date,
    CAST(l.operation_status AS UNSIGNED) AS operation_status
FROM tb_logs AS l
WHERE l.table_name = ''tb_returns'''
);
PREPARE trazabilidad_stmt FROM @trazabilidad_sql;
EXECUTE trazabilidad_stmt;
DEALLOCATE PREPARE trazabilidad_stmt;

-- vw_trazabilidad_tb_shipments
SET @trazabilidad_sql = IF(
    EXISTS (SELECT 1 FROM information_schema.TABLES
            WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'vw_trazabilidad_tb_shipments'),
    'SELECT ''Se conserva el objeto existente: vw_trazabilidad_tb_shipments'' AS resultado',
    'CREATE SQL SECURITY INVOKER VIEW `vw_trazabilidad_tb_shipments` AS
SELECT
    l.ID AS log_id,
    l.table_name,
    CASE
        WHEN l.description REGEXP ''ID=[0-9]+,'' THEN
            CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(l.description, '', datos='', 1), ''ID='', -1), '','', 1) AS UNSIGNED)
        ELSE NULL
    END AS record_id,
    l.operation,
    l.db_users AS db_user,
    SUBSTRING_INDEX(l.db_users, ''@'', 1) AS username,
    COALESCE((
        SELECT GROUP_CONCAT(DISTINCT re.FROM_USER ORDER BY re.FROM_USER SEPARATOR '', '')
        FROM mysql.role_edges AS re
        WHERE re.TO_USER = SUBSTRING_INDEX(l.db_users, ''@'', 1)
    ), ''Sin rol directo actual'') AS roles_actuales_por_nombre,
    l.description AS operation_description,
    l.operation_date,
    CAST(l.operation_status AS UNSIGNED) AS operation_status
FROM tb_logs AS l
WHERE l.table_name = ''tb_shipments'''
);
PREPARE trazabilidad_stmt FROM @trazabilidad_sql;
EXECUTE trazabilidad_stmt;
DEALLOCATE PREPARE trazabilidad_stmt;

-- vw_trazabilidad_tb_users
SET @trazabilidad_sql = IF(
    EXISTS (SELECT 1 FROM information_schema.TABLES
            WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'vw_trazabilidad_tb_users'),
    'SELECT ''Se conserva el objeto existente: vw_trazabilidad_tb_users'' AS resultado',
    'CREATE SQL SECURITY INVOKER VIEW `vw_trazabilidad_tb_users` AS
SELECT
    l.ID AS log_id,
    l.table_name,
    CASE
        WHEN l.description REGEXP ''ID=[0-9]+,'' THEN
            CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(l.description, '', datos='', 1), ''ID='', -1), '','', 1) AS UNSIGNED)
        ELSE NULL
    END AS record_id,
    l.operation,
    l.db_users AS db_user,
    SUBSTRING_INDEX(l.db_users, ''@'', 1) AS username,
    COALESCE((
        SELECT GROUP_CONCAT(DISTINCT re.FROM_USER ORDER BY re.FROM_USER SEPARATOR '', '')
        FROM mysql.role_edges AS re
        WHERE re.TO_USER = SUBSTRING_INDEX(l.db_users, ''@'', 1)
    ), ''Sin rol directo actual'') AS roles_actuales_por_nombre,
    l.description AS operation_description,
    l.operation_date,
    CAST(l.operation_status AS UNSIGNED) AS operation_status
FROM tb_logs AS l
WHERE l.table_name = ''tb_users'''
);
PREPARE trazabilidad_stmt FROM @trazabilidad_sql;
EXECUTE trazabilidad_stmt;
DEALLOCATE PREPARE trazabilidad_stmt;

-- vw_trazabilidad_tbd_cancellation_items
SET @trazabilidad_sql = IF(
    EXISTS (SELECT 1 FROM information_schema.TABLES
            WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'vw_trazabilidad_tbd_cancellation_items'),
    'SELECT ''Se conserva el objeto existente: vw_trazabilidad_tbd_cancellation_items'' AS resultado',
    'CREATE SQL SECURITY INVOKER VIEW `vw_trazabilidad_tbd_cancellation_items` AS
SELECT
    l.ID AS log_id,
    l.table_name,
    CASE
        WHEN l.description REGEXP ''ID=[0-9]+,'' THEN
            CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(l.description, '', datos='', 1), ''ID='', -1), '','', 1) AS UNSIGNED)
        ELSE NULL
    END AS record_id,
    l.operation,
    l.db_users AS db_user,
    SUBSTRING_INDEX(l.db_users, ''@'', 1) AS username,
    COALESCE((
        SELECT GROUP_CONCAT(DISTINCT re.FROM_USER ORDER BY re.FROM_USER SEPARATOR '', '')
        FROM mysql.role_edges AS re
        WHERE re.TO_USER = SUBSTRING_INDEX(l.db_users, ''@'', 1)
    ), ''Sin rol directo actual'') AS roles_actuales_por_nombre,
    l.description AS operation_description,
    l.operation_date,
    CAST(l.operation_status AS UNSIGNED) AS operation_status
FROM tb_logs AS l
WHERE l.table_name = ''tbd_cancellation_items'''
);
PREPARE trazabilidad_stmt FROM @trazabilidad_sql;
EXECUTE trazabilidad_stmt;
DEALLOCATE PREPARE trazabilidad_stmt;

-- vw_trazabilidad_tbd_return_items
SET @trazabilidad_sql = IF(
    EXISTS (SELECT 1 FROM information_schema.TABLES
            WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'vw_trazabilidad_tbd_return_items'),
    'SELECT ''Se conserva el objeto existente: vw_trazabilidad_tbd_return_items'' AS resultado',
    'CREATE SQL SECURITY INVOKER VIEW `vw_trazabilidad_tbd_return_items` AS
SELECT
    l.ID AS log_id,
    l.table_name,
    CASE
        WHEN l.description REGEXP ''ID=[0-9]+,'' THEN
            CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(l.description, '', datos='', 1), ''ID='', -1), '','', 1) AS UNSIGNED)
        ELSE NULL
    END AS record_id,
    l.operation,
    l.db_users AS db_user,
    SUBSTRING_INDEX(l.db_users, ''@'', 1) AS username,
    COALESCE((
        SELECT GROUP_CONCAT(DISTINCT re.FROM_USER ORDER BY re.FROM_USER SEPARATOR '', '')
        FROM mysql.role_edges AS re
        WHERE re.TO_USER = SUBSTRING_INDEX(l.db_users, ''@'', 1)
    ), ''Sin rol directo actual'') AS roles_actuales_por_nombre,
    l.description AS operation_description,
    l.operation_date,
    CAST(l.operation_status AS UNSIGNED) AS operation_status
FROM tb_logs AS l
WHERE l.table_name = ''tbd_return_items'''
);
PREPARE trazabilidad_stmt FROM @trazabilidad_sql;
EXECUTE trazabilidad_stmt;
DEALLOCATE PREPARE trazabilidad_stmt;
