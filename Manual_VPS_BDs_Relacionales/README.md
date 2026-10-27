# Unidad 1 · Bases de Datos en la Nube

Despliegue individual de una base de datos de comercio electrónico en un VPS
compartido con Ubuntu 24.04. Docker Compose inicia MySQL 8.4, PostgreSQL 18
y pgAdmin 4 en contenedores y volúmenes propios.

## Contenido

| Archivo | Función |
| --- | --- |
| `docker-compose.yml` | Define los tres servicios, puertos y volúmenes persistentes. |
| `.env.example` | Plantilla de configuración; se copia a `.env` en el VPS y se completan allí las claves. |
| `sql/mysql.sql` | Crea las tablas y objetos de MySQL e importa los datos. |
| `sql/postgresql.sql` | Crea las tablas y objetos equivalentes de PostgreSQL e importa los datos. |
| `sql/mysql_roles.sql` | Crea las cuentas, los siete roles y sus permisos en MySQL. |
| `sql/postgresql_roles.sql` | Crea las cuentas, los siete roles y sus permisos en PostgreSQL. |

Los roles se llaman `superadmin`, `admin`, `seller`, `buyer`, `support`,
`common` y `not_registered`, como indica la lista de verificación. Los
permisos explícitos de la práctica de clase se conservan: `seller` tiene
`SELECT`, `INSERT` y `UPDATE` sobre `tb_products`; `support` tiene los mismos
permisos sobre `tb_users`; `admin` administra `db_test`; y `superadmin` tiene
privilegios amplios. El guion de clase no definía permisos de tabla para
`buyer`, `common` ni `not_registered`.

## Configuración y despliegue

En el VPS, copiar esta carpeta a un directorio propio del estudiante y entrar
en ella. Crear el archivo privado de configuración:

```sh
cp .env.example .env
nano .env
```

La plantilla propone el proyecto `dbnube-240687` y los puertos de host 40687
para PostgreSQL, 40688 para MySQL y 54687 para pgAdmin. Definir en `.env` las
contraseñas iniciales y el correo de pgAdmin. El archivo `.env` nunca debe
subirse al repositorio.

```sh
docker compose config --quiet
docker compose up -d
docker compose ps
docker volume ls --filter name=dbnube-240687
```

Los volúmenes `postgres_data`, `mysql_data` y `pgadmin_data` conservan los
datos al recrear contenedores. Para revisar incidencias:

```sh
docker compose logs --tail=50 mysql postgres pgadmin
```

## Importación inicial

El contenedor crea una base `db_test` en cada motor. Ejecutar los archivos de
datos **una sola vez en una instancia nueva**, antes de crear los roles:

```sh
docker compose exec -T mysql sh -c 'exec mysql -uroot -p"$MYSQL_ROOT_PASSWORD"' < sql/mysql.sql
docker compose exec -T postgres psql -U postgres -d db_test -v ON_ERROR_STOP=1 < sql/postgresql.sql
```

`sql/mysql.sql` contiene instrucciones `DROP TABLE`; volver a importarlo sobre
una base con cambios posteriores puede borrar esos cambios. El archivo de
PostgreSQL utiliza una transacción y termina en `COMMIT` si no hay errores.

La copia inicial verificada tenía 7 filas en `tb_users`, 5008 en
`tb_products` y 5015 en `tb_logs` en cada motor. Las siete contraseñas de
`tb_users` se sustituyeron por hashes bcrypt de coste 12. Una aplicación que
autentique a esos usuarios debe verificar el hash mediante bcrypt.

## Cuentas y roles

En una instalación nueva, ejecutar `sql/mysql_roles.sql` y
`sql/postgresql_roles.sql` después de la importación. MySQL genera contraseñas
aleatorias para las cuentas y las devuelve una vez como resultado de
`CREATE USER`; guardar ese resultado fuera del repositorio. PostgreSQL crea
las cuentas sin contraseña inicial; asignarla de forma interactiva con
`psql` y `\password`. Nunca poner contraseñas literales en los scripts.

En el VPS de la práctica se corrigieron dos nombres de roles después de la
importación original. Los scripts incluidos aquí ya contienen los nombres
exigidos para una instalación nueva. No volver a ejecutar el archivo de
datos para aplicar esa corrección.

## Acceso desde un cliente externo

Los puertos están vinculados a `127.0.0.1` en el VPS. Durante la práctica se
conectaron pgAdmin Web y MySQL Workbench desde Windows mediante un túnel SSH:

```sh
ssh -N -L 40687:127.0.0.1:40687 -L 40688:127.0.0.1:40688 -L 54687:127.0.0.1:54687 ubuntu@IP_DEL_VPS
```

Con el túnel abierto, Workbench usa `127.0.0.1:40688`. El navegador abre
pgAdmin en `http://127.0.0.1:54687`; dentro de pgAdmin, el servidor de base
de datos tiene host `postgres`, puerto `5432` y base `db_test`.

Para permitir acceso directo desde Internet se necesitaría una lista de IP
autorizadas en el firewall del proveedor o en reglas compatibles con Docker,
antes de cambiar `DB_BIND_ADDRESS` por la IP pública del VPS. Ese cambio no
forma parte de la configuración documentada aquí.

## Verificación y alcance

Se comprobó la ejecución de los tres contenedores, la persistencia de los
volúmenes, la conexión desde clientes gráficos, los conteos de filas, los siete
roles y las asignaciones y permisos principales. Los scripts contienen siete
hashes bcrypt de coste 12 con prefijo `$2a$12$`; la captura de verificación en
el VPS está pendiente de repetirse porque la consulta original buscó `$2b$12$`.
Los diez casos colaborativos de inserción, modificación, eliminación e
importación masiva no se volvieron a ejecutar en este VPS. Los registros
históricos del volcado no se presentan como evidencia de una ejecución nueva.

El reporte PDF adjunto documenta las evidencias disponibles y las
limitaciones. No incluir `.env`, contraseñas generadas, claves SSH ni capturas
que revelen credenciales en GitHub.
