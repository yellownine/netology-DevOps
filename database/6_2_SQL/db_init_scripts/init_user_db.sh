#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 postgres://test_user:test_pwd@0.0.0.0:5432/netology_pg <<-EOSQL
    REVOKE ALL PRIVILEGES ON DATABASE test_db FROM test_admin_user;
    DROP ROLE IF EXISTS test_admin_user;
    CREATE USER test_admin_user;
    DROP DATABASE IF EXISTS test_db;
    CREATE DATABASE test_db;
    GRANT ALL PRIVILEGES ON DATABASE test_db TO test_admin_user;

    \c test_db;

    DROP TABLE IF EXISTS orders CASCADE;
    CREATE TABLE orders (
      id serial,
      наименование varchar(255),
      цена int,
      PRIMARY KEY (id)
    );

    DROP TABLE IF EXISTS clients CASCADE;
    CREATE TABLE clients (
      id serial,
      фамилия varchar(255),
      страна_проживания varchar(255),
      заказ int,
      PRIMARY KEY (id),
      FOREIGN KEY (заказ) REFERENCES orders(id)
    );

    CREATE INDEX cl_order ON clients (заказ);

    CREATE USER test_simple_user;
    GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE orders, clients TO test_simple_user;
EOSQL
