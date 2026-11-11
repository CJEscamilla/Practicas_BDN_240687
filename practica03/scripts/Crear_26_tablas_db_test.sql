-- Scripts de creación de las 26 tablas extraídos de Respaldo_27102026.sql
-- Base de datos: db_test
CREATE DATABASE IF NOT EXISTS `db_test` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */;
USE `db_test`;
SET FOREIGN_KEY_CHECKS=0;

-- Tabla 1: tb_carts
CREATE TABLE `tb_carts` (
  `ID` int unsigned NOT NULL AUTO_INCREMENT,
  `user_ID` int unsigned NOT NULL,
  `status` bit(1) DEFAULT b'1',
  `creation_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_update` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `uk_cart_user` (`user_ID`),
  CONSTRAINT `fk_cart_user` FOREIGN KEY (`user_ID`) REFERENCES `tb_users` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Tabla 2: tb_logs
CREATE TABLE `tb_logs` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `table_name` varchar(100) NOT NULL,
  `operation` enum('Create','Read','Update','Delete') NOT NULL,
  `db_users` varchar(80) NOT NULL,
  `description` text NOT NULL,
  `operation_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `operation_status` bit(1) DEFAULT b'1',
  PRIMARY KEY (`ID`),
  KEY `idx_logs_table_operation_date` (`table_name`,`operation`,`operation_date`)
) ENGINE=InnoDB AUTO_INCREMENT=78291 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Tabla 3: tb_order_cancellations
CREATE TABLE `tb_order_cancellations` (
  `ID` int unsigned NOT NULL AUTO_INCREMENT,
  `order_ID` int unsigned DEFAULT NULL,
  `buyer_order_ID` int unsigned DEFAULT NULL,
  `requested_by_user_ID` int unsigned DEFAULT NULL,
  `cancellation_scope` enum('WholeOrder','SellerOrder','Items') NOT NULL DEFAULT 'WholeOrder',
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
  KEY `idx_cancellations_buyer_order` (`buyer_order_ID`),
  KEY `idx_cancellations_requester` (`requested_by_user_ID`),
  CONSTRAINT `fk_cancellations_buyer_order` FOREIGN KEY (`buyer_order_ID`) REFERENCES `tbd_buyer_orders` (`ID`),
  CONSTRAINT `fk_cancellations_order` FOREIGN KEY (`order_ID`) REFERENCES `tb_orders` (`ID`),
  CONSTRAINT `fk_cancellations_requester` FOREIGN KEY (`requested_by_user_ID`) REFERENCES `tb_users` (`ID`),
  CONSTRAINT `chk_cancellations_target` CHECK ((((`cancellation_scope` = _utf8mb4'WholeOrder') and (`order_ID` is not null) and (`buyer_order_ID` is null)) or ((`cancellation_scope` in (_utf8mb4'SellerOrder',_utf8mb4'Items')) and (`buyer_order_ID` is not null))))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Tabla 4: tb_orders
CREATE TABLE `tb_orders` (
  `ID` int unsigned NOT NULL AUTO_INCREMENT,
  `key` varchar(40) NOT NULL,
  `User_ID` int unsigned NOT NULL,
  `total_products` int NOT NULL,
  `total_cost` decimal(10,3) NOT NULL DEFAULT '0.000',
  `status_string` enum('Registered','Payed','Canceled','Delivered','Devolved','Attended','Sended') NOT NULL DEFAULT 'Registered',
  `status` bit(1) DEFAULT b'1',
  `creation_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_update` datetime DEFAULT NULL,
  PRIMARY KEY (`ID`),
  KEY `fk_user_2_idx` (`User_ID`),
  CONSTRAINT `fk_user_2` FOREIGN KEY (`User_ID`) REFERENCES `tb_users` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Tabla 5: tb_payment_methods
CREATE TABLE `tb_payment_methods` (
  `ID` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(60) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `status` bit(1) NOT NULL DEFAULT b'1',
  `creation_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_update` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `uk_payment_method_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Tabla 6: tb_payment_transaction
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

-- Tabla 7: tb_payments
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
  CONSTRAINT `fk_payment_order` FOREIGN KEY (`order_ID`) REFERENCES `tb_orders` (`ID`),
  CONSTRAINT `chk_payment_amount` CHECK ((`amount` > 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Tabla 8: tb_people
CREATE TABLE `tb_people` (
  `person_ID` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_ID` int unsigned NOT NULL,
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
) ENGINE=InnoDB AUTO_INCREMENT=16386 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Tabla 9: tb_products
CREATE TABLE `tb_products` (
  `ID` int unsigned NOT NULL AUTO_INCREMENT,
  `SKU` varchar(50) NOT NULL,
  `name` varchar(250) NOT NULL,
  `description` text,
  `current_price` decimal(10,2) NOT NULL DEFAULT '0.00',
  `current_stock` int unsigned NOT NULL DEFAULT '0',
  `status` bit(1) DEFAULT b'1',
  `creation_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_update` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `SKU` (`SKU`)
) ENGINE=InnoDB AUTO_INCREMENT=24977 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Tabla 10: tb_refunds
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
  `requested_by_user_ID` int unsigned DEFAULT NULL,
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

-- Tabla 11: tb_returns
CREATE TABLE `tb_returns` (
  `ID` int unsigned NOT NULL AUTO_INCREMENT,
  `buyer_order_ID` int unsigned NOT NULL,
  `requested_by_user_ID` int unsigned DEFAULT NULL,
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
  KEY `idx_returns_buyer_order` (`buyer_order_ID`),
  KEY `idx_returns_requester` (`requested_by_user_ID`),
  KEY `idx_returns_tracking` (`return_carrier`,`return_tracking_number`),
  CONSTRAINT `fk_returns_buyer_order` FOREIGN KEY (`buyer_order_ID`) REFERENCES `tbd_buyer_orders` (`ID`),
  CONSTRAINT `fk_returns_requester` FOREIGN KEY (`requested_by_user_ID`) REFERENCES `tb_users` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Tabla 12: tb_shipments
CREATE TABLE `tb_shipments` (
  `ID` int unsigned NOT NULL AUTO_INCREMENT,
  `buyer_order_ID` int unsigned NOT NULL,
  `address_ID` bigint unsigned DEFAULT NULL,
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
  KEY `idx_shipments_buyer_order` (`buyer_order_ID`),
  KEY `idx_shipments_address` (`address_ID`),
  KEY `idx_shipments_tracking` (`carrier`,`tracking_number`),
  CONSTRAINT `fk_shipments_address` FOREIGN KEY (`address_ID`) REFERENCES `tb_user_addresses` (`ID`),
  CONSTRAINT `fk_shipments_buyer_order` FOREIGN KEY (`buyer_order_ID`) REFERENCES `tbd_buyer_orders` (`ID`),
  CONSTRAINT `chk_shipments_shipping_cost` CHECK ((`shipping_cost` >= 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Tabla 13: tb_user_addresses
CREATE TABLE `tb_user_addresses` (
  `ID` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_ID` int unsigned NOT NULL,
  `address_label` varchar(100) NOT NULL,
  `recipient_name` varchar(150) DEFAULT NULL,
  `recipient_phone` varchar(25) DEFAULT NULL,
  `delivery_instructions` varchar(500) DEFAULT NULL,
  `latitude` decimal(10,7) DEFAULT NULL,
  `longitude` decimal(10,7) DEFAULT NULL,
  `is_default` tinyint(1) NOT NULL DEFAULT '0',
  `status` bit(1) NOT NULL DEFAULT b'1',
  `creation_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_update` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`),
  KEY `idx_user_addresses` (`user_ID`),
  CONSTRAINT `fk_addresses_users` FOREIGN KEY (`user_ID`) REFERENCES `tb_users` (`ID`),
  CONSTRAINT `chk_coordinates` CHECK ((((`latitude` is null) and (`longitude` is null)) or ((`latitude` is not null) and (`longitude` is not null)))),
  CONSTRAINT `chk_latitude` CHECK ((`latitude` between -(90) and 90)),
  CONSTRAINT `chk_longitude` CHECK ((`longitude` between -(180) and 180))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Tabla 14: tb_users
CREATE TABLE `tb_users` (
  `ID` int unsigned NOT NULL AUTO_INCREMENT,
  `email` varchar(80) NOT NULL,
  `nickname` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `creation_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_update` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `last_login` datetime DEFAULT NULL,
  `status` bit(1) NOT NULL DEFAULT b'1',
  PRIMARY KEY (`ID`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `nickname` (`nickname`)
) ENGINE=InnoDB AUTO_INCREMENT=16405 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Tabla 15: tbc_categories
CREATE TABLE `tbc_categories` (
  `ID` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(120) NOT NULL,
  `description` text,
  `sup_id_category` int unsigned DEFAULT NULL,
  `status` bit(1) NOT NULL DEFAULT b'1',
  `creation_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_update` datetime NOT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `name` (`name`),
  KEY `fk_superior_category` (`sup_id_category`),
  CONSTRAINT `fk_superior_category` FOREIGN KEY (`sup_id_category`) REFERENCES `tbc_categories` (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=101 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Tabla 16: tbc_payment_methods_types
CREATE TABLE `tbc_payment_methods_types` (
  `ID` int unsigned NOT NULL AUTO_INCREMENT,
  `code` varchar(30) NOT NULL,
  `description` text NOT NULL,
  `status` bit(1) NOT NULL DEFAULT b'1',
  `creation_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_update` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `code_UNIQUE` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Tabla 17: tbd_address_components
CREATE TABLE `tbd_address_components` (
  `ID` bigint unsigned NOT NULL AUTO_INCREMENT,
  `address_ID` bigint unsigned NOT NULL,
  `value` varchar(255) NOT NULL,
  `component_type` varchar(50) NOT NULL,
  `status` bit(1) NOT NULL DEFAULT b'1',
  `address_sup_ID` bigint unsigned DEFAULT NULL,
  `creation_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_update` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `uk_address_component` (`address_ID`,`ID`),
  KEY `idx_address_parent` (`address_ID`,`address_sup_ID`),
  CONSTRAINT `fk_component_address` FOREIGN KEY (`address_ID`) REFERENCES `tb_user_addresses` (`ID`) ON DELETE RESTRICT,
  CONSTRAINT `fk_component_parent` FOREIGN KEY (`address_ID`, `address_sup_ID`) REFERENCES `tbd_address_components` (`address_ID`, `ID`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Tabla 18: tbd_buyer_orders
CREATE TABLE `tbd_buyer_orders` (
  `ID` int unsigned NOT NULL AUTO_INCREMENT,
  `seller_ID` int unsigned NOT NULL,
  `subtotal` decimal(12,2) NOT NULL DEFAULT '0.00',
  `shipping_cost` decimal(12,2) NOT NULL DEFAULT '0.00',
  `fulfillment_status` enum('Pending','Accepted','Preparing','Sent','Delivered','Canceled','Returned') NOT NULL DEFAULT 'Pending',
  `status` bit(1) NOT NULL DEFAULT b'1',
  `creation_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_update` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`),
  KEY `seller_ID` (`seller_ID`),
  CONSTRAINT `tbd_buyer_orders_ibfk_1` FOREIGN KEY (`seller_ID`) REFERENCES `tb_users` (`ID`),
  CONSTRAINT `tbd_buyer_orders_chk_1` CHECK ((`subtotal` >= 0)),
  CONSTRAINT `tbd_buyer_orders_chk_2` CHECK ((`shipping_cost` >= 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Tabla 19: tbd_cancellation_items
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
  CONSTRAINT `fk_cancellation_items_order_item` FOREIGN KEY (`order_item_ID`) REFERENCES `tbd_order_items` (`ID`),
  CONSTRAINT `chk_cancellation_items_quantity` CHECK ((`quantity` > 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Tabla 20: tbd_cart_items
CREATE TABLE `tbd_cart_items` (
  `cart_ID` int unsigned NOT NULL,
  `provider_ID` int unsigned NOT NULL,
  `product_ID` int unsigned NOT NULL,
  `quantity` int unsigned NOT NULL DEFAULT '1',
  `creation_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`cart_ID`,`provider_ID`,`product_ID`),
  KEY `provider_ID` (`provider_ID`),
  KEY `product_ID` (`product_ID`),
  CONSTRAINT `tbd_cart_items_ibfk_1` FOREIGN KEY (`cart_ID`) REFERENCES `tb_carts` (`ID`),
  CONSTRAINT `tbd_cart_items_ibfk_2` FOREIGN KEY (`provider_ID`) REFERENCES `tbd_products_users_providers` (`user_id`),
  CONSTRAINT `tbd_cart_items_ibfk_3` FOREIGN KEY (`product_ID`) REFERENCES `tbd_products_users_providers` (`product_id`),
  CONSTRAINT `chk_cart_quantity` CHECK ((`quantity` > 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Tabla 21: tbd_order_items
CREATE TABLE `tbd_order_items` (
  `ID` int unsigned NOT NULL AUTO_INCREMENT,
  `buyer_order_ID` int unsigned NOT NULL,
  `product_ID` int unsigned NOT NULL,
  `provider_ID` int unsigned NOT NULL,
  `product_name` varchar(255) NOT NULL,
  `quantity` int unsigned NOT NULL,
  `unit_price` decimal(12,2) NOT NULL,
  `subtotal` decimal(12,2) GENERATED ALWAYS AS ((`quantity` * `unit_price`)) STORED,
  `creation_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`),
  KEY `fk_order_items_product` (`product_ID`),
  KEY `fk_order_items_provider` (`provider_ID`),
  KEY `fk_order_items_buyer_order` (`buyer_order_ID`),
  CONSTRAINT `fk_order_items_buyer_order` FOREIGN KEY (`buyer_order_ID`) REFERENCES `tbd_buyer_orders` (`ID`),
  CONSTRAINT `fk_order_items_product` FOREIGN KEY (`product_ID`) REFERENCES `tbd_products_users_providers` (`product_id`),
  CONSTRAINT `fk_order_items_provider` FOREIGN KEY (`provider_ID`) REFERENCES `tbd_products_users_providers` (`user_id`),
  CONSTRAINT `chk_order_items_quantity` CHECK ((`quantity` > 0)),
  CONSTRAINT `chk_order_items_unit_price` CHECK ((`unit_price` >= 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Tabla 22: tbd_products_categories
CREATE TABLE `tbd_products_categories` (
  `category_ID` int unsigned NOT NULL,
  `product_ID` int unsigned NOT NULL,
  `status` bit(1) NOT NULL DEFAULT b'1',
  `creation_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_update` datetime NOT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`category_ID`,`product_ID`),
  KEY `fk_product` (`product_ID`),
  CONSTRAINT `fk_category` FOREIGN KEY (`category_ID`) REFERENCES `tbc_categories` (`ID`),
  CONSTRAINT `fk_product` FOREIGN KEY (`product_ID`) REFERENCES `tb_products` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Tabla 23: tbd_products_users_providers
CREATE TABLE `tbd_products_users_providers` (
  `user_id` int unsigned NOT NULL,
  `product_id` int unsigned NOT NULL,
  `type_ownership` enum('Owner','Reseller','Distributor') DEFAULT NULL,
  `status` bit(1) NOT NULL DEFAULT b'1',
  `avalaible_date` datetime NOT NULL,
  `creation_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_update` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`,`product_id`),
  KEY `fk_products2` (`product_id`),
  CONSTRAINT `fk_products2` FOREIGN KEY (`product_id`) REFERENCES `tb_products` (`ID`),
  CONSTRAINT `fk_user1` FOREIGN KEY (`user_id`) REFERENCES `tb_users` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Tabla 24: tbd_return_items
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
  CONSTRAINT `fk_return_items_order_item` FOREIGN KEY (`order_item_ID`) REFERENCES `tbd_order_items` (`ID`),
  CONSTRAINT `fk_return_items_return` FOREIGN KEY (`return_ID`) REFERENCES `tb_returns` (`ID`),
  CONSTRAINT `chk_return_items_quantity` CHECK ((`quantity` > 0)),
  CONSTRAINT `chk_return_items_refund_amount` CHECK ((`approved_refund_amount` >= 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Tabla 25: tbd_user_payment_methods
CREATE TABLE `tbd_user_payment_methods` (
  `ID` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_ID` int unsigned NOT NULL,
  `payment_method_type_ID` int unsigned NOT NULL,
  `provider` varchar(60) NOT NULL,
  `provider_method_ref` varchar(255) NOT NULL,
  `label` varchar(100) DEFAULT NULL,
  `last_four` char(4) DEFAULT NULL,
  `is_default` tinyint(1) NOT NULL DEFAULT '0',
  `status` bit(1) NOT NULL DEFAULT b'1',
  `creation_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_update` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `uk_provider_method` (`provider`,`provider_method_ref`),
  KEY `user_ID` (`user_ID`),
  KEY `payment_method_type_ID` (`payment_method_type_ID`),
  CONSTRAINT `tbd_user_payment_methods_ibfk_1` FOREIGN KEY (`user_ID`) REFERENCES `tb_users` (`ID`),
  CONSTRAINT `tbd_user_payment_methods_ibfk_2` FOREIGN KEY (`payment_method_type_ID`) REFERENCES `tbc_payment_methods_types` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Tabla 26: tbd_users_wishlist_products
CREATE TABLE `tbd_users_wishlist_products` (
  `user_ID` int unsigned NOT NULL,
  `product_ID` int unsigned NOT NULL,
  `status` bit(1) NOT NULL DEFAULT b'1',
  `creation_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_update` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_ID`,`product_ID`),
  KEY `fk_wishlist_product` (`product_ID`),
  CONSTRAINT `fk_wishlist_product` FOREIGN KEY (`product_ID`) REFERENCES `tb_products` (`ID`),
  CONSTRAINT `fk_wishlist_user` FOREIGN KEY (`user_ID`) REFERENCES `tb_users` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SET FOREIGN_KEY_CHECKS=1;