-- Resultado esperado: 3 triggers AFTER por tabla y estado OK (13 filas).
-- Se comprueba el evento y nombre previstos, no solamente el total.
USE db_test;
SELECT expected.table_name,
       COUNT(t.TRIGGER_NAME) AS expected_triggers_found,
       CASE WHEN COUNT(t.TRIGGER_NAME) = 3 THEN 'OK' ELSE 'REVISAR' END AS verification
FROM (
    SELECT 'tbc_categories' AS table_name
    UNION ALL SELECT 'tbc_payment_methods_types' AS table_name
    UNION ALL SELECT 'tbc_order_items' AS table_name
    UNION ALL SELECT 'tbc_carts_items' AS table_name
    UNION ALL SELECT 'tb_user_addresses' AS table_name
    UNION ALL SELECT 'tbd_user_payment_methods' AS table_name
    UNION ALL SELECT 'tb_carts' AS table_name
    UNION ALL SELECT 'tb_buyer_orders' AS table_name
    UNION ALL SELECT 'tbd_order_itemes' AS table_name
    UNION ALL SELECT 'tbd_carts_items' AS table_name
    UNION ALL SELECT 'tbd_products_categories' AS table_name
    UNION ALL SELECT 'tbd_products_users_providers' AS table_name
    UNION ALL SELECT 'tbd_users_wishilst_products' AS table_name
) AS expected
LEFT JOIN information_schema.TRIGGERS AS t
  ON t.TRIGGER_SCHEMA = DATABASE()
 AND t.EVENT_OBJECT_TABLE = expected.table_name
 AND t.ACTION_TIMING = 'AFTER'
 AND t.TRIGGER_NAME = CONCAT('trg_after_', LOWER(t.EVENT_MANIPULATION), '_', expected.table_name)
GROUP BY expected.table_name
ORDER BY expected.table_name;

-- Revisar todos los triggers para detectar otros que dupliquen la auditoria.
SELECT EVENT_OBJECT_TABLE, EVENT_MANIPULATION, ACTION_TIMING, TRIGGER_NAME, DEFINER
FROM information_schema.TRIGGERS
WHERE TRIGGER_SCHEMA = DATABASE()
ORDER BY EVENT_OBJECT_TABLE, EVENT_MANIPULATION, TRIGGER_NAME;

-- Ultimas operaciones auditadas (no genera registros retroactivos).
SELECT ID, table_name, operation, db_users, description, operation_date
FROM tb_logs
ORDER BY ID DESC
LIMIT 30;
