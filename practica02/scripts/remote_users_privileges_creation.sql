/* 1. CREACIÓN DE USUARIOS REMOTOS */
CREATE USER IF NOT EXISTS 'cristopher.escamilla'@'%' IDENTIFIED BY '240687';
CREATE USER IF NOT EXISTS 'marco.ramirez'@'%' IDENTIFIED BY 'qwerty123';
CREATE USER IF NOT EXISTS 'yhostin.ramirez'@'%' IDENTIFIED BY '240071';
CREATE USER IF NOT EXISTS 'olaf.garcia'@'%' IDENTIFIED BY '240508';
CREATE USER IF NOT EXISTS 'eduardo.amaro'@'%' IDENTIFIED BY '240726';
CREATE USER IF NOT EXISTS 'uriel.gonzalez'@'%' IDENTIFIED BY '240463';
CREATE USER IF NOT EXISTS 'yazmin.esquivel'@'%' IDENTIFIED BY '240235';
-- Cuentas de aplicaciones.
CREATE USER IF NOT EXISTS 'app.movil'@'%' IDENTIFIED BY 'Moblile890';
CREATE USER IF NOT EXISTS 'app.web'@'%' IDENTIFIED BY 'Web123';

/* 2. ASIGNACIÓN DE PRIVILEGIOS AL SUPER USUARIO */
GRANT ALL PRIVILEGES ON *.* TO 'cristopher.escamilla'@'%' WITH GRANT OPTION;

GRANT SELECT, INSERT, UPDATE, DELETE
ON db_test.*
TO 'uriel.gonzalez'@'%';

/* 3. CREACIÓN DE ROLES */
CREATE ROLE IF NOT EXISTS 'superadmin';
CREATE ROLE IF NOT EXISTS 'admin';
CREATE ROLE IF NOT EXISTS 'seller';
CREATE ROLE IF NOT EXISTS 'buyer';
CREATE ROLE IF NOT EXISTS 'support';
CREATE ROLE IF NOT EXISTS 'common_user';
CREATE ROLE IF NOT EXISTS 'user_not_registered';

/* 4. ASIGNACIÓN DE PRIVILEGIOS A ROLES */
GRANT ALL PRIVILEGES ON *.* TO 'superadmin' WITH GRANT OPTION;

GRANT ALL PRIVILEGES
ON db_test.*
TO 'admin';

GRANT SELECT, INSERT, UPDATE, DELETE ON db_test.tb_users TO 'support';
GRANT SELECT, INSERT, UPDATE ON db_test.tb_products TO 'support';
GRANT SELECT, INSERT, UPDATE ON db_test.tbc_categories TO 'support';
GRANT SELECT, INSERT, UPDATE ON db_test.tbd_products_categories TO 'support';
-- El procedimiento debe existir antes de ejecutar este GRANT.
GRANT EXECUTE ON PROCEDURE db_test.sp_soft_delete_product TO 'yhostin.ramirez'@'%';

GRANT SELECT, INSERT, UPDATE ON db_test.tb_products TO 'seller';
GRANT SELECT ON db_test.tbc_categories TO 'seller';

GRANT SELECT, INSERT, UPDATE ON db_test.tbd_carts_items TO 'buyer';
GRANT SELECT, INSERT, UPDATE ON db_test.tb_buyer_orders TO 'buyer';
GRANT SELECT, INSERT, UPDATE ON db_test.tbd_users_wishilst_products TO 'buyer';

GRANT INSERT ON db_test.tb_people TO 'user_not_registered';
GRANT INSERT ON db_test.tb_users TO 'user_not_registered';

/* 5. ASIGNACIÓN DE ROLES A USUARIOS */
GRANT 'admin' TO 'marco.ramirez'@'%';
GRANT 'support' TO 'yhostin.ramirez'@'%';

/* 6. ACTIVACIÓN DE ROLES (CRÍTICO PARA MYSQL 8+) */
SET DEFAULT ROLE 'admin' TO 'marco.ramirez'@'%';
SET DEFAULT ROLE 'support' TO 'yhostin.ramirez'@'%';

/* 7. APLICAR CAMBIOS */
FLUSH PRIVILEGES;

/*========================
ASIGNACIÓN Y ACTIVACIÓN DE ROLES A USUARIOS 
==================*/

-- Este deben ser ustedes
GRANT 'superadmin' TO 'cristopher.escamilla'@'%';

-- Este deben ser el Ingeniero
GRANT 'admin' TO 'marco.ramirez'@'%';

-- Izquierda
GRANT 'support' TO 'yhostin.ramirez'@'%';

-- Derecha
GRANT 'seller' TO 'olaf.garcia'@'%';
GRANT 'seller' TO 'eduardo.amaro'@'%';

-- Comprador
GRANT 'buyer' TO 'yazmin.esquivel'@'%';

-- Usuario común
GRANT 'common_user' TO 'uriel.gonzalez'@'%';
GRANT 'user_not_registered' TO 'app.movil'@'%';
GRANT 'user_not_registered' TO 'app.web'@'%';

SET DEFAULT ROLE 'superadmin' TO 'cristopher.escamilla'@'%';
SET DEFAULT ROLE 'admin' TO 'marco.ramirez'@'%';  
SET DEFAULT ROLE 'support' TO 'yhostin.ramirez'@'%';
SET DEFAULT ROLE 'seller' TO 'olaf.garcia'@'%';
SET DEFAULT ROLE 'seller' TO 'eduardo.amaro'@'%';
SET DEFAULT ROLE 'buyer' TO 'yazmin.esquivel'@'%';
SET DEFAULT ROLE 'common_user' TO 'uriel.gonzalez'@'%';
SET DEFAULT ROLE 'user_not_registered' TO 'app.movil'@'%';
SET DEFAULT ROLE 'user_not_registered' TO 'app.web'@'%';

/*==================================================*/
/* Asignación de privilegios directos adicionales*/
/*==================================================*/

GRANT SELECT, INSERT, UPDATE, DELETE ON db_test.tb_logs TO 'cristopher.escamilla'@'%';

flush privileges;

/*mensaje de confirmación
*/
SELECT 'Usuarios remotos y roles creados y asignados correctamente' AS mensaje;

