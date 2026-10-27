-- PostgreSQL 18 - roles y cuentas de la practica.
-- Ejecutar como postgres despues de sql/postgresql.sql.
-- No establece contrasenas: asignarlas de forma interactiva con psql \password.
-- El servicio PostgreSQL de este proyecto debe ser un contenedor propio.

DO $$
DECLARE
    role_name TEXT;
    login_name TEXT;
BEGIN
    FOREACH role_name IN ARRAY ARRAY[
        'superadmin', 'admin', 'seller', 'buyer', 'support',
        'common', 'not_registered'
    ] LOOP
        IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = role_name) THEN
            EXECUTE format('CREATE ROLE %I NOLOGIN', role_name);
        END IF;
    END LOOP;

    FOREACH login_name IN ARRAY ARRAY[
        'cristopher.escamilla', 'marco.ramirez', 'yhostin.ramirez',
        'olaf.garcia', 'eduardo.amaro', 'uriel.gonzalez', 'yazmin.esquivel'
    ] LOOP
        IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = login_name) THEN
            EXECUTE format('CREATE ROLE %I LOGIN', login_name);
        END IF;
    END LOOP;
END;
$$;

-- El superadmin recibe atributos de servidor directamente. Los atributos
-- SUPERUSER/CREATEROLE no se heredan al pertenecer a otro rol PostgreSQL.
ALTER ROLE "cristopher.escamilla" SUPERUSER CREATEROLE CREATEDB;

GRANT ALL PRIVILEGES ON DATABASE db_test TO superadmin, admin;
GRANT USAGE, CREATE ON SCHEMA public TO superadmin, admin;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO superadmin, admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO superadmin, admin;

GRANT USAGE ON SCHEMA public TO seller, support;
GRANT SELECT, INSERT, UPDATE ON TABLE public.tb_products TO seller;
GRANT USAGE, SELECT ON SEQUENCE public.tb_products_id_seq TO seller;
GRANT SELECT, INSERT, UPDATE ON TABLE public.tb_users TO support;
GRANT USAGE, SELECT ON SEQUENCE public.tb_users_id_seq TO support;

-- El permiso directo sobre db_test.* del script MySQL se conserva para
-- esta cuenta en las tablas y secuencias que existen al ejecutar el archivo.
GRANT USAGE ON SCHEMA public TO "uriel.gonzalez";
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO "uriel.gonzalez";
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO "uriel.gonzalez";

-- El script MySQL compartido no definia permisos para buyer, common ni
-- not_registered. Se conservan sin permisos adicionales.

GRANT superadmin TO "cristopher.escamilla";
GRANT admin TO "marco.ramirez";
GRANT support TO "yhostin.ramirez";
GRANT seller TO "olaf.garcia", "eduardo.amaro";
GRANT buyer TO "yazmin.esquivel";
GRANT common TO "uriel.gonzalez";

-- Una cuenta nueva en PostgreSQL hereda privilegios de sus roles de grupo.
-- Verificacion: SELECT rolname, rolcanlogin FROM pg_roles WHERE rolname IN (...);
