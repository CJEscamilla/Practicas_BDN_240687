-- Una vista de trazabilidad por cada tabla solicitada (13 vistas).
-- MySQL 8.0.36. Ejecutar tras crear tablas y triggers.
-- Reejecutable: crea solo vistas faltantes y conserva los objetos existentes.
-- SQL SECURITY INVOKER: el consultante necesita SELECT sobre tb_logs y
-- mysql.role_edges. No se conceden permisos automaticamente.
-- roles_actuales_por_nombre agrupa roles directos actuales por nombre de cuenta;
-- no reconstruye roles historicos, activos o heredados ni distingue cuentas
-- homonimas de diferentes hosts. USER() en el log identifica la conexion.
-- ID se extrae del prefijo 'ID=..., datos=' escrito por los nuevos triggers.
USE db_test;
SET NAMES utf8mb4;

-- Crear solo si el nombre no esta ocupado; conservar objetos existentes.
SET @trazabilidad_sql = IF(
    EXISTS (SELECT 1 FROM information_schema.TABLES
            WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'vw_trazabilidad_tbc_categories'),
    'SELECT ''Se conserva el objeto existente: vw_trazabilidad_tbc_categories'' AS resultado',
    'CREATE SQL SECURITY INVOKER VIEW `vw_trazabilidad_tbc_categories` AS
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
WHERE l.table_name = ''tbc_categories'''
);
PREPARE trazabilidad_stmt FROM @trazabilidad_sql;
EXECUTE trazabilidad_stmt;
DEALLOCATE PREPARE trazabilidad_stmt;

-- Crear solo si el nombre no esta ocupado; conservar objetos existentes.
SET @trazabilidad_sql = IF(
    EXISTS (SELECT 1 FROM information_schema.TABLES
            WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'vw_trazabilidad_tbc_payment_methods_types'),
    'SELECT ''Se conserva el objeto existente: vw_trazabilidad_tbc_payment_methods_types'' AS resultado',
    'CREATE SQL SECURITY INVOKER VIEW `vw_trazabilidad_tbc_payment_methods_types` AS
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
WHERE l.table_name = ''tbc_payment_methods_types'''
);
PREPARE trazabilidad_stmt FROM @trazabilidad_sql;
EXECUTE trazabilidad_stmt;
DEALLOCATE PREPARE trazabilidad_stmt;

-- Crear solo si el nombre no esta ocupado; conservar objetos existentes.
SET @trazabilidad_sql = IF(
    EXISTS (SELECT 1 FROM information_schema.TABLES
            WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'vw_trazabilidad_tbc_order_items'),
    'SELECT ''Se conserva el objeto existente: vw_trazabilidad_tbc_order_items'' AS resultado',
    'CREATE SQL SECURITY INVOKER VIEW `vw_trazabilidad_tbc_order_items` AS
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
WHERE l.table_name = ''tbc_order_items'''
);
PREPARE trazabilidad_stmt FROM @trazabilidad_sql;
EXECUTE trazabilidad_stmt;
DEALLOCATE PREPARE trazabilidad_stmt;

-- Crear solo si el nombre no esta ocupado; conservar objetos existentes.
SET @trazabilidad_sql = IF(
    EXISTS (SELECT 1 FROM information_schema.TABLES
            WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'vw_trazabilidad_tbc_carts_items'),
    'SELECT ''Se conserva el objeto existente: vw_trazabilidad_tbc_carts_items'' AS resultado',
    'CREATE SQL SECURITY INVOKER VIEW `vw_trazabilidad_tbc_carts_items` AS
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
WHERE l.table_name = ''tbc_carts_items'''
);
PREPARE trazabilidad_stmt FROM @trazabilidad_sql;
EXECUTE trazabilidad_stmt;
DEALLOCATE PREPARE trazabilidad_stmt;

-- Crear solo si el nombre no esta ocupado; conservar objetos existentes.
SET @trazabilidad_sql = IF(
    EXISTS (SELECT 1 FROM information_schema.TABLES
            WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'vw_trazabilidad_tb_user_addresses'),
    'SELECT ''Se conserva el objeto existente: vw_trazabilidad_tb_user_addresses'' AS resultado',
    'CREATE SQL SECURITY INVOKER VIEW `vw_trazabilidad_tb_user_addresses` AS
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
WHERE l.table_name = ''tb_user_addresses'''
);
PREPARE trazabilidad_stmt FROM @trazabilidad_sql;
EXECUTE trazabilidad_stmt;
DEALLOCATE PREPARE trazabilidad_stmt;

-- Crear solo si el nombre no esta ocupado; conservar objetos existentes.
SET @trazabilidad_sql = IF(
    EXISTS (SELECT 1 FROM information_schema.TABLES
            WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'vw_trazabilidad_tbd_user_payment_methods'),
    'SELECT ''Se conserva el objeto existente: vw_trazabilidad_tbd_user_payment_methods'' AS resultado',
    'CREATE SQL SECURITY INVOKER VIEW `vw_trazabilidad_tbd_user_payment_methods` AS
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
WHERE l.table_name = ''tbd_user_payment_methods'''
);
PREPARE trazabilidad_stmt FROM @trazabilidad_sql;
EXECUTE trazabilidad_stmt;
DEALLOCATE PREPARE trazabilidad_stmt;

-- Crear solo si el nombre no esta ocupado; conservar objetos existentes.
SET @trazabilidad_sql = IF(
    EXISTS (SELECT 1 FROM information_schema.TABLES
            WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'vw_trazabilidad_tb_carts'),
    'SELECT ''Se conserva el objeto existente: vw_trazabilidad_tb_carts'' AS resultado',
    'CREATE SQL SECURITY INVOKER VIEW `vw_trazabilidad_tb_carts` AS
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
WHERE l.table_name = ''tb_carts'''
);
PREPARE trazabilidad_stmt FROM @trazabilidad_sql;
EXECUTE trazabilidad_stmt;
DEALLOCATE PREPARE trazabilidad_stmt;

-- Crear solo si el nombre no esta ocupado; conservar objetos existentes.
SET @trazabilidad_sql = IF(
    EXISTS (SELECT 1 FROM information_schema.TABLES
            WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'vw_trazabilidad_tb_buyer_orders'),
    'SELECT ''Se conserva el objeto existente: vw_trazabilidad_tb_buyer_orders'' AS resultado',
    'CREATE SQL SECURITY INVOKER VIEW `vw_trazabilidad_tb_buyer_orders` AS
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
WHERE l.table_name = ''tb_buyer_orders'''
);
PREPARE trazabilidad_stmt FROM @trazabilidad_sql;
EXECUTE trazabilidad_stmt;
DEALLOCATE PREPARE trazabilidad_stmt;

-- Crear solo si el nombre no esta ocupado; conservar objetos existentes.
SET @trazabilidad_sql = IF(
    EXISTS (SELECT 1 FROM information_schema.TABLES
            WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'vw_trazabilidad_tbd_order_itemes'),
    'SELECT ''Se conserva el objeto existente: vw_trazabilidad_tbd_order_itemes'' AS resultado',
    'CREATE SQL SECURITY INVOKER VIEW `vw_trazabilidad_tbd_order_itemes` AS
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
WHERE l.table_name = ''tbd_order_itemes'''
);
PREPARE trazabilidad_stmt FROM @trazabilidad_sql;
EXECUTE trazabilidad_stmt;
DEALLOCATE PREPARE trazabilidad_stmt;

-- Crear solo si el nombre no esta ocupado; conservar objetos existentes.
SET @trazabilidad_sql = IF(
    EXISTS (SELECT 1 FROM information_schema.TABLES
            WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'vw_trazabilidad_tbd_carts_items'),
    'SELECT ''Se conserva el objeto existente: vw_trazabilidad_tbd_carts_items'' AS resultado',
    'CREATE SQL SECURITY INVOKER VIEW `vw_trazabilidad_tbd_carts_items` AS
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
WHERE l.table_name = ''tbd_carts_items'''
);
PREPARE trazabilidad_stmt FROM @trazabilidad_sql;
EXECUTE trazabilidad_stmt;
DEALLOCATE PREPARE trazabilidad_stmt;

-- Crear solo si el nombre no esta ocupado; conservar objetos existentes.
SET @trazabilidad_sql = IF(
    EXISTS (SELECT 1 FROM information_schema.TABLES
            WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'vw_trazabilidad_tbd_products_categories'),
    'SELECT ''Se conserva el objeto existente: vw_trazabilidad_tbd_products_categories'' AS resultado',
    'CREATE SQL SECURITY INVOKER VIEW `vw_trazabilidad_tbd_products_categories` AS
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
WHERE l.table_name = ''tbd_products_categories'''
);
PREPARE trazabilidad_stmt FROM @trazabilidad_sql;
EXECUTE trazabilidad_stmt;
DEALLOCATE PREPARE trazabilidad_stmt;

-- Crear solo si el nombre no esta ocupado; conservar objetos existentes.
SET @trazabilidad_sql = IF(
    EXISTS (SELECT 1 FROM information_schema.TABLES
            WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'vw_trazabilidad_tbd_products_users_providers'),
    'SELECT ''Se conserva el objeto existente: vw_trazabilidad_tbd_products_users_providers'' AS resultado',
    'CREATE SQL SECURITY INVOKER VIEW `vw_trazabilidad_tbd_products_users_providers` AS
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
WHERE l.table_name = ''tbd_products_users_providers'''
);
PREPARE trazabilidad_stmt FROM @trazabilidad_sql;
EXECUTE trazabilidad_stmt;
DEALLOCATE PREPARE trazabilidad_stmt;

-- Crear solo si el nombre no esta ocupado; conservar objetos existentes.
SET @trazabilidad_sql = IF(
    EXISTS (SELECT 1 FROM information_schema.TABLES
            WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'vw_trazabilidad_tbd_users_wishilst_products'),
    'SELECT ''Se conserva el objeto existente: vw_trazabilidad_tbd_users_wishilst_products'' AS resultado',
    'CREATE SQL SECURITY INVOKER VIEW `vw_trazabilidad_tbd_users_wishilst_products` AS
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
WHERE l.table_name = ''tbd_users_wishilst_products'''
);
PREPARE trazabilidad_stmt FROM @trazabilidad_sql;
EXECUTE trazabilidad_stmt;
DEALLOCATE PREPARE trazabilidad_stmt;


SET @trazabilidad_sql = NULL;
