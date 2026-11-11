-- Usuarios y roles remotos para db_test (MySQL 8).
-- Basado en el respaldo practica03/backups/respaldo10_28.1.sql.
-- Ejecutar con una cuenta autorizada para crear usuarios y conceder privilegios.
-- CREATE USER IF NOT EXISTS no cambia las contrasenas de cuentas existentes.
-- El procedimiento db_test.sp_soft_delete_product debe existir antes del GRANT.
-- Este archivo concede privilegios globales al rol superadmin y a Cristopher.

/* 1. USUARIOS REMOTOS Y CUENTAS DE APLICACIONES */
CREATE USER IF NOT EXISTS 'cristopher.escamilla'@'%' IDENTIFIED BY '240687';
CREATE USER IF NOT EXISTS 'marco.ramirez'@'%' IDENTIFIED BY 'qwerty123';
CREATE USER IF NOT EXISTS 'yhostin.ramirez'@'%' IDENTIFIED BY '240071';
CREATE USER IF NOT EXISTS 'olaf.garcia'@'%' IDENTIFIED BY '240508';
CREATE USER IF NOT EXISTS 'eduardo.amaro'@'%' IDENTIFIED BY '240726';
CREATE USER IF NOT EXISTS 'uriel.gonzalez'@'%' IDENTIFIED BY '240463';
CREATE USER IF NOT EXISTS 'yazmin.esquivel'@'%' IDENTIFIED BY '240235';
CREATE USER IF NOT EXISTS 'app.movil'@'%' IDENTIFIED BY 'Moblile890';
CREATE USER IF NOT EXISTS 'app.web'@'%' IDENTIFIED BY 'Web123';

/* 2. ROLES */
CREATE ROLE IF NOT EXISTS 'superadmin', 'admin', 'support', 'seller',
    'buyer', 'common_user', 'user_not_registered';

/* 3. PRIVILEGIOS DE CADA ROL */
GRANT ALL PRIVILEGES ON *.* TO 'superadmin' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON db_test.* TO 'admin';

GRANT SELECT, INSERT, UPDATE, DELETE ON db_test.tb_users TO 'support';
GRANT SELECT, INSERT, UPDATE ON db_test.tb_products TO 'support';
GRANT SELECT, INSERT, UPDATE ON db_test.tbc_categories TO 'support';
GRANT SELECT, INSERT, UPDATE ON db_test.tbd_products_categories TO 'support';

GRANT SELECT, INSERT, UPDATE ON db_test.tb_products TO 'seller';
GRANT SELECT ON db_test.tbc_categories TO 'seller';

GRANT SELECT, INSERT, UPDATE ON db_test.tbd_carts_items TO 'buyer';
GRANT SELECT, INSERT, UPDATE ON db_test.tb_buyer_orders TO 'buyer';
GRANT SELECT, INSERT, UPDATE ON db_test.tbd_users_wishilst_products TO 'buyer';

GRANT INSERT ON db_test.tb_users TO 'user_not_registered';
GRANT INSERT ON db_test.tb_people TO 'user_not_registered';
-- common_user no tiene privilegios propios definidos en el archivo original.

/* 4. PRIVILEGIOS DIRECTOS */
GRANT ALL PRIVILEGES ON *.* TO 'cristopher.escamilla'@'%' WITH GRANT OPTION;
GRANT SELECT, INSERT, UPDATE, DELETE ON db_test.* TO 'uriel.gonzalez'@'%';
GRANT EXECUTE ON PROCEDURE db_test.sp_soft_delete_product TO 'yhostin.ramirez'@'%';

/* 5. ASIGNACION DE ROLES */
GRANT 'superadmin' TO 'cristopher.escamilla'@'%';
GRANT 'admin' TO 'marco.ramirez'@'%';
GRANT 'support' TO 'yhostin.ramirez'@'%';
GRANT 'seller' TO 'olaf.garcia'@'%', 'eduardo.amaro'@'%';
GRANT 'buyer' TO 'yazmin.esquivel'@'%';
GRANT 'common_user' TO 'uriel.gonzalez'@'%';
GRANT 'user_not_registered' TO 'app.movil'@'%', 'app.web'@'%';

/* 6. ACTIVACION DE ROLES POR DEFECTO */
SET DEFAULT ROLE 'superadmin' TO 'cristopher.escamilla'@'%';
SET DEFAULT ROLE 'admin' TO 'marco.ramirez'@'%';
SET DEFAULT ROLE 'support' TO 'yhostin.ramirez'@'%';
SET DEFAULT ROLE 'seller' TO 'olaf.garcia'@'%', 'eduardo.amaro'@'%';
SET DEFAULT ROLE 'buyer' TO 'yazmin.esquivel'@'%';
SET DEFAULT ROLE 'common_user' TO 'uriel.gonzalez'@'%';
SET DEFAULT ROLE 'user_not_registered' TO 'app.movil'@'%', 'app.web'@'%';

SELECT 'Usuarios y roles configurados correctamente' AS mensaje;
