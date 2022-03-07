CREATE USER IF NOT EXISTS
  test
  IDENTIFIED WITH mysql_native_password BY "test-pass"
  WITH MAX_QUERIES_PER_HOUR 100
  PASSWORD EXPIRE INTERVAL 180 DAY
  FAILED_LOGIN_ATTEMPTS 3
  ATTRIBUTE '{"firstname": "James", "lastname": "Pretty"}';

GRANT SELECT ON test_db.* TO test;
