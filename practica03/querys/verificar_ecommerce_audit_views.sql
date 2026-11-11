-- Deben aparecer 13 filas con verification = OK.
USE db_test;
SELECT expected.view_name,
       CASE WHEN v.TABLE_NAME IS NOT NULL THEN 'OK' ELSE 'FALTA' END AS verification
FROM (
    SELECT 'vw_trazabilidad_tbc_categories' AS view_name
    UNION ALL SELECT 'vw_trazabilidad_tbc_payment_methods_types' AS view_name
    UNION ALL SELECT 'vw_trazabilidad_tbc_order_items' AS view_name
    UNION ALL SELECT 'vw_trazabilidad_tbc_carts_items' AS view_name
    UNION ALL SELECT 'vw_trazabilidad_tb_user_addresses' AS view_name
    UNION ALL SELECT 'vw_trazabilidad_tbd_user_payment_methods' AS view_name
    UNION ALL SELECT 'vw_trazabilidad_tb_carts' AS view_name
    UNION ALL SELECT 'vw_trazabilidad_tb_buyer_orders' AS view_name
    UNION ALL SELECT 'vw_trazabilidad_tbd_order_itemes' AS view_name
    UNION ALL SELECT 'vw_trazabilidad_tbd_carts_items' AS view_name
    UNION ALL SELECT 'vw_trazabilidad_tbd_products_categories' AS view_name
    UNION ALL SELECT 'vw_trazabilidad_tbd_products_users_providers' AS view_name
    UNION ALL SELECT 'vw_trazabilidad_tbd_users_wishilst_products' AS view_name
) AS expected
LEFT JOIN information_schema.VIEWS AS v
  ON v.TABLE_SCHEMA = DATABASE() AND v.TABLE_NAME = expected.view_name
ORDER BY expected.view_name;

-- Muestras: una vista vacia es normal si todavia no hay operaciones auditadas.
SELECT * FROM `vw_trazabilidad_tbc_categories` ORDER BY operation_date DESC, log_id DESC LIMIT 10;
SELECT * FROM `vw_trazabilidad_tbc_payment_methods_types` ORDER BY operation_date DESC, log_id DESC LIMIT 10;
SELECT * FROM `vw_trazabilidad_tbc_order_items` ORDER BY operation_date DESC, log_id DESC LIMIT 10;
SELECT * FROM `vw_trazabilidad_tbc_carts_items` ORDER BY operation_date DESC, log_id DESC LIMIT 10;
SELECT * FROM `vw_trazabilidad_tb_user_addresses` ORDER BY operation_date DESC, log_id DESC LIMIT 10;
SELECT * FROM `vw_trazabilidad_tbd_user_payment_methods` ORDER BY operation_date DESC, log_id DESC LIMIT 10;
SELECT * FROM `vw_trazabilidad_tb_carts` ORDER BY operation_date DESC, log_id DESC LIMIT 10;
SELECT * FROM `vw_trazabilidad_tb_buyer_orders` ORDER BY operation_date DESC, log_id DESC LIMIT 10;
SELECT * FROM `vw_trazabilidad_tbd_order_itemes` ORDER BY operation_date DESC, log_id DESC LIMIT 10;
SELECT * FROM `vw_trazabilidad_tbd_carts_items` ORDER BY operation_date DESC, log_id DESC LIMIT 10;
SELECT * FROM `vw_trazabilidad_tbd_products_categories` ORDER BY operation_date DESC, log_id DESC LIMIT 10;
SELECT * FROM `vw_trazabilidad_tbd_products_users_providers` ORDER BY operation_date DESC, log_id DESC LIMIT 10;
SELECT * FROM `vw_trazabilidad_tbd_users_wishilst_products` ORDER BY operation_date DESC, log_id DESC LIMIT 10;
