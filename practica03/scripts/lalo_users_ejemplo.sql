/* ============================================================
   1. CREACIÓN DE USUARIOS
   ============================================================ */
CREATE USER IF NOT EXISTS 'jose.amaro'@'%' IDENTIFIED BY '240726';
CREATE USER IF NOT EXISTS 'marco.ramirez'@'%' IDENTIFIED BY 'qwerty123';
CREATE USER IF NOT EXISTS 'jorge.garcia'@'%' IDENTIFIED BY '240508';
CREATE USER IF NOT EXISTS 'omar.sampayo'@'%' IDENTIFIED BY '240428';
CREATE USER IF NOT EXISTS 'jhosep.escamilla'@'%' IDENTIFIED BY '240687';
CREATE USER IF NOT EXISTS 'uriel.gonzalez'@'%' IDENTIFIED BY '240463';
CREATE USER IF NOT EXISTS 'yhostin.ramirez'@'%' IDENTIFIED BY '240071';
CREATE USER IF NOT EXISTS 'eduardo.amaro'@'%' IDENTIFIED BY '240726';
CREATE USER IF NOT EXISTS 'jose.castillo'@'%' IDENTIFIED BY '240628';
CREATE USER IF NOT EXISTS 'app.movil'@'%' IDENTIFIED BY 'Moblile890';
CREATE USER IF NOT EXISTS 'app.web'@'%' IDENTIFIED BY 'Web123';

/* ============================================================
   2. CREACIÓN DE ROLES PARA EL SISTEMA E-COMMERCE
   ============================================================ */
CREATE ROLE IF NOT EXISTS 'superadmin';
CREATE ROLE IF NOT EXISTS 'admin';
CREATE ROLE IF NOT EXISTS 'seller';
CREATE ROLE IF NOT EXISTS 'buyer';
CREATE ROLE IF NOT EXISTS 'common';
CREATE ROLE IF NOT EXISTS 'common_user';
CREATE ROLE IF NOT EXISTS 'user_not_registered';
CREATE ROLE IF NOT EXISTS 'support';

/* ============================================================
   3. ASIGNACIÓN DE PRIVILEGIOS A LOS ROLES
   ============================================================ */

/* SUPERADMIN */
GRANT ALL PRIVILEGES ON *.* TO 'superadmin' WITH GRANT OPTION;   

/* ADMIN */
GRANT ALL PRIVILEGES ON db_test.* TO 'admin';
GRANT ALL PRIVILEGES ON respaldo_db_test.* TO 'admin';

/* SUPPORT */
GRANT SELECT, INSERT, UPDATE, DELETE ON db_test.tb_users TO 'support';
GRANT SELECT, INSERT, UPDATE ON db_test.tb_products TO 'support';
GRANT SELECT, INSERT, UPDATE ON db_test.tbc_categories TO 'support';
GRANT SELECT, INSERT, UPDATE ON db_test.tbd_products_categories TO 'support';
-- Otorgarle permiso a tu usuario para ejecutar este procedimiento específico
GRANT EXECUTE ON PROCEDURE db_test.sp_soft_delete_user TO 'jorge.garcia'@'%';

-- Aplicar los cambios de permisos
FLUSH PRIVILEGES;

/* SELLER */
GRANT SELECT, INSERT, UPDATE ON db_test.tb_products TO 'seller';
GRANT SELECT ON db_test.tbc_categories TO 'seller';

/* BUYER*/
GRANT SELECT, INSERT, UPDATE
ON db_test.tbd_carts_items
TO 'buyer';

GRANT SELECT, INSERT, UPDATE
ON db_test.tb_buyer_orders
TO 'buyer';

GRANT SELECT, INSERT
ON db_test.tbd_cart_items
TO 'buyer';

GRANT SELECT, INSERT, UPDATE
ON db_test.tbd_users_wishlist_products
TO 'buyer';

/* USUARIO NO REGISTRADO*/
GRANT INSERT ON db_test.tb_people TO 'user_not_registered';
GRANT INSERT ON db_test.tb_users TO 'user_not_registered';

/* ============================================================
   4. ASIGNACIÓN DE PRIVILEGIOS DIRECTOS Y ROLES A USUARIOS
   ============================================================ */

-- Privilegios directos
GRANT ALL PRIVILEGES ON *.* TO 'jose.amaro'@'%' WITH GRANT OPTION;
GRANT SELECT, INSERT, UPDATE, DELETE ON db_test.* TO 'omar.sampayo'@'%';

-- Asignación de Roles
GRANT 'superadmin' TO 'jose.amaro'@'%';
GRANT 'admin' TO 'marco.ramirez'@'%';
GRANT 'support' TO 'jorge.garcia'@'%';
GRANT 'support' TO 'eduardo.amaro'@'%';
GRANT 'seller' TO 'joseph.escamilla'@'%';
GRANT 'seller' TO 'yhostin.ramirez'@'%';
GRANT 'buyer' TO 'jose.castillo'@'%';
GRANT 'user_not_registered' TO 'app.movil'@'%';
GRANT 'user_not_registered' TO 'app.web'@'%';


/* ============================================================
   5. CONFIGURACIÓN DE ROLES POR DEFECTO
   ============================================================ */
SET DEFAULT ROLE 'superadmin' TO 'jose.amaro'@'%';
SET DEFAULT ROLE 'admin' TO 'marco.ramirez'@'%';
SET DEFAULT ROLE 'support' TO 'jorge.garcia'@'%';
SET DEFAULT ROLE 'seller' TO 'jhosep.escamilla'@'%';
SET DEFAULT ROLE 'seller' TO 'yhostin.ramirez'@'%';
SET DEFAULT ROLE 'buyer' TO 'jose.castillo'@'%';
SET DEFAULT ROLE 'user_not_registered' TO 'app.movil'@'%';
SET DEFAULT ROLE 'user_not_registered' TO 'app.web'@'%';

/* Recargar la tabla de privilegios */
FLUSH PRIVILEGES;

/* Mensaje final de éxito */
SELECT "Los usuarios y privilegios han sido creados correctamente" AS mensaje;