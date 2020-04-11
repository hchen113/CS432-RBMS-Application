CREATE OR REPLACE TRIGGER PUR_TRIGGER
  AFTER INSERT ON PURCHASES
  FOR EACH ROW

  BEGIN
    INSERT INTO LOGS 
    (
      LOG#,
      WHO,
      OTIME,
      TABLE_NAME,
      OPERATION,
      KEY_VALUE
    )
    VALUES
    (
      LOG_NUM.NEXTVAL,
      USER,
      SYSDATE,
      'PURCHASES',
      'INSERT',
      :NEW.PUR#
    );
  END PUR_TRIGGER;
  /
  SHOW ERRORS