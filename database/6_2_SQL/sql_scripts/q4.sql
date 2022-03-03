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

SELECT * FROM clients WHERE заказ IS NOT NULL;
