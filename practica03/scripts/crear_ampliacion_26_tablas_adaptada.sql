-- Adaptacion al esquema de backups/respaldo10_20.sql (16 tablas existentes).
-- Fuente: Crear_26_tablas_db_test.sql. Se conserva el original sin modificaciones.
-- Agrega 10 tablas: resultado esperado, 26 tablas de negocio en total.
-- Ejecutar SOLO si el servidor coincide con el respaldo y estas tablas no existen.
-- No migra al modelo multivendedor del original. No cambia las tablas existentes.
-- No incluye datos, triggers, vistas ni permisos nuevos.
-- MySQL 8.0.36; DDL hace COMMIT implicito. Obtener respaldo antes de ejecutar.
-- No ejecutar ignorando errores. No repetir tras una ejecucion parcial.
USE `db_test`;

-- Nueva tabla: tb_people
CREATE TABLE `tb_people` (
  `person_ID` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_ID` int NOT NULL,
  `title` varchar(30) DEFAULT NULL,
  `given_names` varchar(150) NOT NULL,
  `family_names` varchar(150) DEFAULT NULL,
  `birth_date` date DEFAULT NULL,
  `gender_ID` enum('H','M','Prefiero no decirlo') DEFAULT NULL,
  `phone` varchar(25) DEFAULT NULL,
  `country_code` char(2) DEFAULT NULL,
  `status` bit(1) NOT NULL DEFAULT b'1',
  `creation_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_update` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`person_ID`),
  KEY `idx_people_user_ID` (`user_ID`),
  CONSTRAINT `fk_people_user` FOREIGN KEY (`user_ID`) REFERENCES `tb_users` (`ID`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Nueva tabla: tb_payment_methods
CREATE TABLE `tb_payment_methods` (
  `ID` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(60) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `status` bit(1) NOT NULL DEFAULT b'1',
  `creation_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_update` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `uk_payment_method_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Nueva tabla: tb_payments
CREATE TABLE `tb_payments` (
  `ID` int unsigned NOT NULL AUTO_INCREMENT,
  `order_ID` int unsigned NOT NULL,
  `payment_method_ID` int unsigned NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `currency` char(3) NOT NULL DEFAULT 'MXN',
  `payment_status` enum('Pending','Authorized','Paid','Failed','Refunded','PartiallyRefunded') NOT NULL DEFAULT 'Pending',
  `provider` varchar(60) DEFAULT NULL,
  `provider_reference` varchar(150) DEFAULT NULL,
  `creation_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `paid_date` datetime DEFAULT NULL,
  `last_update` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `uk_payment_provider_reference` (`provider`,`provider_reference`),
  KEY `idx_payment_order` (`order_ID`),
  KEY `fk_payment_method` (`payment_method_ID`),
  CONSTRAINT `fk_payment_method` FOREIGN KEY (`payment_method_ID`) REFERENCES `tb_payment_methods` (`ID`),
  CONSTRAINT `fk_payment_order` FOREIGN KEY (`order_ID`) REFERENCES `tb_buyer_orders` (`ID`),
  CONSTRAINT `chk_payment_amount` CHECK ((`amount` > 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Nueva tabla: tb_order_cancellations
CREATE TABLE `tb_order_cancellations` (
  `ID` int unsigned NOT NULL AUTO_INCREMENT,
  `order_ID` int unsigned NOT NULL,
  `requested_by_user_ID` int DEFAULT NULL,
  `cancellation_scope` enum('WholeOrder','Items') NOT NULL DEFAULT 'WholeOrder',
  `reason_code` varchar(60) DEFAULT NULL,
  `reason_detail` varchar(1000) DEFAULT NULL,
  `cancellation_status` enum('Requested','Approved','Rejected','Completed') NOT NULL DEFAULT 'Requested',
  `requested_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `reviewed_at` datetime DEFAULT NULL,
  `completed_at` datetime DEFAULT NULL,
  `internal_notes` varchar(1000) DEFAULT NULL,
  `creation_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_update` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`),
  KEY `idx_cancellations_order` (`order_ID`),
  KEY `idx_cancellations_requester` (`requested_by_user_ID`),
  CONSTRAINT `fk_cancellations_order` FOREIGN KEY (`order_ID`) REFERENCES `tb_buyer_orders` (`ID`),
  CONSTRAINT `fk_cancellations_requester` FOREIGN KEY (`requested_by_user_ID`) REFERENCES `tb_users` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Nueva tabla: tb_returns
CREATE TABLE `tb_returns` (
  `ID` int unsigned NOT NULL AUTO_INCREMENT,
  `order_ID` int unsigned NOT NULL,
  `requested_by_user_ID` int DEFAULT NULL,
  `reason_code` varchar(60) DEFAULT NULL,
  `reason_detail` varchar(1000) DEFAULT NULL,
  `return_status` enum('Requested','Authorized','Rejected','LabelCreated','InTransit','Received','Inspected','Approved','PartiallyApproved','Refunded','Closed') NOT NULL DEFAULT 'Requested',
  `return_carrier` varchar(100) DEFAULT NULL,
  `return_tracking_number` varchar(150) DEFAULT NULL,
  `requested_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `authorized_at` datetime DEFAULT NULL,
  `received_at` datetime DEFAULT NULL,
  `closed_at` datetime DEFAULT NULL,
  `internal_notes` varchar(1000) DEFAULT NULL,
  `creation_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_update` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`),
  KEY `idx_returns_order` (`order_ID`),
  KEY `idx_returns_requester` (`requested_by_user_ID`),
  KEY `idx_returns_tracking` (`return_carrier`,`return_tracking_number`),
  CONSTRAINT `fk_returns_order` FOREIGN KEY (`order_ID`) REFERENCES `tb_buyer_orders` (`ID`),
  CONSTRAINT `fk_returns_requester` FOREIGN KEY (`requested_by_user_ID`) REFERENCES `tb_users` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Nueva tabla: tb_shipments
CREATE TABLE `tb_shipments` (
  `ID` int unsigned NOT NULL AUTO_INCREMENT,
  `order_ID` int unsigned NOT NULL,
  `address_ID` int unsigned DEFAULT NULL,
  `recipient_name` varchar(150) DEFAULT NULL,
  `recipient_phone` varchar(25) DEFAULT NULL,
  `address_line_1` varchar(255) DEFAULT NULL,
  `address_line_2` varchar(255) DEFAULT NULL,
  `city` varchar(120) DEFAULT NULL,
  `state_region` varchar(120) DEFAULT NULL,
  `postal_code` varchar(20) DEFAULT NULL,
  `country_code` char(2) DEFAULT NULL,
  `carrier` varchar(100) DEFAULT NULL,
  `service_level` varchar(100) DEFAULT NULL,
  `tracking_number` varchar(150) DEFAULT NULL,
  `tracking_url` varchar(500) DEFAULT NULL,
  `shipment_status` enum('Pending','LabelCreated','ReadyToShip','InTransit','OutForDelivery','Delivered','DeliveryFailed','Lost','Returned') NOT NULL DEFAULT 'Pending',
  `shipping_cost` decimal(12,2) NOT NULL DEFAULT '0.00',
  `shipped_at` datetime DEFAULT NULL,
  `estimated_delivery_at` datetime DEFAULT NULL,
  `delivered_at` datetime DEFAULT NULL,
  `creation_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_update` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`),
  KEY `idx_shipments_order` (`order_ID`),
  KEY `idx_shipments_address` (`address_ID`),
  KEY `idx_shipments_tracking` (`carrier`,`tracking_number`),
  CONSTRAINT `fk_shipments_address` FOREIGN KEY (`address_ID`) REFERENCES `tb_user_addresses` (`ID`),
  CONSTRAINT `fk_shipments_order` FOREIGN KEY (`order_ID`) REFERENCES `tb_buyer_orders` (`ID`),
  CONSTRAINT `chk_shipments_shipping_cost` CHECK ((`shipping_cost` >= 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Nueva tabla: tb_refunds
CREATE TABLE `tb_refunds` (
  `ID` int unsigned NOT NULL AUTO_INCREMENT,
  `payment_ID` int unsigned NOT NULL,
  `cancellation_ID` int unsigned DEFAULT NULL,
  `return_ID` int unsigned DEFAULT NULL,
  `reason` enum('Cancellation','Return','Adjustment','Goodwill') NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `currency` char(3) NOT NULL DEFAULT 'MXN',
  `refund_status` enum('Pending','Submitted','Succeeded','Failed','Canceled') NOT NULL DEFAULT 'Pending',
  `provider` varchar(60) DEFAULT NULL,
  `provider_reference` varchar(150) DEFAULT NULL,
  `requested_by_user_ID` int DEFAULT NULL,
  `reason_detail` varchar(1000) DEFAULT NULL,
  `requested_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `processed_at` datetime DEFAULT NULL,
  `creation_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_update` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `uk_refunds_id_payment` (`ID`,`payment_ID`),
  UNIQUE KEY `uk_refunds_provider_reference` (`provider`,`provider_reference`),
  KEY `idx_refunds_payment` (`payment_ID`),
  KEY `idx_refunds_cancellation` (`cancellation_ID`),
  KEY `idx_refunds_return` (`return_ID`),
  KEY `idx_refunds_requester` (`requested_by_user_ID`),
  CONSTRAINT `fk_refunds_cancellation` FOREIGN KEY (`cancellation_ID`) REFERENCES `tb_order_cancellations` (`ID`),
  CONSTRAINT `fk_refunds_payment` FOREIGN KEY (`payment_ID`) REFERENCES `tb_payments` (`ID`),
  CONSTRAINT `fk_refunds_requester` FOREIGN KEY (`requested_by_user_ID`) REFERENCES `tb_users` (`ID`),
  CONSTRAINT `fk_refunds_return` FOREIGN KEY (`return_ID`) REFERENCES `tb_returns` (`ID`),
  CONSTRAINT `chk_refunds_amount` CHECK ((`amount` > 0)),
  CONSTRAINT `chk_refunds_source` CHECK ((((`reason` = _utf8mb4'Cancellation') and (`cancellation_ID` is not null) and (`return_ID` is null)) or ((`reason` = _utf8mb4'Return') and (`return_ID` is not null) and (`cancellation_ID` is null)) or ((`reason` in (_utf8mb4'Adjustment',_utf8mb4'Goodwill')) and (`cancellation_ID` is null) and (`return_ID` is null))))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Nueva tabla: tb_payment_transaction
CREATE TABLE `tb_payment_transaction` (
  `ID` int unsigned NOT NULL AUTO_INCREMENT,
  `payment_ID` int unsigned NOT NULL,
  `refund_ID` int unsigned DEFAULT NULL,
  `transaction_type` enum('Authorization','Capture','Charge','Void','Refund','Chargeback','Adjustment') NOT NULL,
  `transaction_status` enum('Pending','Succeeded','Failed') NOT NULL DEFAULT 'Pending',
  `amount` decimal(10,2) NOT NULL,
  `currency` char(3) NOT NULL DEFAULT 'MXN',
  `provider` varchar(60) DEFAULT NULL,
  `provider_transaction_id` varchar(150) DEFAULT NULL,
  `idempotency_key` varchar(100) DEFAULT NULL,
  `response_code` varchar(100) DEFAULT NULL,
  `response_message` varchar(500) DEFAULT NULL,
  `request_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `response_date` datetime DEFAULT NULL,
  `creation_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_update` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `uk_payment_transaction_provider_ref` (`provider`,`provider_transaction_id`),
  UNIQUE KEY `uk_payment_transaction_idempotency` (`provider`,`idempotency_key`),
  KEY `idx_payment_transaction_payment` (`payment_ID`),
  KEY `idx_payment_transaction_refund` (`refund_ID`),
  KEY `fk_payment_transaction_refund_payment` (`refund_ID`,`payment_ID`),
  CONSTRAINT `fk_payment_transaction_payment` FOREIGN KEY (`payment_ID`) REFERENCES `tb_payments` (`ID`),
  CONSTRAINT `fk_payment_transaction_refund_payment` FOREIGN KEY (`refund_ID`, `payment_ID`) REFERENCES `tb_refunds` (`ID`, `payment_ID`),
  CONSTRAINT `chk_payment_transaction_amount` CHECK ((`amount` > 0)),
  CONSTRAINT `chk_payment_transaction_refund` CHECK (((`transaction_type` <> _utf8mb4'Refund') or (`refund_ID` is not null)))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Nueva tabla: tbd_cancellation_items
CREATE TABLE `tbd_cancellation_items` (
  `ID` int unsigned NOT NULL AUTO_INCREMENT,
  `cancellation_ID` int unsigned NOT NULL,
  `order_item_ID` int unsigned NOT NULL,
  `quantity` int unsigned NOT NULL,
  `creation_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `uk_cancellation_order_item` (`cancellation_ID`,`order_item_ID`),
  KEY `idx_cancellation_items_order_item` (`order_item_ID`),
  CONSTRAINT `fk_cancellation_items_cancellation` FOREIGN KEY (`cancellation_ID`) REFERENCES `tb_order_cancellations` (`ID`),
  CONSTRAINT `fk_cancellation_items_order_item` FOREIGN KEY (`order_item_ID`) REFERENCES `tbd_order_itemes` (`ID`),
  CONSTRAINT `chk_cancellation_items_quantity` CHECK ((`quantity` > 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Nueva tabla: tbd_return_items
CREATE TABLE `tbd_return_items` (
  `ID` int unsigned NOT NULL AUTO_INCREMENT,
  `return_ID` int unsigned NOT NULL,
  `order_item_ID` int unsigned NOT NULL,
  `quantity` int unsigned NOT NULL,
  `item_condition` enum('Unopened','Unused','Used','Damaged','Defective','Other') DEFAULT NULL,
  `disposition` enum('Pending','Restock','Repair','Dispose','SupplierReturn') NOT NULL DEFAULT 'Pending',
  `approved_refund_amount` decimal(12,2) NOT NULL DEFAULT '0.00',
  `item_status` enum('Requested','Approved','Rejected','Received','Refunded') NOT NULL DEFAULT 'Requested',
  `creation_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_update` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `uk_return_order_item` (`return_ID`,`order_item_ID`),
  KEY `idx_return_items_order_item` (`order_item_ID`),
  CONSTRAINT `fk_return_items_order_item` FOREIGN KEY (`order_item_ID`) REFERENCES `tbd_order_itemes` (`ID`),
  CONSTRAINT `fk_return_items_return` FOREIGN KEY (`return_ID`) REFERENCES `tb_returns` (`ID`),
  CONSTRAINT `chk_return_items_quantity` CHECK ((`quantity` > 0)),
  CONSTRAINT `chk_return_items_refund_amount` CHECK ((`approved_refund_amount` >= 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
