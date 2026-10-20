-- Auditoria para las 13 tablas de create_ecommerce_tables.sql (39 triggers).
-- MySQL 8.0.36. Ejecutar DESPUES de crear las tablas, con privilegio TRIGGER
-- y capacidad de insertar en tb_logs. El DEFINER sera la cuenta ejecutora.
-- No reemplaza triggers existentes: ejecutar una sola vez y detenerse ante errores.
-- No modifica los seis triggers existentes de tb_users y tb_products.
-- No crear triggers de auditoria sobre tb_logs: provocarian autorreferencia.
-- USER() identifica la conexion MySQL, no necesariamente al usuario de la tienda.
-- Se omiten datos de direccion, referencias de pago y otros datos personales.
-- Los registros de auditoria participan en la misma transaccion que la operacion.
USE db_test;
SET NAMES utf8mb4;
DELIMITER $$

CREATE TRIGGER `trg_after_insert_tbc_categories`
AFTER INSERT ON `tbc_categories`
FOR EACH ROW
BEGIN
    INSERT INTO tb_logs (table_name, operation, db_users, description)
    VALUES (
        'tbc_categories', 'Create', USER(),
        CONCAT('Registro creado. ID=', NEW.`ID`, ', datos=',
            JSON_OBJECT(
                'ID', NEW.`ID`,
                'name', NEW.`name`,
                'description', NEW.`description`,
                'sup_id_category', NEW.`sup_id_category`,
                'status', CAST(NEW.`status` AS UNSIGNED),
                'creation_date', NEW.`creation_date`,
                'last_update', NEW.`last_update`
            )
        )
    );
END$$

CREATE TRIGGER `trg_after_update_tbc_categories`
AFTER UPDATE ON `tbc_categories`
FOR EACH ROW
BEGIN
    INSERT INTO tb_logs (table_name, operation, db_users, description)
    VALUES (
        'tbc_categories', 'Update', USER(),
        CONCAT('Registro actualizado. ID=', NEW.`ID`, ', datos=',
            JSON_OBJECT('before', JSON_OBJECT(
                'ID', OLD.`ID`,
                'name', OLD.`name`,
                'description', OLD.`description`,
                'sup_id_category', OLD.`sup_id_category`,
                'status', CAST(OLD.`status` AS UNSIGNED),
                'creation_date', OLD.`creation_date`,
                'last_update', OLD.`last_update`
            ), 'after', JSON_OBJECT(
                'ID', NEW.`ID`,
                'name', NEW.`name`,
                'description', NEW.`description`,
                'sup_id_category', NEW.`sup_id_category`,
                'status', CAST(NEW.`status` AS UNSIGNED),
                'creation_date', NEW.`creation_date`,
                'last_update', NEW.`last_update`
            ))
        )
    );
END$$

CREATE TRIGGER `trg_after_delete_tbc_categories`
AFTER DELETE ON `tbc_categories`
FOR EACH ROW
BEGIN
    INSERT INTO tb_logs (table_name, operation, db_users, description)
    VALUES (
        'tbc_categories', 'Delete', USER(),
        CONCAT('Registro eliminado. ID=', OLD.`ID`, ', datos=',
            JSON_OBJECT(
                'ID', OLD.`ID`,
                'name', OLD.`name`,
                'description', OLD.`description`,
                'sup_id_category', OLD.`sup_id_category`,
                'status', CAST(OLD.`status` AS UNSIGNED),
                'creation_date', OLD.`creation_date`,
                'last_update', OLD.`last_update`
            )
        )
    );
END$$

CREATE TRIGGER `trg_after_insert_tbc_payment_methods_types`
AFTER INSERT ON `tbc_payment_methods_types`
FOR EACH ROW
BEGIN
    INSERT INTO tb_logs (table_name, operation, db_users, description)
    VALUES (
        'tbc_payment_methods_types', 'Create', USER(),
        CONCAT('Registro creado. ID=', NEW.`ID`, ', datos=',
            JSON_OBJECT(
                'ID', NEW.`ID`,
                'code', NEW.`code`,
                'name', NEW.`name`,
                'status', CAST(NEW.`status` AS UNSIGNED),
                'creation_date', NEW.`creation_date`,
                'last_update', NEW.`last_update`
            )
        )
    );
END$$

CREATE TRIGGER `trg_after_update_tbc_payment_methods_types`
AFTER UPDATE ON `tbc_payment_methods_types`
FOR EACH ROW
BEGIN
    INSERT INTO tb_logs (table_name, operation, db_users, description)
    VALUES (
        'tbc_payment_methods_types', 'Update', USER(),
        CONCAT('Registro actualizado. ID=', NEW.`ID`, ', datos=',
            JSON_OBJECT('before', JSON_OBJECT(
                'ID', OLD.`ID`,
                'code', OLD.`code`,
                'name', OLD.`name`,
                'status', CAST(OLD.`status` AS UNSIGNED),
                'creation_date', OLD.`creation_date`,
                'last_update', OLD.`last_update`
            ), 'after', JSON_OBJECT(
                'ID', NEW.`ID`,
                'code', NEW.`code`,
                'name', NEW.`name`,
                'status', CAST(NEW.`status` AS UNSIGNED),
                'creation_date', NEW.`creation_date`,
                'last_update', NEW.`last_update`
            ))
        )
    );
END$$

CREATE TRIGGER `trg_after_delete_tbc_payment_methods_types`
AFTER DELETE ON `tbc_payment_methods_types`
FOR EACH ROW
BEGIN
    INSERT INTO tb_logs (table_name, operation, db_users, description)
    VALUES (
        'tbc_payment_methods_types', 'Delete', USER(),
        CONCAT('Registro eliminado. ID=', OLD.`ID`, ', datos=',
            JSON_OBJECT(
                'ID', OLD.`ID`,
                'code', OLD.`code`,
                'name', OLD.`name`,
                'status', CAST(OLD.`status` AS UNSIGNED),
                'creation_date', OLD.`creation_date`,
                'last_update', OLD.`last_update`
            )
        )
    );
END$$

CREATE TRIGGER `trg_after_insert_tbc_order_items`
AFTER INSERT ON `tbc_order_items`
FOR EACH ROW
BEGIN
    INSERT INTO tb_logs (table_name, operation, db_users, description)
    VALUES (
        'tbc_order_items', 'Create', USER(),
        CONCAT('Registro creado. ID=', NEW.`ID`, ', datos=',
            JSON_OBJECT(
                'ID', NEW.`ID`,
                'code', NEW.`code`,
                'name', NEW.`name`,
                'description', NEW.`description`,
                'status', CAST(NEW.`status` AS UNSIGNED)
            )
        )
    );
END$$

CREATE TRIGGER `trg_after_update_tbc_order_items`
AFTER UPDATE ON `tbc_order_items`
FOR EACH ROW
BEGIN
    INSERT INTO tb_logs (table_name, operation, db_users, description)
    VALUES (
        'tbc_order_items', 'Update', USER(),
        CONCAT('Registro actualizado. ID=', NEW.`ID`, ', datos=',
            JSON_OBJECT('before', JSON_OBJECT(
                'ID', OLD.`ID`,
                'code', OLD.`code`,
                'name', OLD.`name`,
                'description', OLD.`description`,
                'status', CAST(OLD.`status` AS UNSIGNED)
            ), 'after', JSON_OBJECT(
                'ID', NEW.`ID`,
                'code', NEW.`code`,
                'name', NEW.`name`,
                'description', NEW.`description`,
                'status', CAST(NEW.`status` AS UNSIGNED)
            ))
        )
    );
END$$

CREATE TRIGGER `trg_after_delete_tbc_order_items`
AFTER DELETE ON `tbc_order_items`
FOR EACH ROW
BEGIN
    INSERT INTO tb_logs (table_name, operation, db_users, description)
    VALUES (
        'tbc_order_items', 'Delete', USER(),
        CONCAT('Registro eliminado. ID=', OLD.`ID`, ', datos=',
            JSON_OBJECT(
                'ID', OLD.`ID`,
                'code', OLD.`code`,
                'name', OLD.`name`,
                'description', OLD.`description`,
                'status', CAST(OLD.`status` AS UNSIGNED)
            )
        )
    );
END$$

CREATE TRIGGER `trg_after_insert_tbc_carts_items`
AFTER INSERT ON `tbc_carts_items`
FOR EACH ROW
BEGIN
    INSERT INTO tb_logs (table_name, operation, db_users, description)
    VALUES (
        'tbc_carts_items', 'Create', USER(),
        CONCAT('Registro creado. ID=', NEW.`ID`, ', datos=',
            JSON_OBJECT(
                'ID', NEW.`ID`,
                'code', NEW.`code`,
                'name', NEW.`name`,
                'description', NEW.`description`,
                'status', CAST(NEW.`status` AS UNSIGNED)
            )
        )
    );
END$$

CREATE TRIGGER `trg_after_update_tbc_carts_items`
AFTER UPDATE ON `tbc_carts_items`
FOR EACH ROW
BEGIN
    INSERT INTO tb_logs (table_name, operation, db_users, description)
    VALUES (
        'tbc_carts_items', 'Update', USER(),
        CONCAT('Registro actualizado. ID=', NEW.`ID`, ', datos=',
            JSON_OBJECT('before', JSON_OBJECT(
                'ID', OLD.`ID`,
                'code', OLD.`code`,
                'name', OLD.`name`,
                'description', OLD.`description`,
                'status', CAST(OLD.`status` AS UNSIGNED)
            ), 'after', JSON_OBJECT(
                'ID', NEW.`ID`,
                'code', NEW.`code`,
                'name', NEW.`name`,
                'description', NEW.`description`,
                'status', CAST(NEW.`status` AS UNSIGNED)
            ))
        )
    );
END$$

CREATE TRIGGER `trg_after_delete_tbc_carts_items`
AFTER DELETE ON `tbc_carts_items`
FOR EACH ROW
BEGIN
    INSERT INTO tb_logs (table_name, operation, db_users, description)
    VALUES (
        'tbc_carts_items', 'Delete', USER(),
        CONCAT('Registro eliminado. ID=', OLD.`ID`, ', datos=',
            JSON_OBJECT(
                'ID', OLD.`ID`,
                'code', OLD.`code`,
                'name', OLD.`name`,
                'description', OLD.`description`,
                'status', CAST(OLD.`status` AS UNSIGNED)
            )
        )
    );
END$$

CREATE TRIGGER `trg_after_insert_tb_user_addresses`
AFTER INSERT ON `tb_user_addresses`
FOR EACH ROW
BEGIN
    INSERT INTO tb_logs (table_name, operation, db_users, description)
    VALUES (
        'tb_user_addresses', 'Create', USER(),
        CONCAT('Registro creado. ID=', NEW.`ID`, ', datos=',
            JSON_OBJECT(
                'ID', NEW.`ID`,
                'user_ID', NEW.`user_ID`,
                'label', NEW.`label`,
                'country_code', NEW.`country_code`,
                'status', CAST(NEW.`status` AS UNSIGNED),
                'creation_date', NEW.`creation_date`,
                'last_update', NEW.`last_update`
            )
        )
    );
END$$

CREATE TRIGGER `trg_after_update_tb_user_addresses`
AFTER UPDATE ON `tb_user_addresses`
FOR EACH ROW
BEGIN
    INSERT INTO tb_logs (table_name, operation, db_users, description)
    VALUES (
        'tb_user_addresses', 'Update', USER(),
        CONCAT('Registro actualizado. ID=', NEW.`ID`, ', datos=',
            JSON_OBJECT('before', JSON_OBJECT(
                'ID', OLD.`ID`,
                'user_ID', OLD.`user_ID`,
                'label', OLD.`label`,
                'country_code', OLD.`country_code`,
                'status', CAST(OLD.`status` AS UNSIGNED),
                'creation_date', OLD.`creation_date`,
                'last_update', OLD.`last_update`
            ), 'after', JSON_OBJECT(
                'ID', NEW.`ID`,
                'user_ID', NEW.`user_ID`,
                'label', NEW.`label`,
                'country_code', NEW.`country_code`,
                'status', CAST(NEW.`status` AS UNSIGNED),
                'creation_date', NEW.`creation_date`,
                'last_update', NEW.`last_update`
            ))
        )
    );
END$$

CREATE TRIGGER `trg_after_delete_tb_user_addresses`
AFTER DELETE ON `tb_user_addresses`
FOR EACH ROW
BEGIN
    INSERT INTO tb_logs (table_name, operation, db_users, description)
    VALUES (
        'tb_user_addresses', 'Delete', USER(),
        CONCAT('Registro eliminado. ID=', OLD.`ID`, ', datos=',
            JSON_OBJECT(
                'ID', OLD.`ID`,
                'user_ID', OLD.`user_ID`,
                'label', OLD.`label`,
                'country_code', OLD.`country_code`,
                'status', CAST(OLD.`status` AS UNSIGNED),
                'creation_date', OLD.`creation_date`,
                'last_update', OLD.`last_update`
            )
        )
    );
END$$

CREATE TRIGGER `trg_after_insert_tbd_user_payment_methods`
AFTER INSERT ON `tbd_user_payment_methods`
FOR EACH ROW
BEGIN
    INSERT INTO tb_logs (table_name, operation, db_users, description)
    VALUES (
        'tbd_user_payment_methods', 'Create', USER(),
        CONCAT('Registro creado. ID=', NEW.`ID`, ', datos=',
            JSON_OBJECT(
                'ID', NEW.`ID`,
                'user_ID', NEW.`user_ID`,
                'payment_method_type_ID', NEW.`payment_method_type_ID`,
                'provider', NEW.`provider`,
                'status', CAST(NEW.`status` AS UNSIGNED),
                'creation_date', NEW.`creation_date`,
                'last_update', NEW.`last_update`
            )
        )
    );
END$$

CREATE TRIGGER `trg_after_update_tbd_user_payment_methods`
AFTER UPDATE ON `tbd_user_payment_methods`
FOR EACH ROW
BEGIN
    INSERT INTO tb_logs (table_name, operation, db_users, description)
    VALUES (
        'tbd_user_payment_methods', 'Update', USER(),
        CONCAT('Registro actualizado. ID=', NEW.`ID`, ', datos=',
            JSON_OBJECT('before', JSON_OBJECT(
                'ID', OLD.`ID`,
                'user_ID', OLD.`user_ID`,
                'payment_method_type_ID', OLD.`payment_method_type_ID`,
                'provider', OLD.`provider`,
                'status', CAST(OLD.`status` AS UNSIGNED),
                'creation_date', OLD.`creation_date`,
                'last_update', OLD.`last_update`
            ), 'after', JSON_OBJECT(
                'ID', NEW.`ID`,
                'user_ID', NEW.`user_ID`,
                'payment_method_type_ID', NEW.`payment_method_type_ID`,
                'provider', NEW.`provider`,
                'status', CAST(NEW.`status` AS UNSIGNED),
                'creation_date', NEW.`creation_date`,
                'last_update', NEW.`last_update`
            ))
        )
    );
END$$

CREATE TRIGGER `trg_after_delete_tbd_user_payment_methods`
AFTER DELETE ON `tbd_user_payment_methods`
FOR EACH ROW
BEGIN
    INSERT INTO tb_logs (table_name, operation, db_users, description)
    VALUES (
        'tbd_user_payment_methods', 'Delete', USER(),
        CONCAT('Registro eliminado. ID=', OLD.`ID`, ', datos=',
            JSON_OBJECT(
                'ID', OLD.`ID`,
                'user_ID', OLD.`user_ID`,
                'payment_method_type_ID', OLD.`payment_method_type_ID`,
                'provider', OLD.`provider`,
                'status', CAST(OLD.`status` AS UNSIGNED),
                'creation_date', OLD.`creation_date`,
                'last_update', OLD.`last_update`
            )
        )
    );
END$$

CREATE TRIGGER `trg_after_insert_tb_carts`
AFTER INSERT ON `tb_carts`
FOR EACH ROW
BEGIN
    INSERT INTO tb_logs (table_name, operation, db_users, description)
    VALUES (
        'tb_carts', 'Create', USER(),
        CONCAT('Registro creado. ID=', NEW.`ID`, ', datos=',
            JSON_OBJECT(
                'ID', NEW.`ID`,
                'user_ID', NEW.`user_ID`,
                'status', NEW.`status`,
                'currency', NEW.`currency`,
                'active_user_ID', NEW.`active_user_ID`,
                'creation_date', NEW.`creation_date`,
                'last_update', NEW.`last_update`
            )
        )
    );
END$$

CREATE TRIGGER `trg_after_update_tb_carts`
AFTER UPDATE ON `tb_carts`
FOR EACH ROW
BEGIN
    INSERT INTO tb_logs (table_name, operation, db_users, description)
    VALUES (
        'tb_carts', 'Update', USER(),
        CONCAT('Registro actualizado. ID=', NEW.`ID`, ', datos=',
            JSON_OBJECT('before', JSON_OBJECT(
                'ID', OLD.`ID`,
                'user_ID', OLD.`user_ID`,
                'status', OLD.`status`,
                'currency', OLD.`currency`,
                'active_user_ID', OLD.`active_user_ID`,
                'creation_date', OLD.`creation_date`,
                'last_update', OLD.`last_update`
            ), 'after', JSON_OBJECT(
                'ID', NEW.`ID`,
                'user_ID', NEW.`user_ID`,
                'status', NEW.`status`,
                'currency', NEW.`currency`,
                'active_user_ID', NEW.`active_user_ID`,
                'creation_date', NEW.`creation_date`,
                'last_update', NEW.`last_update`
            ))
        )
    );
END$$

CREATE TRIGGER `trg_after_delete_tb_carts`
AFTER DELETE ON `tb_carts`
FOR EACH ROW
BEGIN
    INSERT INTO tb_logs (table_name, operation, db_users, description)
    VALUES (
        'tb_carts', 'Delete', USER(),
        CONCAT('Registro eliminado. ID=', OLD.`ID`, ', datos=',
            JSON_OBJECT(
                'ID', OLD.`ID`,
                'user_ID', OLD.`user_ID`,
                'status', OLD.`status`,
                'currency', OLD.`currency`,
                'active_user_ID', OLD.`active_user_ID`,
                'creation_date', OLD.`creation_date`,
                'last_update', OLD.`last_update`
            )
        )
    );
END$$

CREATE TRIGGER `trg_after_insert_tb_buyer_orders`
AFTER INSERT ON `tb_buyer_orders`
FOR EACH ROW
BEGIN
    INSERT INTO tb_logs (table_name, operation, db_users, description)
    VALUES (
        'tb_buyer_orders', 'Create', USER(),
        CONCAT('Registro creado. ID=', NEW.`ID`, ', datos=',
            JSON_OBJECT(
                'ID', NEW.`ID`,
                'order_number', NEW.`order_number`,
                'buyer_user_ID', NEW.`buyer_user_ID`,
                'cart_ID', NEW.`cart_ID`,
                'shipping_address_ID', NEW.`shipping_address_ID`,
                'user_payment_method_ID', NEW.`user_payment_method_ID`,
                'status', NEW.`status`,
                'payment_status', NEW.`payment_status`,
                'currency', NEW.`currency`,
                'subtotal', NEW.`subtotal`,
                'discount_total', NEW.`discount_total`,
                'tax_total', NEW.`tax_total`,
                'shipping_total', NEW.`shipping_total`,
                'grand_total', NEW.`grand_total`,
                'creation_date', NEW.`creation_date`,
                'last_update', NEW.`last_update`
            )
        )
    );
END$$

CREATE TRIGGER `trg_after_update_tb_buyer_orders`
AFTER UPDATE ON `tb_buyer_orders`
FOR EACH ROW
BEGIN
    INSERT INTO tb_logs (table_name, operation, db_users, description)
    VALUES (
        'tb_buyer_orders', 'Update', USER(),
        CONCAT('Registro actualizado. ID=', NEW.`ID`, ', datos=',
            JSON_OBJECT('before', JSON_OBJECT(
                'ID', OLD.`ID`,
                'order_number', OLD.`order_number`,
                'buyer_user_ID', OLD.`buyer_user_ID`,
                'cart_ID', OLD.`cart_ID`,
                'shipping_address_ID', OLD.`shipping_address_ID`,
                'user_payment_method_ID', OLD.`user_payment_method_ID`,
                'status', OLD.`status`,
                'payment_status', OLD.`payment_status`,
                'currency', OLD.`currency`,
                'subtotal', OLD.`subtotal`,
                'discount_total', OLD.`discount_total`,
                'tax_total', OLD.`tax_total`,
                'shipping_total', OLD.`shipping_total`,
                'grand_total', OLD.`grand_total`,
                'creation_date', OLD.`creation_date`,
                'last_update', OLD.`last_update`
            ), 'after', JSON_OBJECT(
                'ID', NEW.`ID`,
                'order_number', NEW.`order_number`,
                'buyer_user_ID', NEW.`buyer_user_ID`,
                'cart_ID', NEW.`cart_ID`,
                'shipping_address_ID', NEW.`shipping_address_ID`,
                'user_payment_method_ID', NEW.`user_payment_method_ID`,
                'status', NEW.`status`,
                'payment_status', NEW.`payment_status`,
                'currency', NEW.`currency`,
                'subtotal', NEW.`subtotal`,
                'discount_total', NEW.`discount_total`,
                'tax_total', NEW.`tax_total`,
                'shipping_total', NEW.`shipping_total`,
                'grand_total', NEW.`grand_total`,
                'creation_date', NEW.`creation_date`,
                'last_update', NEW.`last_update`
            ))
        )
    );
END$$

CREATE TRIGGER `trg_after_delete_tb_buyer_orders`
AFTER DELETE ON `tb_buyer_orders`
FOR EACH ROW
BEGIN
    INSERT INTO tb_logs (table_name, operation, db_users, description)
    VALUES (
        'tb_buyer_orders', 'Delete', USER(),
        CONCAT('Registro eliminado. ID=', OLD.`ID`, ', datos=',
            JSON_OBJECT(
                'ID', OLD.`ID`,
                'order_number', OLD.`order_number`,
                'buyer_user_ID', OLD.`buyer_user_ID`,
                'cart_ID', OLD.`cart_ID`,
                'shipping_address_ID', OLD.`shipping_address_ID`,
                'user_payment_method_ID', OLD.`user_payment_method_ID`,
                'status', OLD.`status`,
                'payment_status', OLD.`payment_status`,
                'currency', OLD.`currency`,
                'subtotal', OLD.`subtotal`,
                'discount_total', OLD.`discount_total`,
                'tax_total', OLD.`tax_total`,
                'shipping_total', OLD.`shipping_total`,
                'grand_total', OLD.`grand_total`,
                'creation_date', OLD.`creation_date`,
                'last_update', OLD.`last_update`
            )
        )
    );
END$$

CREATE TRIGGER `trg_after_insert_tbd_order_itemes`
AFTER INSERT ON `tbd_order_itemes`
FOR EACH ROW
BEGIN
    INSERT INTO tb_logs (table_name, operation, db_users, description)
    VALUES (
        'tbd_order_itemes', 'Create', USER(),
        CONCAT('Registro creado. ID=', NEW.`ID`, ', datos=',
            JSON_OBJECT(
                'ID', NEW.`ID`,
                'order_ID', NEW.`order_ID`,
                'product_ID', NEW.`product_ID`,
                'order_item_status_ID', NEW.`order_item_status_ID`,
                'product_sku_snapshot', NEW.`product_sku_snapshot`,
                'product_name_snapshot', NEW.`product_name_snapshot`,
                'quantity', NEW.`quantity`,
                'unit_price', NEW.`unit_price`,
                'discount_total', NEW.`discount_total`,
                'tax_total', NEW.`tax_total`,
                'line_total', NEW.`line_total`,
                'creation_date', NEW.`creation_date`,
                'last_update', NEW.`last_update`
            )
        )
    );
END$$

CREATE TRIGGER `trg_after_update_tbd_order_itemes`
AFTER UPDATE ON `tbd_order_itemes`
FOR EACH ROW
BEGIN
    INSERT INTO tb_logs (table_name, operation, db_users, description)
    VALUES (
        'tbd_order_itemes', 'Update', USER(),
        CONCAT('Registro actualizado. ID=', NEW.`ID`, ', datos=',
            JSON_OBJECT('before', JSON_OBJECT(
                'ID', OLD.`ID`,
                'order_ID', OLD.`order_ID`,
                'product_ID', OLD.`product_ID`,
                'order_item_status_ID', OLD.`order_item_status_ID`,
                'product_sku_snapshot', OLD.`product_sku_snapshot`,
                'product_name_snapshot', OLD.`product_name_snapshot`,
                'quantity', OLD.`quantity`,
                'unit_price', OLD.`unit_price`,
                'discount_total', OLD.`discount_total`,
                'tax_total', OLD.`tax_total`,
                'line_total', OLD.`line_total`,
                'creation_date', OLD.`creation_date`,
                'last_update', OLD.`last_update`
            ), 'after', JSON_OBJECT(
                'ID', NEW.`ID`,
                'order_ID', NEW.`order_ID`,
                'product_ID', NEW.`product_ID`,
                'order_item_status_ID', NEW.`order_item_status_ID`,
                'product_sku_snapshot', NEW.`product_sku_snapshot`,
                'product_name_snapshot', NEW.`product_name_snapshot`,
                'quantity', NEW.`quantity`,
                'unit_price', NEW.`unit_price`,
                'discount_total', NEW.`discount_total`,
                'tax_total', NEW.`tax_total`,
                'line_total', NEW.`line_total`,
                'creation_date', NEW.`creation_date`,
                'last_update', NEW.`last_update`
            ))
        )
    );
END$$

CREATE TRIGGER `trg_after_delete_tbd_order_itemes`
AFTER DELETE ON `tbd_order_itemes`
FOR EACH ROW
BEGIN
    INSERT INTO tb_logs (table_name, operation, db_users, description)
    VALUES (
        'tbd_order_itemes', 'Delete', USER(),
        CONCAT('Registro eliminado. ID=', OLD.`ID`, ', datos=',
            JSON_OBJECT(
                'ID', OLD.`ID`,
                'order_ID', OLD.`order_ID`,
                'product_ID', OLD.`product_ID`,
                'order_item_status_ID', OLD.`order_item_status_ID`,
                'product_sku_snapshot', OLD.`product_sku_snapshot`,
                'product_name_snapshot', OLD.`product_name_snapshot`,
                'quantity', OLD.`quantity`,
                'unit_price', OLD.`unit_price`,
                'discount_total', OLD.`discount_total`,
                'tax_total', OLD.`tax_total`,
                'line_total', OLD.`line_total`,
                'creation_date', OLD.`creation_date`,
                'last_update', OLD.`last_update`
            )
        )
    );
END$$

CREATE TRIGGER `trg_after_insert_tbd_carts_items`
AFTER INSERT ON `tbd_carts_items`
FOR EACH ROW
BEGIN
    INSERT INTO tb_logs (table_name, operation, db_users, description)
    VALUES (
        'tbd_carts_items', 'Create', USER(),
        CONCAT('Registro creado. ID=', NEW.`ID`, ', datos=',
            JSON_OBJECT(
                'ID', NEW.`ID`,
                'cart_ID', NEW.`cart_ID`,
                'product_ID', NEW.`product_ID`,
                'cart_item_status_ID', NEW.`cart_item_status_ID`,
                'quantity', NEW.`quantity`,
                'creation_date', NEW.`creation_date`,
                'last_update', NEW.`last_update`
            )
        )
    );
END$$

CREATE TRIGGER `trg_after_update_tbd_carts_items`
AFTER UPDATE ON `tbd_carts_items`
FOR EACH ROW
BEGIN
    INSERT INTO tb_logs (table_name, operation, db_users, description)
    VALUES (
        'tbd_carts_items', 'Update', USER(),
        CONCAT('Registro actualizado. ID=', NEW.`ID`, ', datos=',
            JSON_OBJECT('before', JSON_OBJECT(
                'ID', OLD.`ID`,
                'cart_ID', OLD.`cart_ID`,
                'product_ID', OLD.`product_ID`,
                'cart_item_status_ID', OLD.`cart_item_status_ID`,
                'quantity', OLD.`quantity`,
                'creation_date', OLD.`creation_date`,
                'last_update', OLD.`last_update`
            ), 'after', JSON_OBJECT(
                'ID', NEW.`ID`,
                'cart_ID', NEW.`cart_ID`,
                'product_ID', NEW.`product_ID`,
                'cart_item_status_ID', NEW.`cart_item_status_ID`,
                'quantity', NEW.`quantity`,
                'creation_date', NEW.`creation_date`,
                'last_update', NEW.`last_update`
            ))
        )
    );
END$$

CREATE TRIGGER `trg_after_delete_tbd_carts_items`
AFTER DELETE ON `tbd_carts_items`
FOR EACH ROW
BEGIN
    INSERT INTO tb_logs (table_name, operation, db_users, description)
    VALUES (
        'tbd_carts_items', 'Delete', USER(),
        CONCAT('Registro eliminado. ID=', OLD.`ID`, ', datos=',
            JSON_OBJECT(
                'ID', OLD.`ID`,
                'cart_ID', OLD.`cart_ID`,
                'product_ID', OLD.`product_ID`,
                'cart_item_status_ID', OLD.`cart_item_status_ID`,
                'quantity', OLD.`quantity`,
                'creation_date', OLD.`creation_date`,
                'last_update', OLD.`last_update`
            )
        )
    );
END$$

CREATE TRIGGER `trg_after_insert_tbd_products_categories`
AFTER INSERT ON `tbd_products_categories`
FOR EACH ROW
BEGIN
    INSERT INTO tb_logs (table_name, operation, db_users, description)
    VALUES (
        'tbd_products_categories', 'Create', USER(),
        CONCAT('Registro creado. ID=', NEW.`ID`, ', datos=',
            JSON_OBJECT(
                'ID', NEW.`ID`,
                'product_ID', NEW.`product_ID`,
                'category_ID', NEW.`category_ID`,
                'status', CAST(NEW.`status` AS UNSIGNED),
                'creation_date', NEW.`creation_date`,
                'last_update', NEW.`last_update`
            )
        )
    );
END$$

CREATE TRIGGER `trg_after_update_tbd_products_categories`
AFTER UPDATE ON `tbd_products_categories`
FOR EACH ROW
BEGIN
    INSERT INTO tb_logs (table_name, operation, db_users, description)
    VALUES (
        'tbd_products_categories', 'Update', USER(),
        CONCAT('Registro actualizado. ID=', NEW.`ID`, ', datos=',
            JSON_OBJECT('before', JSON_OBJECT(
                'ID', OLD.`ID`,
                'product_ID', OLD.`product_ID`,
                'category_ID', OLD.`category_ID`,
                'status', CAST(OLD.`status` AS UNSIGNED),
                'creation_date', OLD.`creation_date`,
                'last_update', OLD.`last_update`
            ), 'after', JSON_OBJECT(
                'ID', NEW.`ID`,
                'product_ID', NEW.`product_ID`,
                'category_ID', NEW.`category_ID`,
                'status', CAST(NEW.`status` AS UNSIGNED),
                'creation_date', NEW.`creation_date`,
                'last_update', NEW.`last_update`
            ))
        )
    );
END$$

CREATE TRIGGER `trg_after_delete_tbd_products_categories`
AFTER DELETE ON `tbd_products_categories`
FOR EACH ROW
BEGIN
    INSERT INTO tb_logs (table_name, operation, db_users, description)
    VALUES (
        'tbd_products_categories', 'Delete', USER(),
        CONCAT('Registro eliminado. ID=', OLD.`ID`, ', datos=',
            JSON_OBJECT(
                'ID', OLD.`ID`,
                'product_ID', OLD.`product_ID`,
                'category_ID', OLD.`category_ID`,
                'status', CAST(OLD.`status` AS UNSIGNED),
                'creation_date', OLD.`creation_date`,
                'last_update', OLD.`last_update`
            )
        )
    );
END$$

CREATE TRIGGER `trg_after_insert_tbd_products_users_providers`
AFTER INSERT ON `tbd_products_users_providers`
FOR EACH ROW
BEGIN
    INSERT INTO tb_logs (table_name, operation, db_users, description)
    VALUES (
        'tbd_products_users_providers', 'Create', USER(),
        CONCAT('Registro creado. ID=', NEW.`ID`, ', datos=',
            JSON_OBJECT(
                'ID', NEW.`ID`,
                'product_ID', NEW.`product_ID`,
                'provider_user_ID', NEW.`provider_user_ID`,
                'provider_sku', NEW.`provider_sku`,
                'acquisition_cost', NEW.`acquisition_cost`,
                'status', CAST(NEW.`status` AS UNSIGNED),
                'creation_date', NEW.`creation_date`,
                'last_update', NEW.`last_update`
            )
        )
    );
END$$

CREATE TRIGGER `trg_after_update_tbd_products_users_providers`
AFTER UPDATE ON `tbd_products_users_providers`
FOR EACH ROW
BEGIN
    INSERT INTO tb_logs (table_name, operation, db_users, description)
    VALUES (
        'tbd_products_users_providers', 'Update', USER(),
        CONCAT('Registro actualizado. ID=', NEW.`ID`, ', datos=',
            JSON_OBJECT('before', JSON_OBJECT(
                'ID', OLD.`ID`,
                'product_ID', OLD.`product_ID`,
                'provider_user_ID', OLD.`provider_user_ID`,
                'provider_sku', OLD.`provider_sku`,
                'acquisition_cost', OLD.`acquisition_cost`,
                'status', CAST(OLD.`status` AS UNSIGNED),
                'creation_date', OLD.`creation_date`,
                'last_update', OLD.`last_update`
            ), 'after', JSON_OBJECT(
                'ID', NEW.`ID`,
                'product_ID', NEW.`product_ID`,
                'provider_user_ID', NEW.`provider_user_ID`,
                'provider_sku', NEW.`provider_sku`,
                'acquisition_cost', NEW.`acquisition_cost`,
                'status', CAST(NEW.`status` AS UNSIGNED),
                'creation_date', NEW.`creation_date`,
                'last_update', NEW.`last_update`
            ))
        )
    );
END$$

CREATE TRIGGER `trg_after_delete_tbd_products_users_providers`
AFTER DELETE ON `tbd_products_users_providers`
FOR EACH ROW
BEGIN
    INSERT INTO tb_logs (table_name, operation, db_users, description)
    VALUES (
        'tbd_products_users_providers', 'Delete', USER(),
        CONCAT('Registro eliminado. ID=', OLD.`ID`, ', datos=',
            JSON_OBJECT(
                'ID', OLD.`ID`,
                'product_ID', OLD.`product_ID`,
                'provider_user_ID', OLD.`provider_user_ID`,
                'provider_sku', OLD.`provider_sku`,
                'acquisition_cost', OLD.`acquisition_cost`,
                'status', CAST(OLD.`status` AS UNSIGNED),
                'creation_date', OLD.`creation_date`,
                'last_update', OLD.`last_update`
            )
        )
    );
END$$

CREATE TRIGGER `trg_after_insert_tbd_users_wishilst_products`
AFTER INSERT ON `tbd_users_wishilst_products`
FOR EACH ROW
BEGIN
    INSERT INTO tb_logs (table_name, operation, db_users, description)
    VALUES (
        'tbd_users_wishilst_products', 'Create', USER(),
        CONCAT('Registro creado. ID=', NEW.`ID`, ', datos=',
            JSON_OBJECT(
                'ID', NEW.`ID`,
                'user_ID', NEW.`user_ID`,
                'product_ID', NEW.`product_ID`,
                'status', CAST(NEW.`status` AS UNSIGNED),
                'creation_date', NEW.`creation_date`,
                'last_update', NEW.`last_update`
            )
        )
    );
END$$

CREATE TRIGGER `trg_after_update_tbd_users_wishilst_products`
AFTER UPDATE ON `tbd_users_wishilst_products`
FOR EACH ROW
BEGIN
    INSERT INTO tb_logs (table_name, operation, db_users, description)
    VALUES (
        'tbd_users_wishilst_products', 'Update', USER(),
        CONCAT('Registro actualizado. ID=', NEW.`ID`, ', datos=',
            JSON_OBJECT('before', JSON_OBJECT(
                'ID', OLD.`ID`,
                'user_ID', OLD.`user_ID`,
                'product_ID', OLD.`product_ID`,
                'status', CAST(OLD.`status` AS UNSIGNED),
                'creation_date', OLD.`creation_date`,
                'last_update', OLD.`last_update`
            ), 'after', JSON_OBJECT(
                'ID', NEW.`ID`,
                'user_ID', NEW.`user_ID`,
                'product_ID', NEW.`product_ID`,
                'status', CAST(NEW.`status` AS UNSIGNED),
                'creation_date', NEW.`creation_date`,
                'last_update', NEW.`last_update`
            ))
        )
    );
END$$

CREATE TRIGGER `trg_after_delete_tbd_users_wishilst_products`
AFTER DELETE ON `tbd_users_wishilst_products`
FOR EACH ROW
BEGIN
    INSERT INTO tb_logs (table_name, operation, db_users, description)
    VALUES (
        'tbd_users_wishilst_products', 'Delete', USER(),
        CONCAT('Registro eliminado. ID=', OLD.`ID`, ', datos=',
            JSON_OBJECT(
                'ID', OLD.`ID`,
                'user_ID', OLD.`user_ID`,
                'product_ID', OLD.`product_ID`,
                'status', CAST(OLD.`status` AS UNSIGNED),
                'creation_date', OLD.`creation_date`,
                'last_update', OLD.`last_update`
            )
        )
    );
END$$

DELIMITER ;
