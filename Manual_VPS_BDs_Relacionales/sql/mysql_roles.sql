-- MySQL 8.4 - cuentas y roles de la practica compartida por el estudiante.
-- Ejecutar despues de sql/mysql.sql en un contenedor MySQL nuevo.
-- Las contrasenas se generan al crear las cuentas y deben guardarse en privado.
-- Ejecutar cada CREATE USER por separado para conservar su resultado.
-- IF NOT EXISTS no cambia la contrasena de una cuenta que ya exista.

CREATE USER IF NOT EXISTS 'cristopher.escamilla'@'%' IDENTIFIED BY RANDOM PASSWORD;
CREATE USER IF NOT EXISTS 'marco.ramirez'@'%' IDENTIFIED BY RANDOM PASSWORD;
CREATE USER IF NOT EXISTS 'yhostin.ramirez'@'%' IDENTIFIED BY RANDOM PASSWORD;
CREATE USER IF NOT EXISTS 'olaf.garcia'@'%' IDENTIFIED BY RANDOM PASSWORD;
CREATE USER IF NOT EXISTS 'eduardo.amaro'@'%' IDENTIFIED BY RANDOM PASSWORD;
CREATE USER IF NOT EXISTS 'uriel.gonzalez'@'%' IDENTIFIED BY RANDOM PASSWORD;
CREATE USER IF NOT EXISTS 'yazmin.esquivel'@'%' IDENTIFIED BY RANDOM PASSWORD;

CREATE ROLE IF NOT EXISTS 'superadmin';
CREATE ROLE IF NOT EXISTS 'admin';
CREATE ROLE IF NOT EXISTS 'seller';
CREATE ROLE IF NOT EXISTS 'buyer';
CREATE ROLE IF NOT EXISTS 'support';
CREATE ROLE IF NOT EXISTS 'common';
CREATE ROLE IF NOT EXISTS 'not_registered';

-- Permisos del script original, con las repeticiones retiradas.
GRANT ALL PRIVILEGES ON *.* TO 'cristopher.escamilla'@'%' WITH GRANT OPTION;
GRANT SELECT, INSERT, UPDATE, DELETE ON db_test.* TO 'uriel.gonzalez'@'%';
GRANT ALL PRIVILEGES ON *.* TO 'superadmin';
GRANT ALL PRIVILEGES ON db_test.* TO 'admin';
GRANT SELECT, INSERT, UPDATE ON db_test.tb_users TO 'support';
GRANT SELECT, INSERT, UPDATE ON db_test.tb_products TO 'seller';
GRANT SELECT, INSERT, UPDATE, DELETE ON db_test.tb_logs TO 'cristopher.escamilla'@'%';

GRANT 'superadmin' TO 'cristopher.escamilla'@'%';
GRANT 'admin' TO 'marco.ramirez'@'%';
GRANT 'support' TO 'yhostin.ramirez'@'%';
GRANT 'seller' TO 'olaf.garcia'@'%';
GRANT 'seller' TO 'eduardo.amaro'@'%';
GRANT 'buyer' TO 'yazmin.esquivel'@'%';
GRANT 'common' TO 'uriel.gonzalez'@'%';

SET DEFAULT ROLE 'superadmin' TO 'cristopher.escamilla'@'%';
SET DEFAULT ROLE 'admin' TO 'marco.ramirez'@'%';
SET DEFAULT ROLE 'support' TO 'yhostin.ramirez'@'%';
SET DEFAULT ROLE 'seller' TO 'olaf.garcia'@'%';
SET DEFAULT ROLE 'seller' TO 'eduardo.amaro'@'%';
SET DEFAULT ROLE 'buyer' TO 'yazmin.esquivel'@'%';
SET DEFAULT ROLE 'common' TO 'uriel.gonzalez'@'%';

-- Verificaciones de ejemplo.
SHOW GRANTS FOR 'marco.ramirez'@'%' USING 'admin';
SHOW GRANTS FOR 'olaf.garcia'@'%' USING 'seller';
SHOW GRANTS FOR 'yhostin.ramirez'@'%' USING 'support';
