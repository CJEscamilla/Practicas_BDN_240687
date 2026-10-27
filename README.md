name: ${COMPOSE_PROJECT_NAME:?Define COMPOSE_PROJECT_NAME in .env}

services:
  postgres:
    image: postgres:18
    restart: unless-stopped
    environment:
      POSTGRES_DB: db_test
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:?Define POSTGRES_PASSWORD in .env}
      POSTGRES_INITDB_ARGS: --auth-host=scram-sha-256
    ports:
      - "${DB_BIND_ADDRESS:-127.0.0.1}:${PG_HOST_PORT:?Define PG_HOST_PORT in .env}:5432"
    volumes:
      - postgres_data:/var/lib/postgresql

  mysql:
    image: mysql:8.4
    restart: unless-stopped
    environment:
      MYSQL_DATABASE: db_test
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD:?Define MYSQL_ROOT_PASSWORD in .env}
    ports:
      - "${DB_BIND_ADDRESS:-127.0.0.1}:${MYSQL_HOST_PORT:?Define MYSQL_HOST_PORT in .env}:3306"
    volumes:
      - mysql_data:/var/lib/mysql

  pgadmin:
    image: dpage/pgadmin4:9
    restart: unless-stopped
    environment:
      PGADMIN_DEFAULT_EMAIL: ${PGADMIN_EMAIL:?Define PGADMIN_EMAIL in .env}
      PGADMIN_DEFAULT_PASSWORD: ${PGADMIN_PASSWORD:?Define PGADMIN_PASSWORD in .env}
    ports:
      - "${PGADMIN_BIND_ADDRESS:-127.0.0.1}:${PGADMIN_HOST_PORT:?Define PGADMIN_HOST_PORT in .env}:80"
    volumes:
      - pgadmin_data:/var/lib/pgadmin
    depends_on:
      - postgres

volumes:
  postgres_data:
  mysql_data:
  pgadmin_data:
