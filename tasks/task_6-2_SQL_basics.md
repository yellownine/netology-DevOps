# Домашнее задание к занятию "6.2. SQL"

Q1: Используя docker поднимите инстанс PostgreSQL (версию 12) c 2 volume, в который будут складываться данные БД и бэкапы.

Приведите получившуюся команду или docker-compose манифест.

A1:
```yml
version: "3.9"
services:
  postgres:
    image: postgres:12
    environment:
      POSTGRES_DB: "netology_pg"
      POSTGRES_USER: "test_user"
      POSTGRES_PASSWORD: "test_pwd"
    ports:
      - "5432:5432"
    volumes:
      - db_data:/var/lib/postgresql/data
      - db_backup
      - ./db_init_scripts:/docker-entrypoint-initdb.d
volumes:
  db_data:
  db_backup:
```
---
Q2: В БД из задачи 1:

- создайте пользователя test-admin-user и БД test_db
- в БД test_db создайте таблицу orders и clients (спeцификация таблиц ниже)
- предоставьте привилегии на все операции пользователю test-admin-user на таблицы БД test_db
- создайте пользователя test-simple-user
- предоставьте пользователю test-simple-user права на SELECT/INSERT/UPDATE/DELETE данных таблиц БД test_db


Таблица orders:

- id (serial primary key)
- наименование (string)
- цена (integer)


Таблица clients:

- id (serial primary key)
- фамилия (string)
- страна проживания (string, index)
- заказ (foreign key orders)

A2.0:
- сделал скрипт для инициализации БД  
```bash
#!/bin/bash
set -e
psql -v ON_ERROR_STOP=1 postgres://test_user:test_pwd@0.0.0.0:5432/netology_pg <<-EOSQL
    REVOKE ALL PRIVILEGES ON DATABASE test_db FROM test_admin_user;
    DROP ROLE IF EXISTS test_admin_user;
    CREATE USER test_admin_user;
    DROP DATABASE IF EXISTS test_db;
    CREATE DATABASE test_db;
    GRANT ALL PRIVILEGES ON DATABASE test_db TO test_admin_user;

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
```

Приведите:

- итоговый список БД после выполнения пунктов выше,  
![db_list](../screenshots/6-2_db_list.png)

- описание таблиц (describe)
![table_descr](../screenshots/6-2_table_descr.png)

- SQL-запрос для выдачи списка пользователей с правами над таблицами test_db
```SQL
SELECT * FROM pg_catalog.pg_database;
```
это единственное, что пока в силах сгенерировать по этому вопросу  
- список пользователей с правами над таблицами test_db
![db_users](../screenshots/6-2_users.png)

---
Q3: Используя SQL синтаксис - наполните таблицы следующими тестовыми данными:

- Таблица orders

Наименование	цена  
Шоколад	10  
Принтер	3000  
Книга	500  
Монитор	7000  
Гитара	4000  

- Таблица clients

ФИО	Страна проживания  
Иванов Иван Иванович	USA  
Петров Петр Петрович	Canada  
Иоганн Себастьян Бах	Japan  
Ронни Джеймс Дио	Russia  
Ritchie Blackmore	Russia  

Используя SQL синтаксис:

вычислите количество записей для каждой таблицы
приведите в ответе:
запросы
результаты их выполнения.

A3:
![tables_count](../screenshots/6-2_tables_count.png)

---
Q4: Часть пользователей из таблицы clients решили оформить заказы из таблицы orders.

Используя foreign keys свяжите записи из таблиц, согласно таблице:

ФИО	Заказ  
Иванов Иван Иванович	Книга  
Петров Петр Петрович	Монитор  
Иоганн Себастьян Бах	Гитара  

Q4.1: Приведите SQL-запросы для выполнения данных операций.  
A4.1:
```SQL
UPDATE
  clients
SET
  заказ=order_tab.id
FROM (
  SELECT id FROM orders WHERE наименование='Книга') AS order_tab
WHERE фамилия='Иванов Иван Иванович';

UPDATE
  clients
SET
  заказ=order_tab.id
FROM (
  SELECT id FROM orders WHERE наименование='Монитор') AS order_tab
WHERE фамилия='Петров Петр Петрович';

UPDATE
  clients
SET
  заказ=order_tab.id
FROM (
  SELECT id FROM orders WHERE наименование='Гитара') AS order_tab
WHERE фамилия='Иоганн Себастьян Бах';
```  

Q4.2: Приведите SQL-запрос для выдачи всех пользователей, которые совершили заказ, а также вывод данного запроса.  
A4.2:
```SQL
SELECT * FROM clients WHERE заказ IS NOT NULL;
```
![clients and orders](../screenshots/6-2_clients_orders.png)

Подсказк - используйте директиву UPDATE.

---
Q5: Получите полную информацию по выполнению запроса выдачи всех пользователей из задачи 4 (используя директиву EXPLAIN).

Приведите получившийся результат и объясните что значат полученные значения.

A5:
Попробовал EXPLAIN и EXPLAIN ANALYZE. А также вывел в формате JSON.
![explain](../screenshots/6-2_explain.png)
```json
[                                        +
   {                                      +
     "Plan": {                            +
       "Node Type": "Seq Scan",           +
       "Parallel Aware": false,           +
       "Relation Name": "clients",        +
       "Alias": "clients",                +
       "Startup Cost": 0.00,              +
       "Total Cost": 10.70,               +
       "Plan Rows": 70,                   +
       "Plan Width": 1040,                +
       "Filter": "(\"заказ\" IS NOT NULL)"+
     }                                    +
   }                                      +
 ]
```
и
```json
[                                         +
  {                                       +
    "Plan": {                             +
      "Node Type": "Seq Scan",            +
      "Parallel Aware": false,            +
      "Relation Name": "clients",         +
      "Alias": "clients",                 +
      "Startup Cost": 0.00,               +
      "Total Cost": 10.70,                +
      "Plan Rows": 70,                    +
      "Plan Width": 1040,                 +
      "Actual Startup Time": 0.075,       +
      "Actual Total Time": 0.134,         +
      "Actual Rows": 3,                   +
      "Actual Loops": 1,                  +
      "Filter": "(\"заказ\" IS NOT NULL)",+
      "Rows Removed by Filter": 2         +
    },                                    +
    "Planning Time": 0.269,               +
    "Triggers": [                         +
    ],                                    +
    "Execution Time": 0.288               +
  }                                       +
]
```
Запрос на поиск пользователей выполняется
- последовательным сканированием
- по таблице clients
- приблизительная стоимость запуска запроса - 0
- приблизительная общая стоимость запроса 10.7
- ожидаемое число строк, которое выведет поиск - 70
- ожидаемый средний размер строк - 1040  
С ключем ANALYZE видим фактические значения для запроса поиска

---
Q6: Создайте бэкап БД test_db и поместите его в volume, предназначенный для бэкапов (см. Задачу 1).

Остановите контейнер с PostgreSQL (но не удаляйте volumes).

Поднимите новый пустой контейнер с PostgreSQL.

Восстановите БД test_db в новом контейнере.

Приведите список операций, который вы применяли для бэкапа данных и восстановления.

A6:
- нагуглил вопрос дампа БД, лежащей в docker-контейнере
- определил id контейнера через docker ps
- собрал команду
```bash
docker exec -t 7a7edbd6124e pg_dumpall -c -U postgres > dump.sql
```
Но эта команда создает дамп на хосте, а не в volume контейнера. В volume контейнера мне пока не по силам сделать. А долг по домашкам растет.
---
A6.1: После комментариев преподавателя сделал следующее:
- новый docker-compose с одним внешним volume для бэкапа
```yml
version: "3.9"
services:
  postgres:
    image: postgres:12
    environment:
      POSTGRES_DB: "netology_pg"
      POSTGRES_USER: "test_user"
      POSTGRES_PASSWORD: "test_pwd"
    ports:
      - "5432:5432"
    volumes:
      - db_data:/var/lib/postgresql/data
      - db_backup:/var/lib/postgresql/data/backup
      - ./db_init_scripts:/docker-entrypoint-initdb.d
volumes:
  db_data:
  db_backup:
    external: true
    name: db_backup
```
- создал внешний volume
```bash
leonid@mac 6_2_SQL % docker volume create db_backup
```
- зашел в контейнер по его хэшу
```bash
leonid@mac db_backup % docker exec -it 0a237fd59660 bash
```
- сделал дамп, находясь внутри контейнера
```bash
root@0a237fd59660:/# pg_dump -U test_user test_db > /var/lib/postgresql/data/backup/test_db.dump.sql
```
- запустил еще один чистый контейнер с postgres
```bash
leonid@mac db_backup % docker run -it --name other_postgres -v db_backup:/var/lib/postgresql/backup/ -e POSTGRES_PASSWORD=password -d postgres
```
- зашел в контейнер и загрузил дамп в psql
```bash
leonid@mac db_backup % docker exec -it 2ea65fc7977dbd3d61ee8970997f1cfc3b3872b6eb9567fb252bbcf56dfc06c9
root@2ea65fc7977d:/# psql -U postgres < /var/lib/postgresql/backup/test_db.dump.sql
```
