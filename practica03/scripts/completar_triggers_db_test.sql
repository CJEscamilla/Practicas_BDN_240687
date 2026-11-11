-- Triggers para db_test basado en respaldo10_28.1.sql (MySQL 8).
-- Ejecutar una sola vez. No elimina ni modifica triggers existentes.
-- Antes de ejecutar, comparar el esquema y triggers activos con el respaldo.
-- Los cambios DDL se confirman implicitamente y una falla puede dejar cambios parciales.
-- Se omiten contrasenas y referencias de proveedores de pago en la bitacora.
-- La validacion de Olaf exige cancelacion o devolucion: tambien bloquea
-- reembolsos Adjustment y Goodwill sin esos vinculos.
USE `db_test`;

DELIMITER $$

CREATE TRIGGER `trg_after_insert_tb_order_cancellations` AFTER INSERT ON `tb_order_cancellations`
FOR EACH ROW
BEGIN
  INSERT INTO `tb_logs` (`table_name`, `operation`, `db_users`, `description`)
  VALUES ('tb_order_cancellations', 'Create', USER(), CONCAT('Registro creado. ID=', NEW.`ID`, ', datos=', JSON_OBJECT('ID', NEW.`ID` , 'order_ID', NEW.`order_ID` , 'requested_by_user_ID', NEW.`requested_by_user_ID` , 'cancellation_scope', NEW.`cancellation_scope` , 'reason_code', NEW.`reason_code` , 'reason_detail', NEW.`reason_detail` , 'cancellation_status', NEW.`cancellation_status` , 'requested_at', NEW.`requested_at` , 'reviewed_at', NEW.`reviewed_at` , 'completed_at', NEW.`completed_at` , 'internal_notes', NEW.`internal_notes` , 'creation_date', NEW.`creation_date` , 'last_update', NEW.`last_update` )));
END$$

CREATE TRIGGER `trg_after_update_tb_order_cancellations` AFTER UPDATE ON `tb_order_cancellations`
FOR EACH ROW
BEGIN
  INSERT INTO `tb_logs` (`table_name`, `operation`, `db_users`, `description`)
  VALUES ('tb_order_cancellations', 'Update', USER(), CONCAT('Registro actualizado. ID=', NEW.`ID`, ', datos=', JSON_OBJECT('before', JSON_OBJECT('ID', OLD.`ID` , 'order_ID', OLD.`order_ID` , 'requested_by_user_ID', OLD.`requested_by_user_ID` , 'cancellation_scope', OLD.`cancellation_scope` , 'reason_code', OLD.`reason_code` , 'reason_detail', OLD.`reason_detail` , 'cancellation_status', OLD.`cancellation_status` , 'requested_at', OLD.`requested_at` , 'reviewed_at', OLD.`reviewed_at` , 'completed_at', OLD.`completed_at` , 'internal_notes', OLD.`internal_notes` , 'creation_date', OLD.`creation_date` , 'last_update', OLD.`last_update` ), 'after', JSON_OBJECT('ID', NEW.`ID` , 'order_ID', NEW.`order_ID` , 'requested_by_user_ID', NEW.`requested_by_user_ID` , 'cancellation_scope', NEW.`cancellation_scope` , 'reason_code', NEW.`reason_code` , 'reason_detail', NEW.`reason_detail` , 'cancellation_status', NEW.`cancellation_status` , 'requested_at', NEW.`requested_at` , 'reviewed_at', NEW.`reviewed_at` , 'completed_at', NEW.`completed_at` , 'internal_notes', NEW.`internal_notes` , 'creation_date', NEW.`creation_date` , 'last_update', NEW.`last_update` ))));
END$$

CREATE TRIGGER `trg_after_delete_tb_order_cancellations` AFTER DELETE ON `tb_order_cancellations`
FOR EACH ROW
BEGIN
  INSERT INTO `tb_logs` (`table_name`, `operation`, `db_users`, `description`)
  VALUES ('tb_order_cancellations', 'Delete', USER(), CONCAT('Registro eliminado. ID=', OLD.`ID`, ', datos=', JSON_OBJECT('ID', OLD.`ID` , 'order_ID', OLD.`order_ID` , 'requested_by_user_ID', OLD.`requested_by_user_ID` , 'cancellation_scope', OLD.`cancellation_scope` , 'reason_code', OLD.`reason_code` , 'reason_detail', OLD.`reason_detail` , 'cancellation_status', OLD.`cancellation_status` , 'requested_at', OLD.`requested_at` , 'reviewed_at', OLD.`reviewed_at` , 'completed_at', OLD.`completed_at` , 'internal_notes', OLD.`internal_notes` , 'creation_date', OLD.`creation_date` , 'last_update', OLD.`last_update` )));
END$$

CREATE TRIGGER `trg_after_insert_tb_payment_methods` AFTER INSERT ON `tb_payment_methods`
FOR EACH ROW
BEGIN
  INSERT INTO `tb_logs` (`table_name`, `operation`, `db_users`, `description`)
  VALUES ('tb_payment_methods', 'Create', USER(), CONCAT('Registro creado. ID=', NEW.`ID`, ', datos=', JSON_OBJECT('ID', NEW.`ID` , 'name', NEW.`name` , 'description', NEW.`description` , 'status', CAST(NEW.`status` AS UNSIGNED) , 'creation_date', NEW.`creation_date` , 'last_update', NEW.`last_update` )));
END$$

CREATE TRIGGER `trg_after_update_tb_payment_methods` AFTER UPDATE ON `tb_payment_methods`
FOR EACH ROW
BEGIN
  INSERT INTO `tb_logs` (`table_name`, `operation`, `db_users`, `description`)
  VALUES ('tb_payment_methods', 'Update', USER(), CONCAT('Registro actualizado. ID=', NEW.`ID`, ', datos=', JSON_OBJECT('before', JSON_OBJECT('ID', OLD.`ID` , 'name', OLD.`name` , 'description', OLD.`description` , 'status', CAST(OLD.`status` AS UNSIGNED) , 'creation_date', OLD.`creation_date` , 'last_update', OLD.`last_update` ), 'after', JSON_OBJECT('ID', NEW.`ID` , 'name', NEW.`name` , 'description', NEW.`description` , 'status', CAST(NEW.`status` AS UNSIGNED) , 'creation_date', NEW.`creation_date` , 'last_update', NEW.`last_update` ))));
END$$

CREATE TRIGGER `trg_after_delete_tb_payment_methods` AFTER DELETE ON `tb_payment_methods`
FOR EACH ROW
BEGIN
  INSERT INTO `tb_logs` (`table_name`, `operation`, `db_users`, `description`)
  VALUES ('tb_payment_methods', 'Delete', USER(), CONCAT('Registro eliminado. ID=', OLD.`ID`, ', datos=', JSON_OBJECT('ID', OLD.`ID` , 'name', OLD.`name` , 'description', OLD.`description` , 'status', CAST(OLD.`status` AS UNSIGNED) , 'creation_date', OLD.`creation_date` , 'last_update', OLD.`last_update` )));
END$$

CREATE TRIGGER `trg_after_insert_tb_payment_transaction` AFTER INSERT ON `tb_payment_transaction`
FOR EACH ROW
BEGIN
  INSERT INTO `tb_logs` (`table_name`, `operation`, `db_users`, `description`)
  VALUES ('tb_payment_transaction', 'Create', USER(), CONCAT('Registro creado. ID=', NEW.`ID`, ', datos=', JSON_OBJECT('ID', NEW.`ID` , 'payment_ID', NEW.`payment_ID` , 'refund_ID', NEW.`refund_ID` , 'transaction_type', NEW.`transaction_type` , 'transaction_status', NEW.`transaction_status` , 'amount', NEW.`amount` , 'currency', NEW.`currency` , 'provider', NEW.`provider` , 'response_code', NEW.`response_code` , 'response_message', NEW.`response_message` , 'request_date', NEW.`request_date` , 'response_date', NEW.`response_date` , 'creation_date', NEW.`creation_date` , 'last_update', NEW.`last_update` )));
END$$

CREATE TRIGGER `trg_after_update_tb_payment_transaction` AFTER UPDATE ON `tb_payment_transaction`
FOR EACH ROW
BEGIN
  INSERT INTO `tb_logs` (`table_name`, `operation`, `db_users`, `description`)
  VALUES ('tb_payment_transaction', 'Update', USER(), CONCAT('Registro actualizado. ID=', NEW.`ID`, ', datos=', JSON_OBJECT('before', JSON_OBJECT('ID', OLD.`ID` , 'payment_ID', OLD.`payment_ID` , 'refund_ID', OLD.`refund_ID` , 'transaction_type', OLD.`transaction_type` , 'transaction_status', OLD.`transaction_status` , 'amount', OLD.`amount` , 'currency', OLD.`currency` , 'provider', OLD.`provider` , 'response_code', OLD.`response_code` , 'response_message', OLD.`response_message` , 'request_date', OLD.`request_date` , 'response_date', OLD.`response_date` , 'creation_date', OLD.`creation_date` , 'last_update', OLD.`last_update` ), 'after', JSON_OBJECT('ID', NEW.`ID` , 'payment_ID', NEW.`payment_ID` , 'refund_ID', NEW.`refund_ID` , 'transaction_type', NEW.`transaction_type` , 'transaction_status', NEW.`transaction_status` , 'amount', NEW.`amount` , 'currency', NEW.`currency` , 'provider', NEW.`provider` , 'response_code', NEW.`response_code` , 'response_message', NEW.`response_message` , 'request_date', NEW.`request_date` , 'response_date', NEW.`response_date` , 'creation_date', NEW.`creation_date` , 'last_update', NEW.`last_update` ))));
END$$

CREATE TRIGGER `trg_after_delete_tb_payment_transaction` AFTER DELETE ON `tb_payment_transaction`
FOR EACH ROW
BEGIN
  INSERT INTO `tb_logs` (`table_name`, `operation`, `db_users`, `description`)
  VALUES ('tb_payment_transaction', 'Delete', USER(), CONCAT('Registro eliminado. ID=', OLD.`ID`, ', datos=', JSON_OBJECT('ID', OLD.`ID` , 'payment_ID', OLD.`payment_ID` , 'refund_ID', OLD.`refund_ID` , 'transaction_type', OLD.`transaction_type` , 'transaction_status', OLD.`transaction_status` , 'amount', OLD.`amount` , 'currency', OLD.`currency` , 'provider', OLD.`provider` , 'response_code', OLD.`response_code` , 'response_message', OLD.`response_message` , 'request_date', OLD.`request_date` , 'response_date', OLD.`response_date` , 'creation_date', OLD.`creation_date` , 'last_update', OLD.`last_update` )));
END$$

CREATE TRIGGER `trg_after_insert_tb_payments` AFTER INSERT ON `tb_payments`
FOR EACH ROW
BEGIN
  INSERT INTO `tb_logs` (`table_name`, `operation`, `db_users`, `description`)
  VALUES ('tb_payments', 'Create', USER(), CONCAT('Registro creado. ID=', NEW.`ID`, ', datos=', JSON_OBJECT('ID', NEW.`ID` , 'order_ID', NEW.`order_ID` , 'payment_method_ID', NEW.`payment_method_ID` , 'amount', NEW.`amount` , 'currency', NEW.`currency` , 'payment_status', NEW.`payment_status` , 'provider', NEW.`provider` , 'creation_date', NEW.`creation_date` , 'paid_date', NEW.`paid_date` , 'last_update', NEW.`last_update` )));
END$$

CREATE TRIGGER `trg_after_update_tb_payments` AFTER UPDATE ON `tb_payments`
FOR EACH ROW
BEGIN
  INSERT INTO `tb_logs` (`table_name`, `operation`, `db_users`, `description`)
  VALUES ('tb_payments', 'Update', USER(), CONCAT('Registro actualizado. ID=', NEW.`ID`, ', datos=', JSON_OBJECT('before', JSON_OBJECT('ID', OLD.`ID` , 'order_ID', OLD.`order_ID` , 'payment_method_ID', OLD.`payment_method_ID` , 'amount', OLD.`amount` , 'currency', OLD.`currency` , 'payment_status', OLD.`payment_status` , 'provider', OLD.`provider` , 'creation_date', OLD.`creation_date` , 'paid_date', OLD.`paid_date` , 'last_update', OLD.`last_update` ), 'after', JSON_OBJECT('ID', NEW.`ID` , 'order_ID', NEW.`order_ID` , 'payment_method_ID', NEW.`payment_method_ID` , 'amount', NEW.`amount` , 'currency', NEW.`currency` , 'payment_status', NEW.`payment_status` , 'provider', NEW.`provider` , 'creation_date', NEW.`creation_date` , 'paid_date', NEW.`paid_date` , 'last_update', NEW.`last_update` ))));
END$$

CREATE TRIGGER `trg_after_delete_tb_payments` AFTER DELETE ON `tb_payments`
FOR EACH ROW
BEGIN
  INSERT INTO `tb_logs` (`table_name`, `operation`, `db_users`, `description`)
  VALUES ('tb_payments', 'Delete', USER(), CONCAT('Registro eliminado. ID=', OLD.`ID`, ', datos=', JSON_OBJECT('ID', OLD.`ID` , 'order_ID', OLD.`order_ID` , 'payment_method_ID', OLD.`payment_method_ID` , 'amount', OLD.`amount` , 'currency', OLD.`currency` , 'payment_status', OLD.`payment_status` , 'provider', OLD.`provider` , 'creation_date', OLD.`creation_date` , 'paid_date', OLD.`paid_date` , 'last_update', OLD.`last_update` )));
END$$

CREATE TRIGGER `trg_after_insert_tb_people` AFTER INSERT ON `tb_people`
FOR EACH ROW
BEGIN
  INSERT INTO `tb_logs` (`table_name`, `operation`, `db_users`, `description`)
  VALUES ('tb_people', 'Create', USER(), CONCAT('Registro creado. ID=', NEW.`person_ID`, ', datos=', JSON_OBJECT('person_ID', NEW.`person_ID` , 'user_ID', NEW.`user_ID` , 'title', NEW.`title` , 'given_names', NEW.`given_names` , 'family_names', NEW.`family_names` , 'birth_date', NEW.`birth_date` , 'gender_ID', NEW.`gender_ID` , 'phone', NEW.`phone` , 'country_code', NEW.`country_code` , 'status', CAST(NEW.`status` AS UNSIGNED) , 'creation_date', NEW.`creation_date` , 'last_update', NEW.`last_update` )));
END$$

CREATE TRIGGER `trg_after_update_tb_people` AFTER UPDATE ON `tb_people`
FOR EACH ROW
BEGIN
  INSERT INTO `tb_logs` (`table_name`, `operation`, `db_users`, `description`)
  VALUES ('tb_people', 'Update', USER(), CONCAT('Registro actualizado. ID=', NEW.`person_ID`, ', datos=', JSON_OBJECT('before', JSON_OBJECT('person_ID', OLD.`person_ID` , 'user_ID', OLD.`user_ID` , 'title', OLD.`title` , 'given_names', OLD.`given_names` , 'family_names', OLD.`family_names` , 'birth_date', OLD.`birth_date` , 'gender_ID', OLD.`gender_ID` , 'phone', OLD.`phone` , 'country_code', OLD.`country_code` , 'status', CAST(OLD.`status` AS UNSIGNED) , 'creation_date', OLD.`creation_date` , 'last_update', OLD.`last_update` ), 'after', JSON_OBJECT('person_ID', NEW.`person_ID` , 'user_ID', NEW.`user_ID` , 'title', NEW.`title` , 'given_names', NEW.`given_names` , 'family_names', NEW.`family_names` , 'birth_date', NEW.`birth_date` , 'gender_ID', NEW.`gender_ID` , 'phone', NEW.`phone` , 'country_code', NEW.`country_code` , 'status', CAST(NEW.`status` AS UNSIGNED) , 'creation_date', NEW.`creation_date` , 'last_update', NEW.`last_update` ))));
END$$

CREATE TRIGGER `trg_after_delete_tb_people` AFTER DELETE ON `tb_people`
FOR EACH ROW
BEGIN
  INSERT INTO `tb_logs` (`table_name`, `operation`, `db_users`, `description`)
  VALUES ('tb_people', 'Delete', USER(), CONCAT('Registro eliminado. ID=', OLD.`person_ID`, ', datos=', JSON_OBJECT('person_ID', OLD.`person_ID` , 'user_ID', OLD.`user_ID` , 'title', OLD.`title` , 'given_names', OLD.`given_names` , 'family_names', OLD.`family_names` , 'birth_date', OLD.`birth_date` , 'gender_ID', OLD.`gender_ID` , 'phone', OLD.`phone` , 'country_code', OLD.`country_code` , 'status', CAST(OLD.`status` AS UNSIGNED) , 'creation_date', OLD.`creation_date` , 'last_update', OLD.`last_update` )));
END$$

CREATE TRIGGER `trg_after_insert_tb_products` AFTER INSERT ON `tb_products`
FOR EACH ROW
BEGIN
  INSERT INTO `tb_logs` (`table_name`, `operation`, `db_users`, `description`)
  VALUES ('tb_products', 'Create', USER(), CONCAT('Registro creado. ID=', NEW.`ID`, ', datos=', JSON_OBJECT('ID', NEW.`ID` , 'SKU', NEW.`SKU` , 'name', NEW.`name` , 'description', NEW.`description` , 'current_price', NEW.`current_price` , 'current_stock', NEW.`current_stock` , 'status', NEW.`status` , 'creation_date', NEW.`creation_date` , 'last_update', NEW.`last_update` )));
END$$

CREATE TRIGGER `trg_after_update_tb_products` AFTER UPDATE ON `tb_products`
FOR EACH ROW
BEGIN
  INSERT INTO `tb_logs` (`table_name`, `operation`, `db_users`, `description`)
  VALUES ('tb_products', 'Update', USER(), CONCAT('Registro actualizado. ID=', NEW.`ID`, ', datos=', JSON_OBJECT('before', JSON_OBJECT('ID', OLD.`ID` , 'SKU', OLD.`SKU` , 'name', OLD.`name` , 'description', OLD.`description` , 'current_price', OLD.`current_price` , 'current_stock', OLD.`current_stock` , 'status', OLD.`status` , 'creation_date', OLD.`creation_date` , 'last_update', OLD.`last_update` ), 'after', JSON_OBJECT('ID', NEW.`ID` , 'SKU', NEW.`SKU` , 'name', NEW.`name` , 'description', NEW.`description` , 'current_price', NEW.`current_price` , 'current_stock', NEW.`current_stock` , 'status', NEW.`status` , 'creation_date', NEW.`creation_date` , 'last_update', NEW.`last_update` ))));
END$$

CREATE TRIGGER `trg_after_delete_tb_products` AFTER DELETE ON `tb_products`
FOR EACH ROW
BEGIN
  INSERT INTO `tb_logs` (`table_name`, `operation`, `db_users`, `description`)
  VALUES ('tb_products', 'Delete', USER(), CONCAT('Registro eliminado. ID=', OLD.`ID`, ', datos=', JSON_OBJECT('ID', OLD.`ID` , 'SKU', OLD.`SKU` , 'name', OLD.`name` , 'description', OLD.`description` , 'current_price', OLD.`current_price` , 'current_stock', OLD.`current_stock` , 'status', OLD.`status` , 'creation_date', OLD.`creation_date` , 'last_update', OLD.`last_update` )));
END$$

CREATE TRIGGER `trg_after_insert_tb_refunds` AFTER INSERT ON `tb_refunds`
FOR EACH ROW
BEGIN
  INSERT INTO `tb_logs` (`table_name`, `operation`, `db_users`, `description`)
  VALUES ('tb_refunds', 'Create', USER(), CONCAT('Registro creado. ID=', NEW.`ID`, ', datos=', JSON_OBJECT('ID', NEW.`ID` , 'payment_ID', NEW.`payment_ID` , 'cancellation_ID', NEW.`cancellation_ID` , 'return_ID', NEW.`return_ID` , 'reason', NEW.`reason` , 'amount', NEW.`amount` , 'currency', NEW.`currency` , 'refund_status', NEW.`refund_status` , 'provider', NEW.`provider` , 'requested_by_user_ID', NEW.`requested_by_user_ID` , 'reason_detail', NEW.`reason_detail` , 'requested_at', NEW.`requested_at` , 'processed_at', NEW.`processed_at` , 'creation_date', NEW.`creation_date` , 'last_update', NEW.`last_update` )));
END$$

CREATE TRIGGER `trg_after_update_tb_refunds` AFTER UPDATE ON `tb_refunds`
FOR EACH ROW
BEGIN
  INSERT INTO `tb_logs` (`table_name`, `operation`, `db_users`, `description`)
  VALUES ('tb_refunds', 'Update', USER(), CONCAT('Registro actualizado. ID=', NEW.`ID`, ', datos=', JSON_OBJECT('before', JSON_OBJECT('ID', OLD.`ID` , 'payment_ID', OLD.`payment_ID` , 'cancellation_ID', OLD.`cancellation_ID` , 'return_ID', OLD.`return_ID` , 'reason', OLD.`reason` , 'amount', OLD.`amount` , 'currency', OLD.`currency` , 'refund_status', OLD.`refund_status` , 'provider', OLD.`provider` , 'requested_by_user_ID', OLD.`requested_by_user_ID` , 'reason_detail', OLD.`reason_detail` , 'requested_at', OLD.`requested_at` , 'processed_at', OLD.`processed_at` , 'creation_date', OLD.`creation_date` , 'last_update', OLD.`last_update` ), 'after', JSON_OBJECT('ID', NEW.`ID` , 'payment_ID', NEW.`payment_ID` , 'cancellation_ID', NEW.`cancellation_ID` , 'return_ID', NEW.`return_ID` , 'reason', NEW.`reason` , 'amount', NEW.`amount` , 'currency', NEW.`currency` , 'refund_status', NEW.`refund_status` , 'provider', NEW.`provider` , 'requested_by_user_ID', NEW.`requested_by_user_ID` , 'reason_detail', NEW.`reason_detail` , 'requested_at', NEW.`requested_at` , 'processed_at', NEW.`processed_at` , 'creation_date', NEW.`creation_date` , 'last_update', NEW.`last_update` ))));
END$$

CREATE TRIGGER `trg_after_delete_tb_refunds` AFTER DELETE ON `tb_refunds`
FOR EACH ROW
BEGIN
  INSERT INTO `tb_logs` (`table_name`, `operation`, `db_users`, `description`)
  VALUES ('tb_refunds', 'Delete', USER(), CONCAT('Registro eliminado. ID=', OLD.`ID`, ', datos=', JSON_OBJECT('ID', OLD.`ID` , 'payment_ID', OLD.`payment_ID` , 'cancellation_ID', OLD.`cancellation_ID` , 'return_ID', OLD.`return_ID` , 'reason', OLD.`reason` , 'amount', OLD.`amount` , 'currency', OLD.`currency` , 'refund_status', OLD.`refund_status` , 'provider', OLD.`provider` , 'requested_by_user_ID', OLD.`requested_by_user_ID` , 'reason_detail', OLD.`reason_detail` , 'requested_at', OLD.`requested_at` , 'processed_at', OLD.`processed_at` , 'creation_date', OLD.`creation_date` , 'last_update', OLD.`last_update` )));
END$$

CREATE TRIGGER `trg_after_insert_tb_returns` AFTER INSERT ON `tb_returns`
FOR EACH ROW
BEGIN
  INSERT INTO `tb_logs` (`table_name`, `operation`, `db_users`, `description`)
  VALUES ('tb_returns', 'Create', USER(), CONCAT('Registro creado. ID=', NEW.`ID`, ', datos=', JSON_OBJECT('ID', NEW.`ID` , 'order_ID', NEW.`order_ID` , 'requested_by_user_ID', NEW.`requested_by_user_ID` , 'reason_code', NEW.`reason_code` , 'reason_detail', NEW.`reason_detail` , 'return_status', NEW.`return_status` , 'return_carrier', NEW.`return_carrier` , 'return_tracking_number', NEW.`return_tracking_number` , 'requested_at', NEW.`requested_at` , 'authorized_at', NEW.`authorized_at` , 'received_at', NEW.`received_at` , 'closed_at', NEW.`closed_at` , 'internal_notes', NEW.`internal_notes` , 'creation_date', NEW.`creation_date` , 'last_update', NEW.`last_update` )));
END$$

CREATE TRIGGER `trg_after_update_tb_returns` AFTER UPDATE ON `tb_returns`
FOR EACH ROW
BEGIN
  INSERT INTO `tb_logs` (`table_name`, `operation`, `db_users`, `description`)
  VALUES ('tb_returns', 'Update', USER(), CONCAT('Registro actualizado. ID=', NEW.`ID`, ', datos=', JSON_OBJECT('before', JSON_OBJECT('ID', OLD.`ID` , 'order_ID', OLD.`order_ID` , 'requested_by_user_ID', OLD.`requested_by_user_ID` , 'reason_code', OLD.`reason_code` , 'reason_detail', OLD.`reason_detail` , 'return_status', OLD.`return_status` , 'return_carrier', OLD.`return_carrier` , 'return_tracking_number', OLD.`return_tracking_number` , 'requested_at', OLD.`requested_at` , 'authorized_at', OLD.`authorized_at` , 'received_at', OLD.`received_at` , 'closed_at', OLD.`closed_at` , 'internal_notes', OLD.`internal_notes` , 'creation_date', OLD.`creation_date` , 'last_update', OLD.`last_update` ), 'after', JSON_OBJECT('ID', NEW.`ID` , 'order_ID', NEW.`order_ID` , 'requested_by_user_ID', NEW.`requested_by_user_ID` , 'reason_code', NEW.`reason_code` , 'reason_detail', NEW.`reason_detail` , 'return_status', NEW.`return_status` , 'return_carrier', NEW.`return_carrier` , 'return_tracking_number', NEW.`return_tracking_number` , 'requested_at', NEW.`requested_at` , 'authorized_at', NEW.`authorized_at` , 'received_at', NEW.`received_at` , 'closed_at', NEW.`closed_at` , 'internal_notes', NEW.`internal_notes` , 'creation_date', NEW.`creation_date` , 'last_update', NEW.`last_update` ))));
END$$

CREATE TRIGGER `trg_after_delete_tb_returns` AFTER DELETE ON `tb_returns`
FOR EACH ROW
BEGIN
  INSERT INTO `tb_logs` (`table_name`, `operation`, `db_users`, `description`)
  VALUES ('tb_returns', 'Delete', USER(), CONCAT('Registro eliminado. ID=', OLD.`ID`, ', datos=', JSON_OBJECT('ID', OLD.`ID` , 'order_ID', OLD.`order_ID` , 'requested_by_user_ID', OLD.`requested_by_user_ID` , 'reason_code', OLD.`reason_code` , 'reason_detail', OLD.`reason_detail` , 'return_status', OLD.`return_status` , 'return_carrier', OLD.`return_carrier` , 'return_tracking_number', OLD.`return_tracking_number` , 'requested_at', OLD.`requested_at` , 'authorized_at', OLD.`authorized_at` , 'received_at', OLD.`received_at` , 'closed_at', OLD.`closed_at` , 'internal_notes', OLD.`internal_notes` , 'creation_date', OLD.`creation_date` , 'last_update', OLD.`last_update` )));
END$$

CREATE TRIGGER `trg_after_insert_tb_shipments` AFTER INSERT ON `tb_shipments`
FOR EACH ROW
BEGIN
  INSERT INTO `tb_logs` (`table_name`, `operation`, `db_users`, `description`)
  VALUES ('tb_shipments', 'Create', USER(), CONCAT('Registro creado. ID=', NEW.`ID`, ', datos=', JSON_OBJECT('ID', NEW.`ID` , 'order_ID', NEW.`order_ID` , 'address_ID', NEW.`address_ID` , 'recipient_name', NEW.`recipient_name` , 'recipient_phone', NEW.`recipient_phone` , 'address_line_1', NEW.`address_line_1` , 'address_line_2', NEW.`address_line_2` , 'city', NEW.`city` , 'state_region', NEW.`state_region` , 'postal_code', NEW.`postal_code` , 'country_code', NEW.`country_code` , 'carrier', NEW.`carrier` , 'service_level', NEW.`service_level` , 'tracking_number', NEW.`tracking_number` , 'tracking_url', NEW.`tracking_url` , 'shipment_status', NEW.`shipment_status` , 'shipping_cost', NEW.`shipping_cost` , 'shipped_at', NEW.`shipped_at` , 'estimated_delivery_at', NEW.`estimated_delivery_at` , 'delivered_at', NEW.`delivered_at` , 'creation_date', NEW.`creation_date` , 'last_update', NEW.`last_update` )));
END$$

CREATE TRIGGER `trg_after_update_tb_shipments` AFTER UPDATE ON `tb_shipments`
FOR EACH ROW
BEGIN
  INSERT INTO `tb_logs` (`table_name`, `operation`, `db_users`, `description`)
  VALUES ('tb_shipments', 'Update', USER(), CONCAT('Registro actualizado. ID=', NEW.`ID`, ', datos=', JSON_OBJECT('before', JSON_OBJECT('ID', OLD.`ID` , 'order_ID', OLD.`order_ID` , 'address_ID', OLD.`address_ID` , 'recipient_name', OLD.`recipient_name` , 'recipient_phone', OLD.`recipient_phone` , 'address_line_1', OLD.`address_line_1` , 'address_line_2', OLD.`address_line_2` , 'city', OLD.`city` , 'state_region', OLD.`state_region` , 'postal_code', OLD.`postal_code` , 'country_code', OLD.`country_code` , 'carrier', OLD.`carrier` , 'service_level', OLD.`service_level` , 'tracking_number', OLD.`tracking_number` , 'tracking_url', OLD.`tracking_url` , 'shipment_status', OLD.`shipment_status` , 'shipping_cost', OLD.`shipping_cost` , 'shipped_at', OLD.`shipped_at` , 'estimated_delivery_at', OLD.`estimated_delivery_at` , 'delivered_at', OLD.`delivered_at` , 'creation_date', OLD.`creation_date` , 'last_update', OLD.`last_update` ), 'after', JSON_OBJECT('ID', NEW.`ID` , 'order_ID', NEW.`order_ID` , 'address_ID', NEW.`address_ID` , 'recipient_name', NEW.`recipient_name` , 'recipient_phone', NEW.`recipient_phone` , 'address_line_1', NEW.`address_line_1` , 'address_line_2', NEW.`address_line_2` , 'city', NEW.`city` , 'state_region', NEW.`state_region` , 'postal_code', NEW.`postal_code` , 'country_code', NEW.`country_code` , 'carrier', NEW.`carrier` , 'service_level', NEW.`service_level` , 'tracking_number', NEW.`tracking_number` , 'tracking_url', NEW.`tracking_url` , 'shipment_status', NEW.`shipment_status` , 'shipping_cost', NEW.`shipping_cost` , 'shipped_at', NEW.`shipped_at` , 'estimated_delivery_at', NEW.`estimated_delivery_at` , 'delivered_at', NEW.`delivered_at` , 'creation_date', NEW.`creation_date` , 'last_update', NEW.`last_update` ))));
END$$

CREATE TRIGGER `trg_after_delete_tb_shipments` AFTER DELETE ON `tb_shipments`
FOR EACH ROW
BEGIN
  INSERT INTO `tb_logs` (`table_name`, `operation`, `db_users`, `description`)
  VALUES ('tb_shipments', 'Delete', USER(), CONCAT('Registro eliminado. ID=', OLD.`ID`, ', datos=', JSON_OBJECT('ID', OLD.`ID` , 'order_ID', OLD.`order_ID` , 'address_ID', OLD.`address_ID` , 'recipient_name', OLD.`recipient_name` , 'recipient_phone', OLD.`recipient_phone` , 'address_line_1', OLD.`address_line_1` , 'address_line_2', OLD.`address_line_2` , 'city', OLD.`city` , 'state_region', OLD.`state_region` , 'postal_code', OLD.`postal_code` , 'country_code', OLD.`country_code` , 'carrier', OLD.`carrier` , 'service_level', OLD.`service_level` , 'tracking_number', OLD.`tracking_number` , 'tracking_url', OLD.`tracking_url` , 'shipment_status', OLD.`shipment_status` , 'shipping_cost', OLD.`shipping_cost` , 'shipped_at', OLD.`shipped_at` , 'estimated_delivery_at', OLD.`estimated_delivery_at` , 'delivered_at', OLD.`delivered_at` , 'creation_date', OLD.`creation_date` , 'last_update', OLD.`last_update` )));
END$$

CREATE TRIGGER `trg_after_insert_tb_users` AFTER INSERT ON `tb_users`
FOR EACH ROW
BEGIN
  INSERT INTO `tb_logs` (`table_name`, `operation`, `db_users`, `description`)
  VALUES ('tb_users', 'Create', USER(), CONCAT('Registro creado. ID=', NEW.`ID`, ', datos=', JSON_OBJECT('ID', NEW.`ID` , 'email', NEW.`email` , 'nickname', NEW.`nickname` , 'creation_date', NEW.`creation_date` , 'last_update', NEW.`last_update` , 'last_login', NEW.`last_login` )));
END$$

CREATE TRIGGER `trg_after_update_tb_users` AFTER UPDATE ON `tb_users`
FOR EACH ROW
BEGIN
  INSERT INTO `tb_logs` (`table_name`, `operation`, `db_users`, `description`)
  VALUES ('tb_users', 'Update', USER(), CONCAT('Registro actualizado. ID=', NEW.`ID`, ', datos=', JSON_OBJECT('before', JSON_OBJECT('ID', OLD.`ID` , 'email', OLD.`email` , 'nickname', OLD.`nickname` , 'creation_date', OLD.`creation_date` , 'last_update', OLD.`last_update` , 'last_login', OLD.`last_login` ), 'after', JSON_OBJECT('ID', NEW.`ID` , 'email', NEW.`email` , 'nickname', NEW.`nickname` , 'creation_date', NEW.`creation_date` , 'last_update', NEW.`last_update` , 'last_login', NEW.`last_login` ))));
END$$

CREATE TRIGGER `trg_after_delete_tb_users` AFTER DELETE ON `tb_users`
FOR EACH ROW
BEGIN
  INSERT INTO `tb_logs` (`table_name`, `operation`, `db_users`, `description`)
  VALUES ('tb_users', 'Delete', USER(), CONCAT('Registro eliminado. ID=', OLD.`ID`, ', datos=', JSON_OBJECT('ID', OLD.`ID` , 'email', OLD.`email` , 'nickname', OLD.`nickname` , 'creation_date', OLD.`creation_date` , 'last_update', OLD.`last_update` , 'last_login', OLD.`last_login` )));
END$$

CREATE TRIGGER `trg_after_insert_tbd_cancellation_items` AFTER INSERT ON `tbd_cancellation_items`
FOR EACH ROW
BEGIN
  INSERT INTO `tb_logs` (`table_name`, `operation`, `db_users`, `description`)
  VALUES ('tbd_cancellation_items', 'Create', USER(), CONCAT('Registro creado. ID=', NEW.`ID`, ', datos=', JSON_OBJECT('ID', NEW.`ID` , 'cancellation_ID', NEW.`cancellation_ID` , 'order_item_ID', NEW.`order_item_ID` , 'quantity', NEW.`quantity` , 'creation_date', NEW.`creation_date` )));
END$$

CREATE TRIGGER `trg_after_update_tbd_cancellation_items` AFTER UPDATE ON `tbd_cancellation_items`
FOR EACH ROW
BEGIN
  INSERT INTO `tb_logs` (`table_name`, `operation`, `db_users`, `description`)
  VALUES ('tbd_cancellation_items', 'Update', USER(), CONCAT('Registro actualizado. ID=', NEW.`ID`, ', datos=', JSON_OBJECT('before', JSON_OBJECT('ID', OLD.`ID` , 'cancellation_ID', OLD.`cancellation_ID` , 'order_item_ID', OLD.`order_item_ID` , 'quantity', OLD.`quantity` , 'creation_date', OLD.`creation_date` ), 'after', JSON_OBJECT('ID', NEW.`ID` , 'cancellation_ID', NEW.`cancellation_ID` , 'order_item_ID', NEW.`order_item_ID` , 'quantity', NEW.`quantity` , 'creation_date', NEW.`creation_date` ))));
END$$

CREATE TRIGGER `trg_after_delete_tbd_cancellation_items` AFTER DELETE ON `tbd_cancellation_items`
FOR EACH ROW
BEGIN
  INSERT INTO `tb_logs` (`table_name`, `operation`, `db_users`, `description`)
  VALUES ('tbd_cancellation_items', 'Delete', USER(), CONCAT('Registro eliminado. ID=', OLD.`ID`, ', datos=', JSON_OBJECT('ID', OLD.`ID` , 'cancellation_ID', OLD.`cancellation_ID` , 'order_item_ID', OLD.`order_item_ID` , 'quantity', OLD.`quantity` , 'creation_date', OLD.`creation_date` )));
END$$

CREATE TRIGGER `trg_after_insert_tbd_return_items` AFTER INSERT ON `tbd_return_items`
FOR EACH ROW
BEGIN
  INSERT INTO `tb_logs` (`table_name`, `operation`, `db_users`, `description`)
  VALUES ('tbd_return_items', 'Create', USER(), CONCAT('Registro creado. ID=', NEW.`ID`, ', datos=', JSON_OBJECT('ID', NEW.`ID` , 'return_ID', NEW.`return_ID` , 'order_item_ID', NEW.`order_item_ID` , 'quantity', NEW.`quantity` , 'item_condition', NEW.`item_condition` , 'disposition', NEW.`disposition` , 'approved_refund_amount', NEW.`approved_refund_amount` , 'item_status', NEW.`item_status` , 'creation_date', NEW.`creation_date` , 'last_update', NEW.`last_update` )));
END$$

CREATE TRIGGER `trg_after_update_tbd_return_items` AFTER UPDATE ON `tbd_return_items`
FOR EACH ROW
BEGIN
  INSERT INTO `tb_logs` (`table_name`, `operation`, `db_users`, `description`)
  VALUES ('tbd_return_items', 'Update', USER(), CONCAT('Registro actualizado. ID=', NEW.`ID`, ', datos=', JSON_OBJECT('before', JSON_OBJECT('ID', OLD.`ID` , 'return_ID', OLD.`return_ID` , 'order_item_ID', OLD.`order_item_ID` , 'quantity', OLD.`quantity` , 'item_condition', OLD.`item_condition` , 'disposition', OLD.`disposition` , 'approved_refund_amount', OLD.`approved_refund_amount` , 'item_status', OLD.`item_status` , 'creation_date', OLD.`creation_date` , 'last_update', OLD.`last_update` ), 'after', JSON_OBJECT('ID', NEW.`ID` , 'return_ID', NEW.`return_ID` , 'order_item_ID', NEW.`order_item_ID` , 'quantity', NEW.`quantity` , 'item_condition', NEW.`item_condition` , 'disposition', NEW.`disposition` , 'approved_refund_amount', NEW.`approved_refund_amount` , 'item_status', NEW.`item_status` , 'creation_date', NEW.`creation_date` , 'last_update', NEW.`last_update` ))));
END$$

CREATE TRIGGER `trg_after_delete_tbd_return_items` AFTER DELETE ON `tbd_return_items`
FOR EACH ROW
BEGIN
  INSERT INTO `tb_logs` (`table_name`, `operation`, `db_users`, `description`)
  VALUES ('tbd_return_items', 'Delete', USER(), CONCAT('Registro eliminado. ID=', OLD.`ID`, ', datos=', JSON_OBJECT('ID', OLD.`ID` , 'return_ID', OLD.`return_ID` , 'order_item_ID', OLD.`order_item_ID` , 'quantity', OLD.`quantity` , 'item_condition', OLD.`item_condition` , 'disposition', OLD.`disposition` , 'approved_refund_amount', OLD.`approved_refund_amount` , 'item_status', OLD.`item_status` , 'creation_date', OLD.`creation_date` , 'last_update', OLD.`last_update` )));
END$$

CREATE TRIGGER `trg_tb_refunds_validate_insert` BEFORE INSERT ON `tb_refunds`
FOR EACH ROW
BEGIN
  IF NEW.`return_ID` IS NULL AND NEW.`cancellation_ID` IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El reembolso debe asociarse a una devolucion o cancelacion';
  END IF;
END$$

CREATE TRIGGER `trg_tb_refunds_validate_update` BEFORE UPDATE ON `tb_refunds`
FOR EACH ROW
BEGIN
  IF NEW.`return_ID` IS NULL AND NEW.`cancellation_ID` IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El reembolso debe asociarse a una devolucion o cancelacion';
  END IF;
END$$

DELIMITER ;

-- Verificar despues de ejecutar: se esperan 77 si antes habia 39.
SELECT COUNT(*) AS total_triggers FROM information_schema.TRIGGERS WHERE TRIGGER_SCHEMA = 'db_test';
SELECT EVENT_OBJECT_TABLE, ACTION_TIMING, EVENT_MANIPULATION, TRIGGER_NAME
FROM information_schema.TRIGGERS WHERE TRIGGER_SCHEMA = 'db_test'
ORDER BY EVENT_OBJECT_TABLE, ACTION_TIMING, EVENT_MANIPULATION;
