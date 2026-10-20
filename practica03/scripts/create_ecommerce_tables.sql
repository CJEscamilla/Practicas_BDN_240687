-- MySQL 8.0.36. Ejecutar como admin en db_test tras revisar el esquema real.
-- Requiere tb_users.ID INT y tb_products.ID INT UNSIGNED (InnoDB).
-- No elimina datos. CREATE IF NOT EXISTS no actualiza tablas preexistentes.
-- DDL hace COMMIT implicito: respaldar primero; no es una migracion atomica.
-- tbc_order_items y tbc_carts_items se interpretan como catalogos de estados.
USE db_test;

-- Ya existe en el respaldo: conservar estructura y categorias actuales.
CREATE TABLE IF NOT EXISTS tbc_categories (
    ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    name VARCHAR(120) NOT NULL,
    description TEXT,
    sup_id_category INT UNSIGNED DEFAULT NULL,
    status BIT(1) NOT NULL DEFAULT b'1',
    creation_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_update DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (ID), UNIQUE KEY name_UNIQUE (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
-- Se conserva la ausencia de FK jerarquica para no modificar la tabla existente.

CREATE TABLE IF NOT EXISTS tbc_payment_methods_types (
    ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    code VARCHAR(40) NOT NULL,
    name VARCHAR(100) NOT NULL,
    status BIT(1) NOT NULL DEFAULT b'1',
    creation_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_update DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (ID), UNIQUE KEY uq_payment_type_code (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS tbc_order_items (
    ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    code VARCHAR(40) NOT NULL,
    name VARCHAR(100) NOT NULL,
    description VARCHAR(255),
    status BIT(1) NOT NULL DEFAULT b'1',
    PRIMARY KEY (ID), UNIQUE KEY uq_order_item_state (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS tbc_carts_items (
    ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    code VARCHAR(40) NOT NULL,
    name VARCHAR(100) NOT NULL,
    description VARCHAR(255),
    status BIT(1) NOT NULL DEFAULT b'1',
    PRIMARY KEY (ID), UNIQUE KEY uq_cart_item_state (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS tb_user_addresses (
    ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    user_ID INT NOT NULL,
    label VARCHAR(60) NOT NULL,
    recipient_name VARCHAR(150) NOT NULL,
    phone VARCHAR(30),
    street VARCHAR(200) NOT NULL,
    exterior_number VARCHAR(30) NOT NULL,
    interior_number VARCHAR(30),
    neighborhood VARCHAR(120),
    city VARCHAR(120) NOT NULL,
    state VARCHAR(120) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    country_code CHAR(2) NOT NULL DEFAULT 'MX',
    delivery_instructions VARCHAR(500),
    status BIT(1) NOT NULL DEFAULT b'1',
    creation_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_update DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (ID),
    UNIQUE KEY uq_address_owner (user_ID, ID),
    CONSTRAINT fk_address_user FOREIGN KEY (user_ID) REFERENCES tb_users(ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS tbd_user_payment_methods (
    ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    user_ID INT NOT NULL,
    payment_method_type_ID INT UNSIGNED NOT NULL,
    provider VARCHAR(80) NOT NULL,
    provider_reference VARCHAR(255) NOT NULL COMMENT 'Token o referencia externa; nunca PAN completo ni CVV',
    display_name VARCHAR(100) NOT NULL,
    last_four CHAR(4),
    status BIT(1) NOT NULL DEFAULT b'1',
    creation_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_update DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (ID), UNIQUE KEY uq_payment_owner (user_ID, ID),
    UNIQUE KEY uq_user_provider_reference (user_ID, provider, provider_reference),
    CONSTRAINT fk_payment_user FOREIGN KEY (user_ID) REFERENCES tb_users(ID),
    CONSTRAINT fk_payment_type FOREIGN KEY (payment_method_type_ID) REFERENCES tbc_payment_methods_types(ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS tb_carts (
    ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    user_ID INT NOT NULL,
    status ENUM('active','converted','abandoned') NOT NULL DEFAULT 'active',
    currency CHAR(3) NOT NULL DEFAULT 'MXN',
    active_user_ID INT GENERATED ALWAYS AS (CASE WHEN status = 'active' THEN user_ID ELSE NULL END) STORED,
    creation_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_update DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (ID), UNIQUE KEY uq_active_cart_user (active_user_ID),
    UNIQUE KEY uq_cart_owner (user_ID, ID),
    CONSTRAINT fk_cart_user FOREIGN KEY (user_ID) REFERENCES tb_users(ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS tb_buyer_orders (
    ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    order_number VARCHAR(40) NOT NULL,
    buyer_user_ID INT NOT NULL,
    cart_ID INT UNSIGNED,
    shipping_address_ID INT UNSIGNED NOT NULL,
    user_payment_method_ID INT UNSIGNED,
    status ENUM('pending','confirmed','processing','shipped','delivered','cancelled') NOT NULL DEFAULT 'pending',
    payment_status ENUM('pending','authorized','paid','failed','refunded') NOT NULL DEFAULT 'pending',
    currency CHAR(3) NOT NULL DEFAULT 'MXN',
    shipping_address_snapshot JSON NOT NULL COMMENT 'Copia completa del destinatario y direccion al comprar',
    subtotal DECIMAL(14,2) NOT NULL,
    discount_total DECIMAL(14,2) NOT NULL DEFAULT 0,
    tax_total DECIMAL(14,2) NOT NULL DEFAULT 0,
    shipping_total DECIMAL(14,2) NOT NULL DEFAULT 0,
    grand_total DECIMAL(14,2) GENERATED ALWAYS AS (subtotal - discount_total + tax_total + shipping_total) STORED,
    creation_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_update DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (ID), UNIQUE KEY uq_order_number (order_number),
    UNIQUE KEY uq_order_cart (cart_ID), KEY idx_order_buyer_date (buyer_user_ID, creation_date),
    CONSTRAINT fk_order_buyer FOREIGN KEY (buyer_user_ID) REFERENCES tb_users(ID),
    CONSTRAINT fk_order_cart_owner FOREIGN KEY (buyer_user_ID, cart_ID) REFERENCES tb_carts(user_ID, ID),
    CONSTRAINT fk_order_address_owner FOREIGN KEY (buyer_user_ID, shipping_address_ID) REFERENCES tb_user_addresses(user_ID, ID),
    CONSTRAINT fk_order_payment_owner FOREIGN KEY (buyer_user_ID, user_payment_method_ID) REFERENCES tbd_user_payment_methods(user_ID, ID),
    CONSTRAINT chk_order_amounts CHECK (subtotal >= 0 AND discount_total >= 0 AND discount_total <= subtotal AND tax_total >= 0 AND shipping_total >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS tbd_order_itemes (
    ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    order_ID INT UNSIGNED NOT NULL,
    product_ID INT UNSIGNED NOT NULL,
    order_item_status_ID INT UNSIGNED NOT NULL,
    product_sku_snapshot VARCHAR(50) NOT NULL,
    product_name_snapshot VARCHAR(250) NOT NULL,
    quantity INT UNSIGNED NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    discount_total DECIMAL(14,2) NOT NULL DEFAULT 0,
    tax_total DECIMAL(14,2) NOT NULL DEFAULT 0,
    line_total DECIMAL(14,2) GENERATED ALWAYS AS (quantity * unit_price - discount_total + tax_total) STORED,
    creation_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_update DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (ID), UNIQUE KEY uq_order_product (order_ID, product_ID),
    CONSTRAINT fk_order_detail_order FOREIGN KEY (order_ID) REFERENCES tb_buyer_orders(ID),
    CONSTRAINT fk_order_detail_product FOREIGN KEY (product_ID) REFERENCES tb_products(ID),
    CONSTRAINT fk_order_detail_state FOREIGN KEY (order_item_status_ID) REFERENCES tbc_order_items(ID),
    CONSTRAINT chk_order_detail_amounts CHECK (quantity > 0 AND unit_price >= 0 AND discount_total >= 0 AND discount_total <= quantity * unit_price AND tax_total >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS tbd_carts_items (
    ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    cart_ID INT UNSIGNED NOT NULL,
    product_ID INT UNSIGNED NOT NULL,
    cart_item_status_ID INT UNSIGNED NOT NULL,
    quantity INT UNSIGNED NOT NULL,
    creation_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_update DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (ID), UNIQUE KEY uq_cart_product (cart_ID, product_ID),
    CONSTRAINT fk_cart_detail_cart FOREIGN KEY (cart_ID) REFERENCES tb_carts(ID),
    CONSTRAINT fk_cart_detail_product FOREIGN KEY (product_ID) REFERENCES tb_products(ID),
    CONSTRAINT fk_cart_detail_state FOREIGN KEY (cart_item_status_ID) REFERENCES tbc_carts_items(ID),
    CONSTRAINT chk_cart_quantity CHECK (quantity > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS tbd_products_categories (
    ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    product_ID INT UNSIGNED NOT NULL,
    category_ID INT UNSIGNED NOT NULL,
    status BIT(1) NOT NULL DEFAULT b'1',
    creation_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_update DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (ID), UNIQUE KEY uq_product_category (product_ID, category_ID),
    CONSTRAINT fk_product_category_product FOREIGN KEY (product_ID) REFERENCES tb_products(ID),
    CONSTRAINT fk_product_category_category FOREIGN KEY (category_ID) REFERENCES tbc_categories(ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS tbd_products_users_providers (
    ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    product_ID INT UNSIGNED NOT NULL,
    provider_user_ID INT NOT NULL COMMENT 'Proveedor de la plataforma, no cuenta de mysql.user',
    provider_sku VARCHAR(80),
    acquisition_cost DECIMAL(10,2),
    status BIT(1) NOT NULL DEFAULT b'1',
    creation_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_update DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (ID), UNIQUE KEY uq_product_provider (product_ID, provider_user_ID),
    CONSTRAINT fk_provider_product FOREIGN KEY (product_ID) REFERENCES tb_products(ID),
    CONSTRAINT fk_provider_user FOREIGN KEY (provider_user_ID) REFERENCES tb_users(ID),
    CONSTRAINT chk_provider_cost CHECK (acquisition_cost IS NULL OR acquisition_cost >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS tbd_users_wishilst_products (
    ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    user_ID INT NOT NULL,
    product_ID INT UNSIGNED NOT NULL,
    status BIT(1) NOT NULL DEFAULT b'1',
    creation_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_update DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (ID), UNIQUE KEY uq_wishlist_user_product (user_ID, product_ID),
    CONSTRAINT fk_wishlist_user FOREIGN KEY (user_ID) REFERENCES tb_users(ID),
    CONSTRAINT fk_wishlist_product FOREIGN KEY (product_ID) REFERENCES tb_products(ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- No se importan CSV ni se cambian permisos. Poblar los catalogos de estados
-- y tipos de pago antes de crear detalles y medios de pago, respectivamente.
