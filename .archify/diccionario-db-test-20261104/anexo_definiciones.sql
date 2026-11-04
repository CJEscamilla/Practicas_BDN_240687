-- ANEXO DE LECTURA: definiciones del respaldo; no ejecutar como restauración.
-- Se omitieron las cláusulas DEFINER que identifican cuentas. No contiene filas INSERT.
-- Fuente: practica03/backups/respaldo10_28.1.sql
-- Las líneas indicadas corresponden al respaldo original.

-- TABLA tb_buyer_orders | línea 27
CREATE TABLE `tb_buyer_orders` (
  `ID` int unsigned NOT NULL AUTO_INCREMENT,
  `order_number` varchar(40) NOT NULL,
  `buyer_user_ID` int NOT NULL,
  `cart_ID` int unsigned DEFAULT NULL,
  `shipping_address_ID` int unsigned NOT NULL,
  `user_payment_method_ID` int unsigned DEFAULT NULL,
  `status` enum('pending','confirmed','processing','shipped','delivered','cancelled') NOT NULL DEFAULT 'pending',
  `payment_status` enum('pending','authorized','paid','failed','refunded') NOT NULL DEFAULT 'pending',
  `currency` char(3) NOT NULL DEFAULT 'MXN',
  `shipping_address_snapshot` json NOT NULL COMMENT 'Copia completa del destinatario y direccion al comprar',
  `subtotal` decimal(14,2) NOT NULL,
  `discount_total` decimal(14,2) NOT NULL DEFAULT '0.00',
  `tax_total` decimal(14,2) NOT NULL DEFAULT '0.00',
  `shipping_total` decimal(14,2) NOT NULL DEFAULT '0.00',
  `grand_total` decimal(14,2) GENERATED ALWAYS AS ((((`subtotal` - `discount_total`) + `tax_total`) + `shipping_total`)) STORED,
  `creation_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_update` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `uq_order_number` (`order_number`),
  UNIQUE KEY `uq_order_cart` (`cart_ID`),
  KEY `idx_order_buyer_date` (`buyer_user_ID`,`creation_date`),
  KEY `fk_order_cart_owner` (`buyer_user_ID`,`cart_ID`),
  KEY `fk_order_address_owner` (`buyer_user_ID`,`shipping_address_ID`),
  KEY `fk_order_payment_owner` (`buyer_user_ID`,`user_payment_method_ID`),
  CONSTRAINT `fk_order_address_owner` FOREIGN KEY (`buyer_user_ID`, `shipping_address_ID`) REFERENCES `tb_user_addresses` (`user_ID`, `ID`),
  CONSTRAINT `fk_order_buyer` FOREIGN KEY (`buyer_user_ID`) REFERENCES `tb_users` (`ID`),
  CONSTRAINT `fk_order_cart_owner` FOREIGN KEY (`buyer_user_ID`, `cart_ID`) REFERENCES `tb_carts` (`user_ID`, `ID`),
  CONSTRAINT `fk_order_payment_owner` FOREIGN KEY (`buyer_user_ID`, `user_payment_method_ID`) REFERENCES `tbd_user_payment_methods` (`user_ID`, `ID`),
  CONSTRAINT `chk_order_amounts` CHECK (((`subtotal` >= 0) and (`discount_total` >= 0) and (`discount_total` <= `subtotal`) and (`tax_total` >= 0) and (`shipping_total` >= 0)))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- TABLA tb_carts | línea 213
CREATE TABLE `tb_carts` (
  `ID` int unsigned NOT NULL AUTO_INCREMENT,
  `user_ID` int NOT NULL,
  `status` enum('active','converted','abandoned') NOT NULL DEFAULT 'active',
  `currency` char(3) NOT NULL DEFAULT 'MXN',
  `active_user_ID` int GENERATED ALWAYS AS ((case when (`status` = _utf8mb4'active') then `user_ID` else NULL end)) STORED,
  `creation_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_update` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `uq_cart_owner` (`user_ID`,`ID`),
  UNIQUE KEY `uq_active_cart_user` (`active_user_ID`),
  CONSTRAINT `fk_cart_user` FOREIGN KEY (`user_ID`) REFERENCES `tb_users` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- TABLA tb_logs | línea 345
CREATE TABLE `tb_logs` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `table_name` varchar(100) NOT NULL,
  `operation` enum('Create','Read','Update','Delete') NOT NULL,
  `db_users` varchar(80) NOT NULL,
  `description` text NOT NULL,
  `operation_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `operation_status` bit(1) DEFAULT b'1',
  PRIMARY KEY (`ID`),
  KEY `idx_logs_search` (`table_name`,`operation`),
  KEY `idx_logs_table_op` (`table_name`,`operation`)
) ENGINE=InnoDB AUTO_INCREMENT=5016 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- TABLA tb_order_cancellations | línea 377
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

-- TABLA tb_payment_methods | línea 415
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

-- TABLA tb_payment_transaction | línea 443
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

-- TABLA tb_payments | línea 489
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

-- TABLA tb_people | línea 527
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

-- TABLA tb_products | línea 562
CREATE TABLE `tb_products` (
  `ID` int unsigned NOT NULL AUTO_INCREMENT,
  `SKU` varchar(50) NOT NULL,
  `name` varchar(250) NOT NULL,
  `description` text,
  `current_price` decimal(10,2) NOT NULL DEFAULT '0.00',
  `current_stock` int unsigned NOT NULL DEFAULT '0',
  `status` tinyint DEFAULT '1',
  `creation_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_update` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `SKU` (`SKU`),
  KEY `idx_products_id` (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=5009 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- TABLA tb_refunds | línea 596
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

-- TABLA tb_returns | línea 645
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

-- TABLA tb_shipments | línea 686
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

-- TABLA tb_user_addresses | línea 735
CREATE TABLE `tb_user_addresses` (
  `ID` int unsigned NOT NULL AUTO_INCREMENT,
  `user_ID` int NOT NULL,
  `label` varchar(60) NOT NULL,
  `recipient_name` varchar(150) NOT NULL,
  `phone` varchar(30) DEFAULT NULL,
  `street` varchar(200) NOT NULL,
  `exterior_number` varchar(30) NOT NULL,
  `interior_number` varchar(30) DEFAULT NULL,
  `neighborhood` varchar(120) DEFAULT NULL,
  `city` varchar(120) NOT NULL,
  `state` varchar(120) NOT NULL,
  `postal_code` varchar(20) NOT NULL,
  `country_code` char(2) NOT NULL DEFAULT 'MX',
  `delivery_instructions` varchar(500) DEFAULT NULL,
  `status` bit(1) NOT NULL DEFAULT b'1',
  `creation_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_update` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `uq_address_owner` (`user_ID`,`ID`),
  CONSTRAINT `fk_address_user` FOREIGN KEY (`user_ID`) REFERENCES `tb_users` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- TABLA tb_users | línea 876
CREATE TABLE `tb_users` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `email` varchar(80) NOT NULL,
  `nickname` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `creation_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_update` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `last_login` datetime DEFAULT NULL,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `nickname` (`nickname`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- TABLA tbc_carts_items | línea 907
CREATE TABLE `tbc_carts_items` (
  `ID` int unsigned NOT NULL AUTO_INCREMENT,
  `code` varchar(40) NOT NULL,
  `name` varchar(100) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `status` bit(1) NOT NULL DEFAULT b'1',
  PRIMARY KEY (`ID`),
  UNIQUE KEY `uq_cart_item_state` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- TABLA tbc_categories | línea 1027
CREATE TABLE `tbc_categories` (
  `ID` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(120) NOT NULL,
  `description` text,
  `sup_id_category` int unsigned DEFAULT NULL,
  `status` bit(1) NOT NULL DEFAULT b'1',
  `creation_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_update` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `name_UNIQUE` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=101 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- TABLA tbc_order_items | línea 1158
CREATE TABLE `tbc_order_items` (
  `ID` int unsigned NOT NULL AUTO_INCREMENT,
  `code` varchar(40) NOT NULL,
  `name` varchar(100) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `status` bit(1) NOT NULL DEFAULT b'1',
  PRIMARY KEY (`ID`),
  UNIQUE KEY `uq_order_item_state` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- TABLA tbc_payment_methods_types | línea 1278
CREATE TABLE `tbc_payment_methods_types` (
  `ID` int unsigned NOT NULL AUTO_INCREMENT,
  `code` varchar(40) NOT NULL,
  `name` varchar(100) NOT NULL,
  `status` bit(1) NOT NULL DEFAULT b'1',
  `creation_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_update` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `uq_payment_type_code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- TABLA tbd_cancellation_items | línea 1403
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

-- TABLA tbd_carts_items | línea 1434
CREATE TABLE `tbd_carts_items` (
  `ID` int unsigned NOT NULL AUTO_INCREMENT,
  `cart_ID` int unsigned NOT NULL,
  `product_ID` int unsigned NOT NULL,
  `cart_item_status_ID` int unsigned NOT NULL,
  `quantity` int unsigned NOT NULL,
  `creation_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_update` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `uq_cart_product` (`cart_ID`,`product_ID`),
  KEY `fk_cart_detail_product` (`product_ID`),
  KEY `fk_cart_detail_state` (`cart_item_status_ID`),
  CONSTRAINT `fk_cart_detail_cart` FOREIGN KEY (`cart_ID`) REFERENCES `tb_carts` (`ID`),
  CONSTRAINT `fk_cart_detail_product` FOREIGN KEY (`product_ID`) REFERENCES `tb_products` (`ID`),
  CONSTRAINT `fk_cart_detail_state` FOREIGN KEY (`cart_item_status_ID`) REFERENCES `tbc_carts_items` (`ID`),
  CONSTRAINT `chk_cart_quantity` CHECK ((`quantity` > 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- TABLA tbd_order_itemes | línea 1570
CREATE TABLE `tbd_order_itemes` (
  `ID` int unsigned NOT NULL AUTO_INCREMENT,
  `order_ID` int unsigned NOT NULL,
  `product_ID` int unsigned NOT NULL,
  `order_item_status_ID` int unsigned NOT NULL,
  `product_sku_snapshot` varchar(50) NOT NULL,
  `product_name_snapshot` varchar(250) NOT NULL,
  `quantity` int unsigned NOT NULL,
  `unit_price` decimal(10,2) NOT NULL,
  `discount_total` decimal(14,2) NOT NULL DEFAULT '0.00',
  `tax_total` decimal(14,2) NOT NULL DEFAULT '0.00',
  `line_total` decimal(14,2) GENERATED ALWAYS AS ((((`quantity` * `unit_price`) - `discount_total`) + `tax_total`)) STORED,
  `creation_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_update` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `uq_order_product` (`order_ID`,`product_ID`),
  KEY `fk_order_detail_product` (`product_ID`),
  KEY `fk_order_detail_state` (`order_item_status_ID`),
  CONSTRAINT `fk_order_detail_order` FOREIGN KEY (`order_ID`) REFERENCES `tb_buyer_orders` (`ID`),
  CONSTRAINT `fk_order_detail_product` FOREIGN KEY (`product_ID`) REFERENCES `tb_products` (`ID`),
  CONSTRAINT `fk_order_detail_state` FOREIGN KEY (`order_item_status_ID`) REFERENCES `tbc_order_items` (`ID`),
  CONSTRAINT `chk_order_detail_amounts` CHECK (((`quantity` > 0) and (`unit_price` >= 0) and (`discount_total` >= 0) and (`discount_total` <= (`quantity` * `unit_price`)) and (`tax_total` >= 0)))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- TABLA tbd_products_categories | línea 1736
CREATE TABLE `tbd_products_categories` (
  `ID` int unsigned NOT NULL AUTO_INCREMENT,
  `product_ID` int unsigned NOT NULL,
  `category_ID` int unsigned NOT NULL,
  `status` bit(1) NOT NULL DEFAULT b'1',
  `creation_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_update` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `uq_product_category` (`product_ID`,`category_ID`),
  KEY `fk_product_category_category` (`category_ID`),
  CONSTRAINT `fk_product_category_category` FOREIGN KEY (`category_ID`) REFERENCES `tbc_categories` (`ID`),
  CONSTRAINT `fk_product_category_product` FOREIGN KEY (`product_ID`) REFERENCES `tb_products` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- TABLA tbd_products_users_providers | línea 1864
CREATE TABLE `tbd_products_users_providers` (
  `ID` int unsigned NOT NULL AUTO_INCREMENT,
  `product_ID` int unsigned NOT NULL,
  `provider_user_ID` int NOT NULL COMMENT 'Proveedor de la plataforma, no cuenta de mysql.user',
  `provider_sku` varchar(80) DEFAULT NULL,
  `acquisition_cost` decimal(10,2) DEFAULT NULL,
  `status` bit(1) NOT NULL DEFAULT b'1',
  `creation_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_update` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `uq_product_provider` (`product_ID`,`provider_user_ID`),
  KEY `fk_provider_user` (`provider_user_ID`),
  CONSTRAINT `fk_provider_product` FOREIGN KEY (`product_ID`) REFERENCES `tb_products` (`ID`),
  CONSTRAINT `fk_provider_user` FOREIGN KEY (`provider_user_ID`) REFERENCES `tb_users` (`ID`),
  CONSTRAINT `chk_provider_cost` CHECK (((`acquisition_cost` is null) or (`acquisition_cost` >= 0)))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- TABLA tbd_return_items | línea 2003
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

-- TABLA tbd_user_payment_methods | línea 2040
CREATE TABLE `tbd_user_payment_methods` (
  `ID` int unsigned NOT NULL AUTO_INCREMENT,
  `user_ID` int NOT NULL,
  `payment_method_type_ID` int unsigned NOT NULL,
  `provider` varchar(80) NOT NULL,
  `provider_reference` varchar(255) NOT NULL COMMENT 'Token o referencia externa; nunca PAN completo ni CVV',
  `display_name` varchar(100) NOT NULL,
  `last_four` char(4) DEFAULT NULL,
  `status` bit(1) NOT NULL DEFAULT b'1',
  `creation_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_update` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `uq_payment_owner` (`user_ID`,`ID`),
  UNIQUE KEY `uq_user_provider_reference` (`user_ID`,`provider`,`provider_reference`),
  KEY `fk_payment_type` (`payment_method_type_ID`),
  CONSTRAINT `fk_payment_type` FOREIGN KEY (`payment_method_type_ID`) REFERENCES `tbc_payment_methods_types` (`ID`),
  CONSTRAINT `fk_payment_user` FOREIGN KEY (`user_ID`) REFERENCES `tb_users` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- TABLA tbd_users_wishilst_products | línea 2177
CREATE TABLE `tbd_users_wishilst_products` (
  `ID` int unsigned NOT NULL AUTO_INCREMENT,
  `user_ID` int NOT NULL,
  `product_ID` int unsigned NOT NULL,
  `status` bit(1) NOT NULL DEFAULT b'1',
  `creation_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_update` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `uq_wishlist_user_product` (`user_ID`,`product_ID`),
  KEY `fk_wishlist_product` (`product_ID`),
  CONSTRAINT `fk_wishlist_product` FOREIGN KEY (`product_ID`) REFERENCES `tb_products` (`ID`),
  CONSTRAINT `fk_wishlist_user` FOREIGN KEY (`user_ID`) REFERENCES `tb_users` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- VISTA vw_trazabilidad_categorias | línea 3082
CREATE VIEW `vw_trazabilidad_categorias` AS select `l`.`ID` AS `log_id`,cast(substring_index(substring_index(`l`.`description`,'ID=',-(1)),',',1) as unsigned) AS `category_id`,`l`.`operation` AS `operation`,`l`.`db_users` AS `db_user`,substring_index(`l`.`db_users`,'@',1) AS `username`,coalesce((select group_concat(distinct `re`.`FROM_USER` order by `re`.`FROM_USER` ASC separator ', ') from `mysql`.`role_edges` `re` where (`re`.`TO_USER` = substring_index(`l`.`db_users`,'@',1))),'Sin rol asignado') AS `roles`,`l`.`description` AS `operation_description`,`l`.`operation_date` AS `operation_date`,`l`.`operation_status` AS `operation_status` from `tb_logs` `l` where (`l`.`table_name` = 'tbc_categories');

-- VISTA vw_trazabilidad_productos | línea 3100
CREATE VIEW `vw_trazabilidad_productos` AS select `tb_logs`.`ID` AS `log_id`,`tb_logs`.`operation` AS `operation`,`tb_logs`.`db_users` AS `inserted_by`,`tb_logs`.`description` AS `operation_description`,`tb_logs`.`operation_date` AS `operation_date` from `tb_logs` where ((`tb_logs`.`table_name` = 'tb_products') and (`tb_logs`.`operation` = 'Create'));

-- VISTA vw_trazabilidad_tb_buyer_orders | línea 3118
CREATE VIEW `vw_trazabilidad_tb_buyer_orders` AS select `l`.`ID` AS `log_id`,`l`.`table_name` AS `table_name`,(case when regexp_like(`l`.`description`,'ID=[0-9]+,') then cast(substring_index(substring_index(substring_index(`l`.`description`,', datos=',1),'ID=',-(1)),',',1) as unsigned) else NULL end) AS `record_id`,`l`.`operation` AS `operation`,`l`.`db_users` AS `db_user`,substring_index(`l`.`db_users`,'@',1) AS `username`,coalesce((select group_concat(distinct `re`.`FROM_USER` order by `re`.`FROM_USER` ASC separator ', ') from `mysql`.`role_edges` `re` where (`re`.`TO_USER` = substring_index(`l`.`db_users`,'@',1))),'Sin rol directo actual') AS `roles_actuales_por_nombre`,`l`.`description` AS `operation_description`,`l`.`operation_date` AS `operation_date`,cast(`l`.`operation_status` as unsigned) AS `operation_status` from `tb_logs` `l` where (`l`.`table_name` = 'tb_buyer_orders');

-- VISTA vw_trazabilidad_tb_carts | línea 3136
CREATE VIEW `vw_trazabilidad_tb_carts` AS select `l`.`ID` AS `log_id`,`l`.`table_name` AS `table_name`,(case when regexp_like(`l`.`description`,'ID=[0-9]+,') then cast(substring_index(substring_index(substring_index(`l`.`description`,', datos=',1),'ID=',-(1)),',',1) as unsigned) else NULL end) AS `record_id`,`l`.`operation` AS `operation`,`l`.`db_users` AS `db_user`,substring_index(`l`.`db_users`,'@',1) AS `username`,coalesce((select group_concat(distinct `re`.`FROM_USER` order by `re`.`FROM_USER` ASC separator ', ') from `mysql`.`role_edges` `re` where (`re`.`TO_USER` = substring_index(`l`.`db_users`,'@',1))),'Sin rol directo actual') AS `roles_actuales_por_nombre`,`l`.`description` AS `operation_description`,`l`.`operation_date` AS `operation_date`,cast(`l`.`operation_status` as unsigned) AS `operation_status` from `tb_logs` `l` where (`l`.`table_name` = 'tb_carts');

-- VISTA vw_trazabilidad_tb_order_cancellations | línea 3154
CREATE VIEW `vw_trazabilidad_tb_order_cancellations` AS select `l`.`ID` AS `log_id`,`l`.`table_name` AS `table_name`,(case when regexp_like(`l`.`description`,'ID=[0-9]+,') then cast(substring_index(substring_index(substring_index(`l`.`description`,', datos=',1),'ID=',-(1)),',',1) as unsigned) else NULL end) AS `record_id`,`l`.`operation` AS `operation`,`l`.`db_users` AS `db_user`,substring_index(`l`.`db_users`,'@',1) AS `username`,coalesce((select group_concat(distinct `re`.`FROM_USER` order by `re`.`FROM_USER` ASC separator ', ') from `mysql`.`role_edges` `re` where (`re`.`TO_USER` = substring_index(`l`.`db_users`,'@',1))),'Sin rol directo actual') AS `roles_actuales_por_nombre`,`l`.`description` AS `operation_description`,`l`.`operation_date` AS `operation_date`,cast(`l`.`operation_status` as unsigned) AS `operation_status` from `tb_logs` `l` where (`l`.`table_name` = 'tb_order_cancellations');

-- VISTA vw_trazabilidad_tb_payment_methods | línea 3172
CREATE VIEW `vw_trazabilidad_tb_payment_methods` AS select `l`.`ID` AS `log_id`,`l`.`table_name` AS `table_name`,(case when regexp_like(`l`.`description`,'ID=[0-9]+,') then cast(substring_index(substring_index(substring_index(`l`.`description`,', datos=',1),'ID=',-(1)),',',1) as unsigned) else NULL end) AS `record_id`,`l`.`operation` AS `operation`,`l`.`db_users` AS `db_user`,substring_index(`l`.`db_users`,'@',1) AS `username`,coalesce((select group_concat(distinct `re`.`FROM_USER` order by `re`.`FROM_USER` ASC separator ', ') from `mysql`.`role_edges` `re` where (`re`.`TO_USER` = substring_index(`l`.`db_users`,'@',1))),'Sin rol directo actual') AS `roles_actuales_por_nombre`,`l`.`description` AS `operation_description`,`l`.`operation_date` AS `operation_date`,cast(`l`.`operation_status` as unsigned) AS `operation_status` from `tb_logs` `l` where (`l`.`table_name` = 'tb_payment_methods');

-- VISTA vw_trazabilidad_tb_payment_transaction | línea 3190
CREATE VIEW `vw_trazabilidad_tb_payment_transaction` AS select `l`.`ID` AS `log_id`,`l`.`table_name` AS `table_name`,(case when regexp_like(`l`.`description`,'ID=[0-9]+,') then cast(substring_index(substring_index(substring_index(`l`.`description`,', datos=',1),'ID=',-(1)),',',1) as unsigned) else NULL end) AS `record_id`,`l`.`operation` AS `operation`,`l`.`db_users` AS `db_user`,substring_index(`l`.`db_users`,'@',1) AS `username`,coalesce((select group_concat(distinct `re`.`FROM_USER` order by `re`.`FROM_USER` ASC separator ', ') from `mysql`.`role_edges` `re` where (`re`.`TO_USER` = substring_index(`l`.`db_users`,'@',1))),'Sin rol directo actual') AS `roles_actuales_por_nombre`,`l`.`description` AS `operation_description`,`l`.`operation_date` AS `operation_date`,cast(`l`.`operation_status` as unsigned) AS `operation_status` from `tb_logs` `l` where (`l`.`table_name` = 'tb_payment_transaction');

-- VISTA vw_trazabilidad_tb_payments | línea 3208
CREATE VIEW `vw_trazabilidad_tb_payments` AS select `l`.`ID` AS `log_id`,`l`.`table_name` AS `table_name`,(case when regexp_like(`l`.`description`,'ID=[0-9]+,') then cast(substring_index(substring_index(substring_index(`l`.`description`,', datos=',1),'ID=',-(1)),',',1) as unsigned) else NULL end) AS `record_id`,`l`.`operation` AS `operation`,`l`.`db_users` AS `db_user`,substring_index(`l`.`db_users`,'@',1) AS `username`,coalesce((select group_concat(distinct `re`.`FROM_USER` order by `re`.`FROM_USER` ASC separator ', ') from `mysql`.`role_edges` `re` where (`re`.`TO_USER` = substring_index(`l`.`db_users`,'@',1))),'Sin rol directo actual') AS `roles_actuales_por_nombre`,`l`.`description` AS `operation_description`,`l`.`operation_date` AS `operation_date`,cast(`l`.`operation_status` as unsigned) AS `operation_status` from `tb_logs` `l` where (`l`.`table_name` = 'tb_payments');

-- VISTA vw_trazabilidad_tb_people | línea 3226
CREATE VIEW `vw_trazabilidad_tb_people` AS select `l`.`ID` AS `log_id`,`l`.`table_name` AS `table_name`,(case when regexp_like(`l`.`description`,'ID=[0-9]+,') then cast(substring_index(substring_index(substring_index(`l`.`description`,', datos=',1),'ID=',-(1)),',',1) as unsigned) else NULL end) AS `record_id`,`l`.`operation` AS `operation`,`l`.`db_users` AS `db_user`,substring_index(`l`.`db_users`,'@',1) AS `username`,coalesce((select group_concat(distinct `re`.`FROM_USER` order by `re`.`FROM_USER` ASC separator ', ') from `mysql`.`role_edges` `re` where (`re`.`TO_USER` = substring_index(`l`.`db_users`,'@',1))),'Sin rol directo actual') AS `roles_actuales_por_nombre`,`l`.`description` AS `operation_description`,`l`.`operation_date` AS `operation_date`,cast(`l`.`operation_status` as unsigned) AS `operation_status` from `tb_logs` `l` where (`l`.`table_name` = 'tb_people');

-- VISTA vw_trazabilidad_tb_products | línea 3244
CREATE VIEW `vw_trazabilidad_tb_products` AS select `l`.`ID` AS `log_id`,`l`.`table_name` AS `table_name`,(case when regexp_like(`l`.`description`,'ID=[0-9]+,') then cast(substring_index(substring_index(substring_index(`l`.`description`,', datos=',1),'ID=',-(1)),',',1) as unsigned) else NULL end) AS `record_id`,`l`.`operation` AS `operation`,`l`.`db_users` AS `db_user`,substring_index(`l`.`db_users`,'@',1) AS `username`,coalesce((select group_concat(distinct `re`.`FROM_USER` order by `re`.`FROM_USER` ASC separator ', ') from `mysql`.`role_edges` `re` where (`re`.`TO_USER` = substring_index(`l`.`db_users`,'@',1))),'Sin rol directo actual') AS `roles_actuales_por_nombre`,`l`.`description` AS `operation_description`,`l`.`operation_date` AS `operation_date`,cast(`l`.`operation_status` as unsigned) AS `operation_status` from `tb_logs` `l` where (`l`.`table_name` = 'tb_products');

-- VISTA vw_trazabilidad_tb_refunds | línea 3262
CREATE VIEW `vw_trazabilidad_tb_refunds` AS select `l`.`ID` AS `log_id`,`l`.`table_name` AS `table_name`,(case when regexp_like(`l`.`description`,'ID=[0-9]+,') then cast(substring_index(substring_index(substring_index(`l`.`description`,', datos=',1),'ID=',-(1)),',',1) as unsigned) else NULL end) AS `record_id`,`l`.`operation` AS `operation`,`l`.`db_users` AS `db_user`,substring_index(`l`.`db_users`,'@',1) AS `username`,coalesce((select group_concat(distinct `re`.`FROM_USER` order by `re`.`FROM_USER` ASC separator ', ') from `mysql`.`role_edges` `re` where (`re`.`TO_USER` = substring_index(`l`.`db_users`,'@',1))),'Sin rol directo actual') AS `roles_actuales_por_nombre`,`l`.`description` AS `operation_description`,`l`.`operation_date` AS `operation_date`,cast(`l`.`operation_status` as unsigned) AS `operation_status` from `tb_logs` `l` where (`l`.`table_name` = 'tb_refunds');

-- VISTA vw_trazabilidad_tb_returns | línea 3280
CREATE VIEW `vw_trazabilidad_tb_returns` AS select `l`.`ID` AS `log_id`,`l`.`table_name` AS `table_name`,(case when regexp_like(`l`.`description`,'ID=[0-9]+,') then cast(substring_index(substring_index(substring_index(`l`.`description`,', datos=',1),'ID=',-(1)),',',1) as unsigned) else NULL end) AS `record_id`,`l`.`operation` AS `operation`,`l`.`db_users` AS `db_user`,substring_index(`l`.`db_users`,'@',1) AS `username`,coalesce((select group_concat(distinct `re`.`FROM_USER` order by `re`.`FROM_USER` ASC separator ', ') from `mysql`.`role_edges` `re` where (`re`.`TO_USER` = substring_index(`l`.`db_users`,'@',1))),'Sin rol directo actual') AS `roles_actuales_por_nombre`,`l`.`description` AS `operation_description`,`l`.`operation_date` AS `operation_date`,cast(`l`.`operation_status` as unsigned) AS `operation_status` from `tb_logs` `l` where (`l`.`table_name` = 'tb_returns');

-- VISTA vw_trazabilidad_tb_shipments | línea 3298
CREATE VIEW `vw_trazabilidad_tb_shipments` AS select `l`.`ID` AS `log_id`,`l`.`table_name` AS `table_name`,(case when regexp_like(`l`.`description`,'ID=[0-9]+,') then cast(substring_index(substring_index(substring_index(`l`.`description`,', datos=',1),'ID=',-(1)),',',1) as unsigned) else NULL end) AS `record_id`,`l`.`operation` AS `operation`,`l`.`db_users` AS `db_user`,substring_index(`l`.`db_users`,'@',1) AS `username`,coalesce((select group_concat(distinct `re`.`FROM_USER` order by `re`.`FROM_USER` ASC separator ', ') from `mysql`.`role_edges` `re` where (`re`.`TO_USER` = substring_index(`l`.`db_users`,'@',1))),'Sin rol directo actual') AS `roles_actuales_por_nombre`,`l`.`description` AS `operation_description`,`l`.`operation_date` AS `operation_date`,cast(`l`.`operation_status` as unsigned) AS `operation_status` from `tb_logs` `l` where (`l`.`table_name` = 'tb_shipments');

-- VISTA vw_trazabilidad_tb_user_addresses | línea 3316
CREATE VIEW `vw_trazabilidad_tb_user_addresses` AS select `l`.`ID` AS `log_id`,`l`.`table_name` AS `table_name`,(case when regexp_like(`l`.`description`,'ID=[0-9]+,') then cast(substring_index(substring_index(substring_index(`l`.`description`,', datos=',1),'ID=',-(1)),',',1) as unsigned) else NULL end) AS `record_id`,`l`.`operation` AS `operation`,`l`.`db_users` AS `db_user`,substring_index(`l`.`db_users`,'@',1) AS `username`,coalesce((select group_concat(distinct `re`.`FROM_USER` order by `re`.`FROM_USER` ASC separator ', ') from `mysql`.`role_edges` `re` where (`re`.`TO_USER` = substring_index(`l`.`db_users`,'@',1))),'Sin rol directo actual') AS `roles_actuales_por_nombre`,`l`.`description` AS `operation_description`,`l`.`operation_date` AS `operation_date`,cast(`l`.`operation_status` as unsigned) AS `operation_status` from `tb_logs` `l` where (`l`.`table_name` = 'tb_user_addresses');

-- VISTA vw_trazabilidad_tb_users | línea 3334
CREATE VIEW `vw_trazabilidad_tb_users` AS select `l`.`ID` AS `log_id`,`l`.`table_name` AS `table_name`,(case when regexp_like(`l`.`description`,'ID=[0-9]+,') then cast(substring_index(substring_index(substring_index(`l`.`description`,', datos=',1),'ID=',-(1)),',',1) as unsigned) else NULL end) AS `record_id`,`l`.`operation` AS `operation`,`l`.`db_users` AS `db_user`,substring_index(`l`.`db_users`,'@',1) AS `username`,coalesce((select group_concat(distinct `re`.`FROM_USER` order by `re`.`FROM_USER` ASC separator ', ') from `mysql`.`role_edges` `re` where (`re`.`TO_USER` = substring_index(`l`.`db_users`,'@',1))),'Sin rol directo actual') AS `roles_actuales_por_nombre`,`l`.`description` AS `operation_description`,`l`.`operation_date` AS `operation_date`,cast(`l`.`operation_status` as unsigned) AS `operation_status` from `tb_logs` `l` where (`l`.`table_name` = 'tb_users');

-- VISTA vw_trazabilidad_tbc_carts_items | línea 3352
CREATE VIEW `vw_trazabilidad_tbc_carts_items` AS select `l`.`ID` AS `log_id`,`l`.`table_name` AS `table_name`,(case when regexp_like(`l`.`description`,'ID=[0-9]+,') then cast(substring_index(substring_index(substring_index(`l`.`description`,', datos=',1),'ID=',-(1)),',',1) as unsigned) else NULL end) AS `record_id`,`l`.`operation` AS `operation`,`l`.`db_users` AS `db_user`,substring_index(`l`.`db_users`,'@',1) AS `username`,coalesce((select group_concat(distinct `re`.`FROM_USER` order by `re`.`FROM_USER` ASC separator ', ') from `mysql`.`role_edges` `re` where (`re`.`TO_USER` = substring_index(`l`.`db_users`,'@',1))),'Sin rol directo actual') AS `roles_actuales_por_nombre`,`l`.`description` AS `operation_description`,`l`.`operation_date` AS `operation_date`,cast(`l`.`operation_status` as unsigned) AS `operation_status` from `tb_logs` `l` where (`l`.`table_name` = 'tbc_carts_items');

-- VISTA vw_trazabilidad_tbc_categories | línea 3370
CREATE VIEW `vw_trazabilidad_tbc_categories` AS select `l`.`ID` AS `log_id`,`l`.`table_name` AS `table_name`,(case when regexp_like(`l`.`description`,'ID=[0-9]+,') then cast(substring_index(substring_index(substring_index(`l`.`description`,', datos=',1),'ID=',-(1)),',',1) as unsigned) else NULL end) AS `record_id`,`l`.`operation` AS `operation`,`l`.`db_users` AS `db_user`,substring_index(`l`.`db_users`,'@',1) AS `username`,coalesce((select group_concat(distinct `re`.`FROM_USER` order by `re`.`FROM_USER` ASC separator ', ') from `mysql`.`role_edges` `re` where (`re`.`TO_USER` = substring_index(`l`.`db_users`,'@',1))),'Sin rol directo actual') AS `roles_actuales_por_nombre`,`l`.`description` AS `operation_description`,`l`.`operation_date` AS `operation_date`,cast(`l`.`operation_status` as unsigned) AS `operation_status` from `tb_logs` `l` where (`l`.`table_name` = 'tbc_categories');

-- VISTA vw_trazabilidad_tbc_order_items | línea 3388
CREATE VIEW `vw_trazabilidad_tbc_order_items` AS select `l`.`ID` AS `log_id`,`l`.`table_name` AS `table_name`,(case when regexp_like(`l`.`description`,'ID=[0-9]+,') then cast(substring_index(substring_index(substring_index(`l`.`description`,', datos=',1),'ID=',-(1)),',',1) as unsigned) else NULL end) AS `record_id`,`l`.`operation` AS `operation`,`l`.`db_users` AS `db_user`,substring_index(`l`.`db_users`,'@',1) AS `username`,coalesce((select group_concat(distinct `re`.`FROM_USER` order by `re`.`FROM_USER` ASC separator ', ') from `mysql`.`role_edges` `re` where (`re`.`TO_USER` = substring_index(`l`.`db_users`,'@',1))),'Sin rol directo actual') AS `roles_actuales_por_nombre`,`l`.`description` AS `operation_description`,`l`.`operation_date` AS `operation_date`,cast(`l`.`operation_status` as unsigned) AS `operation_status` from `tb_logs` `l` where (`l`.`table_name` = 'tbc_order_items');

-- VISTA vw_trazabilidad_tbc_payment_methods_types | línea 3406
CREATE VIEW `vw_trazabilidad_tbc_payment_methods_types` AS select `l`.`ID` AS `log_id`,`l`.`table_name` AS `table_name`,(case when regexp_like(`l`.`description`,'ID=[0-9]+,') then cast(substring_index(substring_index(substring_index(`l`.`description`,', datos=',1),'ID=',-(1)),',',1) as unsigned) else NULL end) AS `record_id`,`l`.`operation` AS `operation`,`l`.`db_users` AS `db_user`,substring_index(`l`.`db_users`,'@',1) AS `username`,coalesce((select group_concat(distinct `re`.`FROM_USER` order by `re`.`FROM_USER` ASC separator ', ') from `mysql`.`role_edges` `re` where (`re`.`TO_USER` = substring_index(`l`.`db_users`,'@',1))),'Sin rol directo actual') AS `roles_actuales_por_nombre`,`l`.`description` AS `operation_description`,`l`.`operation_date` AS `operation_date`,cast(`l`.`operation_status` as unsigned) AS `operation_status` from `tb_logs` `l` where (`l`.`table_name` = 'tbc_payment_methods_types');

-- VISTA vw_trazabilidad_tbd_cancellation_items | línea 3424
CREATE VIEW `vw_trazabilidad_tbd_cancellation_items` AS select `l`.`ID` AS `log_id`,`l`.`table_name` AS `table_name`,(case when regexp_like(`l`.`description`,'ID=[0-9]+,') then cast(substring_index(substring_index(substring_index(`l`.`description`,', datos=',1),'ID=',-(1)),',',1) as unsigned) else NULL end) AS `record_id`,`l`.`operation` AS `operation`,`l`.`db_users` AS `db_user`,substring_index(`l`.`db_users`,'@',1) AS `username`,coalesce((select group_concat(distinct `re`.`FROM_USER` order by `re`.`FROM_USER` ASC separator ', ') from `mysql`.`role_edges` `re` where (`re`.`TO_USER` = substring_index(`l`.`db_users`,'@',1))),'Sin rol directo actual') AS `roles_actuales_por_nombre`,`l`.`description` AS `operation_description`,`l`.`operation_date` AS `operation_date`,cast(`l`.`operation_status` as unsigned) AS `operation_status` from `tb_logs` `l` where (`l`.`table_name` = 'tbd_cancellation_items');

-- VISTA vw_trazabilidad_tbd_carts_items | línea 3442
CREATE VIEW `vw_trazabilidad_tbd_carts_items` AS select `l`.`ID` AS `log_id`,`l`.`table_name` AS `table_name`,(case when regexp_like(`l`.`description`,'ID=[0-9]+,') then cast(substring_index(substring_index(substring_index(`l`.`description`,', datos=',1),'ID=',-(1)),',',1) as unsigned) else NULL end) AS `record_id`,`l`.`operation` AS `operation`,`l`.`db_users` AS `db_user`,substring_index(`l`.`db_users`,'@',1) AS `username`,coalesce((select group_concat(distinct `re`.`FROM_USER` order by `re`.`FROM_USER` ASC separator ', ') from `mysql`.`role_edges` `re` where (`re`.`TO_USER` = substring_index(`l`.`db_users`,'@',1))),'Sin rol directo actual') AS `roles_actuales_por_nombre`,`l`.`description` AS `operation_description`,`l`.`operation_date` AS `operation_date`,cast(`l`.`operation_status` as unsigned) AS `operation_status` from `tb_logs` `l` where (`l`.`table_name` = 'tbd_carts_items');

-- VISTA vw_trazabilidad_tbd_order_itemes | línea 3460
CREATE VIEW `vw_trazabilidad_tbd_order_itemes` AS select `l`.`ID` AS `log_id`,`l`.`table_name` AS `table_name`,(case when regexp_like(`l`.`description`,'ID=[0-9]+,') then cast(substring_index(substring_index(substring_index(`l`.`description`,', datos=',1),'ID=',-(1)),',',1) as unsigned) else NULL end) AS `record_id`,`l`.`operation` AS `operation`,`l`.`db_users` AS `db_user`,substring_index(`l`.`db_users`,'@',1) AS `username`,coalesce((select group_concat(distinct `re`.`FROM_USER` order by `re`.`FROM_USER` ASC separator ', ') from `mysql`.`role_edges` `re` where (`re`.`TO_USER` = substring_index(`l`.`db_users`,'@',1))),'Sin rol directo actual') AS `roles_actuales_por_nombre`,`l`.`description` AS `operation_description`,`l`.`operation_date` AS `operation_date`,cast(`l`.`operation_status` as unsigned) AS `operation_status` from `tb_logs` `l` where (`l`.`table_name` = 'tbd_order_itemes');

-- VISTA vw_trazabilidad_tbd_products_categories | línea 3478
CREATE VIEW `vw_trazabilidad_tbd_products_categories` AS select `l`.`ID` AS `log_id`,`l`.`table_name` AS `table_name`,(case when regexp_like(`l`.`description`,'ID=[0-9]+,') then cast(substring_index(substring_index(substring_index(`l`.`description`,', datos=',1),'ID=',-(1)),',',1) as unsigned) else NULL end) AS `record_id`,`l`.`operation` AS `operation`,`l`.`db_users` AS `db_user`,substring_index(`l`.`db_users`,'@',1) AS `username`,coalesce((select group_concat(distinct `re`.`FROM_USER` order by `re`.`FROM_USER` ASC separator ', ') from `mysql`.`role_edges` `re` where (`re`.`TO_USER` = substring_index(`l`.`db_users`,'@',1))),'Sin rol directo actual') AS `roles_actuales_por_nombre`,`l`.`description` AS `operation_description`,`l`.`operation_date` AS `operation_date`,cast(`l`.`operation_status` as unsigned) AS `operation_status` from `tb_logs` `l` where (`l`.`table_name` = 'tbd_products_categories');

-- VISTA vw_trazabilidad_tbd_products_users_providers | línea 3496
CREATE VIEW `vw_trazabilidad_tbd_products_users_providers` AS select `l`.`ID` AS `log_id`,`l`.`table_name` AS `table_name`,(case when regexp_like(`l`.`description`,'ID=[0-9]+,') then cast(substring_index(substring_index(substring_index(`l`.`description`,', datos=',1),'ID=',-(1)),',',1) as unsigned) else NULL end) AS `record_id`,`l`.`operation` AS `operation`,`l`.`db_users` AS `db_user`,substring_index(`l`.`db_users`,'@',1) AS `username`,coalesce((select group_concat(distinct `re`.`FROM_USER` order by `re`.`FROM_USER` ASC separator ', ') from `mysql`.`role_edges` `re` where (`re`.`TO_USER` = substring_index(`l`.`db_users`,'@',1))),'Sin rol directo actual') AS `roles_actuales_por_nombre`,`l`.`description` AS `operation_description`,`l`.`operation_date` AS `operation_date`,cast(`l`.`operation_status` as unsigned) AS `operation_status` from `tb_logs` `l` where (`l`.`table_name` = 'tbd_products_users_providers');

-- VISTA vw_trazabilidad_tbd_return_items | línea 3514
CREATE VIEW `vw_trazabilidad_tbd_return_items` AS select `l`.`ID` AS `log_id`,`l`.`table_name` AS `table_name`,(case when regexp_like(`l`.`description`,'ID=[0-9]+,') then cast(substring_index(substring_index(substring_index(`l`.`description`,', datos=',1),'ID=',-(1)),',',1) as unsigned) else NULL end) AS `record_id`,`l`.`operation` AS `operation`,`l`.`db_users` AS `db_user`,substring_index(`l`.`db_users`,'@',1) AS `username`,coalesce((select group_concat(distinct `re`.`FROM_USER` order by `re`.`FROM_USER` ASC separator ', ') from `mysql`.`role_edges` `re` where (`re`.`TO_USER` = substring_index(`l`.`db_users`,'@',1))),'Sin rol directo actual') AS `roles_actuales_por_nombre`,`l`.`description` AS `operation_description`,`l`.`operation_date` AS `operation_date`,cast(`l`.`operation_status` as unsigned) AS `operation_status` from `tb_logs` `l` where (`l`.`table_name` = 'tbd_return_items');

-- VISTA vw_trazabilidad_tbd_user_payment_methods | línea 3532
CREATE VIEW `vw_trazabilidad_tbd_user_payment_methods` AS select `l`.`ID` AS `log_id`,`l`.`table_name` AS `table_name`,(case when regexp_like(`l`.`description`,'ID=[0-9]+,') then cast(substring_index(substring_index(substring_index(`l`.`description`,', datos=',1),'ID=',-(1)),',',1) as unsigned) else NULL end) AS `record_id`,`l`.`operation` AS `operation`,`l`.`db_users` AS `db_user`,substring_index(`l`.`db_users`,'@',1) AS `username`,coalesce((select group_concat(distinct `re`.`FROM_USER` order by `re`.`FROM_USER` ASC separator ', ') from `mysql`.`role_edges` `re` where (`re`.`TO_USER` = substring_index(`l`.`db_users`,'@',1))),'Sin rol directo actual') AS `roles_actuales_por_nombre`,`l`.`description` AS `operation_description`,`l`.`operation_date` AS `operation_date`,cast(`l`.`operation_status` as unsigned) AS `operation_status` from `tb_logs` `l` where (`l`.`table_name` = 'tbd_user_payment_methods');

-- VISTA vw_trazabilidad_tbd_users_wishilst_products | línea 3550
CREATE VIEW `vw_trazabilidad_tbd_users_wishilst_products` AS select `l`.`ID` AS `log_id`,`l`.`table_name` AS `table_name`,(case when regexp_like(`l`.`description`,'ID=[0-9]+,') then cast(substring_index(substring_index(substring_index(`l`.`description`,', datos=',1),'ID=',-(1)),',',1) as unsigned) else NULL end) AS `record_id`,`l`.`operation` AS `operation`,`l`.`db_users` AS `db_user`,substring_index(`l`.`db_users`,'@',1) AS `username`,coalesce((select group_concat(distinct `re`.`FROM_USER` order by `re`.`FROM_USER` ASC separator ', ') from `mysql`.`role_edges` `re` where (`re`.`TO_USER` = substring_index(`l`.`db_users`,'@',1))),'Sin rol directo actual') AS `roles_actuales_por_nombre`,`l`.`description` AS `operation_description`,`l`.`operation_date` AS `operation_date`,cast(`l`.`operation_status` as unsigned) AS `operation_status` from `tb_logs` `l` where (`l`.`table_name` = 'tbd_users_wishilst_products');

-- VISTA vw_trazabilidad_usuarios_creados | línea 3568
CREATE VIEW `vw_trazabilidad_usuarios_creados` AS select `u`.`nickname` AS `nickname`,`u`.`email` AS `email`,`b`.`db_users` AS `inserted_by`,coalesce((select group_concat(distinct `re`.`FROM_USER` order by `re`.`FROM_USER` ASC separator ', ') from `mysql`.`role_edges` `re` where (`re`.`TO_USER` = substring_index(`b`.`db_users`,'@',1))),'Sin roles') AS `roles`,`b`.`description` AS `operation_description`,`b`.`operation_date` AS `operation_date` from (`tb_logs` `b` join `tb_users` `u` on(((`b`.`description` like concat('%',`u`.`nickname`,'%')) and (`b`.`description` like concat('%',`u`.`email`,'%'))))) where ((`b`.`table_name` = 'tb_users') and (`b`.`operation` = 'Create')) order by `b`.`operation_date`;

-- TRIGGER trg_after_insert_tb_buyer_orders | línea 77
CREATE TRIGGER `trg_after_insert_tb_buyer_orders` AFTER INSERT ON `tb_buyer_orders` FOR EACH ROW BEGIN
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
END ;

-- TRIGGER trg_after_update_tb_buyer_orders | línea 117
CREATE TRIGGER `trg_after_update_tb_buyer_orders` AFTER UPDATE ON `tb_buyer_orders` FOR EACH ROW BEGIN
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
END ;

-- TRIGGER trg_after_delete_tb_buyer_orders | línea 174
CREATE TRIGGER `trg_after_delete_tb_buyer_orders` AFTER DELETE ON `tb_buyer_orders` FOR EACH ROW BEGIN
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
END ;

-- TRIGGER trg_after_insert_tb_carts | línea 245
CREATE TRIGGER `trg_after_insert_tb_carts` AFTER INSERT ON `tb_carts` FOR EACH ROW BEGIN
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
END ;

-- TRIGGER trg_after_update_tb_carts | línea 276
CREATE TRIGGER `trg_after_update_tb_carts` AFTER UPDATE ON `tb_carts` FOR EACH ROW BEGIN
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
END ;

-- TRIGGER trg_after_delete_tb_carts | línea 315
CREATE TRIGGER `trg_after_delete_tb_carts` AFTER DELETE ON `tb_carts` FOR EACH ROW BEGIN
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
END ;

-- TRIGGER trg_after_insert_tb_user_addresses | línea 776
CREATE TRIGGER `trg_after_insert_tb_user_addresses` AFTER INSERT ON `tb_user_addresses` FOR EACH ROW BEGIN
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
END ;

-- TRIGGER trg_after_update_tb_user_addresses | línea 807
CREATE TRIGGER `trg_after_update_tb_user_addresses` AFTER UPDATE ON `tb_user_addresses` FOR EACH ROW BEGIN
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
END ;

-- TRIGGER trg_after_delete_tb_user_addresses | línea 846
CREATE TRIGGER `trg_after_delete_tb_user_addresses` AFTER DELETE ON `tb_user_addresses` FOR EACH ROW BEGIN
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
END ;

-- TRIGGER trg_after_insert_tbc_carts_items | línea 935
CREATE TRIGGER `trg_after_insert_tbc_carts_items` AFTER INSERT ON `tbc_carts_items` FOR EACH ROW BEGIN
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
END ;

-- TRIGGER trg_after_update_tbc_carts_items | línea 964
CREATE TRIGGER `trg_after_update_tbc_carts_items` AFTER UPDATE ON `tbc_carts_items` FOR EACH ROW BEGIN
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
END ;

-- TRIGGER trg_after_delete_tbc_carts_items | línea 999
CREATE TRIGGER `trg_after_delete_tbc_carts_items` AFTER DELETE ON `tbc_carts_items` FOR EACH ROW BEGIN
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
END ;

-- TRIGGER trg_after_insert_tbc_categories | línea 1058
CREATE TRIGGER `trg_after_insert_tbc_categories` AFTER INSERT ON `tbc_categories` FOR EACH ROW BEGIN
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
END ;

-- TRIGGER trg_after_update_tbc_categories | línea 1089
CREATE TRIGGER `trg_after_update_tbc_categories` AFTER UPDATE ON `tbc_categories` FOR EACH ROW BEGIN
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
END ;

-- TRIGGER trg_after_delete_tbc_categories | línea 1128
CREATE TRIGGER `trg_after_delete_tbc_categories` AFTER DELETE ON `tbc_categories` FOR EACH ROW BEGIN
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
END ;

-- TRIGGER trg_after_insert_tbc_order_items | línea 1186
CREATE TRIGGER `trg_after_insert_tbc_order_items` AFTER INSERT ON `tbc_order_items` FOR EACH ROW BEGIN
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
END ;

-- TRIGGER trg_after_update_tbc_order_items | línea 1215
CREATE TRIGGER `trg_after_update_tbc_order_items` AFTER UPDATE ON `tbc_order_items` FOR EACH ROW BEGIN
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
END ;

-- TRIGGER trg_after_delete_tbc_order_items | línea 1250
CREATE TRIGGER `trg_after_delete_tbc_order_items` AFTER DELETE ON `tbc_order_items` FOR EACH ROW BEGIN
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
END ;

-- TRIGGER trg_after_insert_tbc_payment_methods_types | línea 1307
CREATE TRIGGER `trg_after_insert_tbc_payment_methods_types` AFTER INSERT ON `tbc_payment_methods_types` FOR EACH ROW BEGIN
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
END ;

-- TRIGGER trg_after_update_tbc_payment_methods_types | línea 1337
CREATE TRIGGER `trg_after_update_tbc_payment_methods_types` AFTER UPDATE ON `tbc_payment_methods_types` FOR EACH ROW BEGIN
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
END ;

-- TRIGGER trg_after_delete_tbc_payment_methods_types | línea 1374
CREATE TRIGGER `trg_after_delete_tbc_payment_methods_types` AFTER DELETE ON `tbc_payment_methods_types` FOR EACH ROW BEGIN
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
END ;

-- TRIGGER trg_after_insert_tbd_carts_items | línea 1470
CREATE TRIGGER `trg_after_insert_tbd_carts_items` AFTER INSERT ON `tbd_carts_items` FOR EACH ROW BEGIN
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
END ;

-- TRIGGER trg_after_update_tbd_carts_items | línea 1501
CREATE TRIGGER `trg_after_update_tbd_carts_items` AFTER UPDATE ON `tbd_carts_items` FOR EACH ROW BEGIN
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
END ;

-- TRIGGER trg_after_delete_tbd_carts_items | línea 1540
CREATE TRIGGER `trg_after_delete_tbd_carts_items` AFTER DELETE ON `tbd_carts_items` FOR EACH ROW BEGIN
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
END ;

-- TRIGGER trg_after_insert_tbd_order_itemes | línea 1612
CREATE TRIGGER `trg_after_insert_tbd_order_itemes` AFTER INSERT ON `tbd_order_itemes` FOR EACH ROW BEGIN
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
END ;

-- TRIGGER trg_after_update_tbd_order_itemes | línea 1649
CREATE TRIGGER `trg_after_update_tbd_order_itemes` AFTER UPDATE ON `tbd_order_itemes` FOR EACH ROW BEGIN
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
END ;

-- TRIGGER trg_after_delete_tbd_order_itemes | línea 1700
CREATE TRIGGER `trg_after_delete_tbd_order_itemes` AFTER DELETE ON `tbd_order_itemes` FOR EACH ROW BEGIN
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
END ;

-- TRIGGER trg_after_insert_tbd_products_categories | línea 1768
CREATE TRIGGER `trg_after_insert_tbd_products_categories` AFTER INSERT ON `tbd_products_categories` FOR EACH ROW BEGIN
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
END ;

-- TRIGGER trg_after_update_tbd_products_categories | línea 1798
CREATE TRIGGER `trg_after_update_tbd_products_categories` AFTER UPDATE ON `tbd_products_categories` FOR EACH ROW BEGIN
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
END ;

-- TRIGGER trg_after_delete_tbd_products_categories | línea 1835
CREATE TRIGGER `trg_after_delete_tbd_products_categories` AFTER DELETE ON `tbd_products_categories` FOR EACH ROW BEGIN
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
END ;

-- TRIGGER trg_after_insert_tbd_products_users_providers | línea 1899
CREATE TRIGGER `trg_after_insert_tbd_products_users_providers` AFTER INSERT ON `tbd_products_users_providers` FOR EACH ROW BEGIN
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
END ;

-- TRIGGER trg_after_update_tbd_products_users_providers | línea 1931
CREATE TRIGGER `trg_after_update_tbd_products_users_providers` AFTER UPDATE ON `tbd_products_users_providers` FOR EACH ROW BEGIN
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
END ;

-- TRIGGER trg_after_delete_tbd_products_users_providers | línea 1972
CREATE TRIGGER `trg_after_delete_tbd_products_users_providers` AFTER DELETE ON `tbd_products_users_providers` FOR EACH ROW BEGIN
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
END ;

-- TRIGGER trg_after_insert_tbd_user_payment_methods | línea 2077
CREATE TRIGGER `trg_after_insert_tbd_user_payment_methods` AFTER INSERT ON `tbd_user_payment_methods` FOR EACH ROW BEGIN
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
END ;

-- TRIGGER trg_after_update_tbd_user_payment_methods | línea 2108
CREATE TRIGGER `trg_after_update_tbd_user_payment_methods` AFTER UPDATE ON `tbd_user_payment_methods` FOR EACH ROW BEGIN
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
END ;

-- TRIGGER trg_after_delete_tbd_user_payment_methods | línea 2147
CREATE TRIGGER `trg_after_delete_tbd_user_payment_methods` AFTER DELETE ON `tbd_user_payment_methods` FOR EACH ROW BEGIN
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
END ;

-- TRIGGER trg_after_insert_tbd_users_wishilst_products | línea 2209
CREATE TRIGGER `trg_after_insert_tbd_users_wishilst_products` AFTER INSERT ON `tbd_users_wishilst_products` FOR EACH ROW BEGIN
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
END ;

-- TRIGGER trg_after_update_tbd_users_wishilst_products | línea 2239
CREATE TRIGGER `trg_after_update_tbd_users_wishilst_products` AFTER UPDATE ON `tbd_users_wishilst_products` FOR EACH ROW BEGIN
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
END ;

-- TRIGGER trg_after_delete_tbd_users_wishilst_products | línea 2276
CREATE TRIGGER `trg_after_delete_tbd_users_wishilst_products` AFTER DELETE ON `tbd_users_wishilst_products` FOR EACH ROW BEGIN
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
END ;

-- PROCEDURE sp_deactivate_user | línea 2893
CREATE PROCEDURE `sp_deactivate_user`(
    IN p_user_id INT UNSIGNED
)
BEGIN
    -- 1. Validar que el usuario exista en la tabla
    IF NOT EXISTS (
        SELECT 1
        FROM tb_users
        WHERE ID = p_user_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El usuario especificado no existe';
    END IF;

    -- 2. Validar si el usuario ya se encuentra inactivo
    IF EXISTS (
        SELECT 1
        FROM tb_users
        WHERE ID = p_user_id
          AND status = b'0'
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El usuario ya se encuentra inactivo';
    END IF;

    -- 3. Desactivar el usuario
    UPDATE tb_users
    SET status = b'0'
    WHERE ID = p_user_id;

END;

-- PROCEDURE sp_register_user | línea 2939
CREATE PROCEDURE `sp_register_user`(
    IN p_email VARCHAR(80),
    IN p_nickname VARCHAR(100),
    IN p_password VARCHAR(255),

    IN p_title VARCHAR(30),
    IN p_given_names VARCHAR(150),
    IN p_family_names VARCHAR(150),
    IN p_birth_date DATE,
    IN p_gender_ID TINYINT UNSIGNED,
    IN p_phone VARCHAR(25),
    IN p_country_code CHAR(2)
)
    MODIFIES SQL DATA
BEGIN
    DECLARE v_user_ID INT UNSIGNED;
    DECLARE v_person_ID BIGINT UNSIGNED;

    -- Manejo de errores: si algo falla dentro del bloque, revierte la transacción
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- 1. Crear la cuenta de usuario en tb_users
    INSERT INTO `tb_users` (
        `email`,
        `nickname`,
        `password`,
        `status`
    )
    VALUES (
        p_email,
        p_nickname,
        p_password,
        b'1'
    );

    SET v_user_ID = LAST_INSERT_ID();

    -- 2. Crear los datos personales relacionados en tb_people
    INSERT INTO `tb_people` (
        `user_ID`,
        `title`,
        `given_names`,
        `family_names`,
        `birth_date`,
        `gender_ID`,
        `phone`,
        `country_code`,
        `status`
    )
    VALUES (
        v_user_ID,
        p_title,
        p_given_names,
        p_family_names,
        p_birth_date,
        p_gender_ID,
        p_phone,
        p_country_code,
        b'1'
    );

    SET v_person_ID = LAST_INSERT_ID();

    COMMIT;

    -- 3. Devolver los identificadores creados
    SELECT
        v_user_ID AS user_ID,
        v_person_ID AS person_ID,
        'Usuario registrado correctamente' AS mensaje;

END;

-- PROCEDURE sp_restore_product | línea 3032
CREATE PROCEDURE `sp_restore_product`(
    IN p_product_id INT UNSIGNED
)
BEGIN
    -- 1. Validar si el producto existe
    IF NOT EXISTS (
        SELECT 1
        FROM tb_products
        WHERE ID = p_product_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El producto especificado no existe';
    END IF;

    -- 2. Validar si el producto ya está activo
    IF EXISTS (
        SELECT 1
        FROM tb_products
        WHERE ID = p_product_id
          AND status = b'1'
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El producto ya se encuentra activo';
    END IF;

    -- 3. Restaurar / Activar el producto
    UPDATE tb_products
    SET status = b'1'
    WHERE ID = p_product_id;

END;
