# Домашнее задание к занятию "6.4. PostgreSQL"

Q1:
Используя docker поднимите инстанс PostgreSQL (версию 13). Данные БД сохраните в volume.

Подключитесь к БД PostgreSQL используя psql.

Воспользуйтесь командой \? для вывода подсказки по имеющимся в psql управляющим командам.

Найдите и приведите управляющие команды для:

- вывода списка БД  
A1.1:  
```bash
\d
\d+
\dS
\dS+ #вообще все, что есть в БД
```
- подключения к БД  
A1.2:  
```bash
\c
```
- вывода списка таблиц  
A1.3:  
```bash
\dt
\dt+
\dtS
\dtS+ #все таблицы
```
- вывода описания содержимого таблиц  
A1.3:  
```bash
\d+ <table name>; # указывается имя таблицы, для которой надо получить описание
```
- выхода из psql  
A1.4:  
```bash
\q
```

---
Q2:
Используя psql создайте БД test_database.

Изучите бэкап БД.

Восстановите бэкап БД в test_database.

Перейдите в управляющую консоль psql внутри контейнера.

Подключитесь к восстановленной БД и проведите операцию ANALYZE для сбора статистики по таблице.

Используя таблицу pg_stats, найдите столбец таблицы orders с наибольшим средним значением размера элементов в байтах.

Приведите в ответе команду, которую вы использовали для вычисления и полученный результат.

A2:
```bash
test_database=# select attname,avg_width from pg_stats where tablename = 'orders';
 attname | avg_width
---------+-----------
 id      |         4
 title   |        16
 price   |         4
(3 rows)
```

---
Q3: Архитектор и администратор БД выяснили, что ваша таблица orders разрослась до невиданных размеров и поиск по ней занимает долгое время. Вам, как успешному выпускнику курсов DevOps в нетологии предложили провести разбиение таблицы на 2 (шардировать на orders_1 - price>499 и orders_2 - price<=499).

Предложите SQL-транзакцию для проведения данной операции.

Можно ли было изначально исключить "ручное" разбиение при проектировании таблицы orders?

A3:
```SQL
BEGIN;

ALTER TABLE orders RENAME TO orders_single;

CREATE TABLE orders (like orders_single)
  PARTITION BY RANGE (price);

CREATE TABLE orders_1 PARTITION OF orders
  FOR VALUES FROM (500) TO (MAXVALUE);

CREATE TABLE orders_2 PARTITION OF orders
  FOR VALUES FROM (MINVALUE) TO (500);

INSERT INTO orders_1 SELECT * FROM orders_single
  WHERE price>499;

INSERT INTO orders_2 SELECT * FROM orders_single
  WHERE price<=499;

DROP TABLE orders_single;

COMMIT;
```
Примечание: это сработает только за счет того, что аттрибут price в таблице имеет тип integer. Необходимость использовать 500 вместо 499 связана с тем, что диапазон FROM () TO () включает нижнюю границу и не включает верхнюю. Наверно, есть еще решения с какой-нибудь инверсной логикой, но важно ведь решение:)

Исключить ручное разбиение можно (как нам рассказали на вебинаре), но не сказали как. Могу предположить, что для таких задач можно написать свои SQL-функции или изначально спроектировать все с разбиением да еще и на стороне приложения.

---
Q4: Используя утилиту pg_dump создайте бекап БД test_database.

Как бы вы доработали бэкап-файл, чтобы добавить уникальность значения столбца title для таблиц test_database?

A4: Я бы в исходной секционированной таблице добавил этому атрибуту ограничение UNIQE, которое наследовалось бы секциями при шардировании. Хотя по смыслу содержания таблицы... ведь бывают разные издания одной книги по разной цене - "цифровая версия", "твердая обложка", "покетбук". В общем, я бы аккуратно предложил не делать уникальным title.

SQL-транзакция шардирования, в которой добавлен признак уникальности title:
```SQL
BEGIN;

ALTER TABLE orders RENAME TO orders_single;

CREATE TABLE orders (like orders_single)
  PARTITION BY RANGE (price);

ALTER TABLE orders ALTER COLUMN tittle SET UNIQE;

CREATE TABLE orders_1 PARTITION OF orders
  FOR VALUES FROM (500) TO (MAXVALUE);

CREATE TABLE orders_2 PARTITION OF orders
  FOR VALUES FROM (MINVALUE) TO (500);

INSERT INTO orders_1 SELECT * FROM orders_single
  WHERE price>499;

INSERT INTO orders_2 SELECT * FROM orders_single
  WHERE price<=499;

DROP TABLE orders_single;

COMMIT;
```
