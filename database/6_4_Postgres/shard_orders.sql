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
