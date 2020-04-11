CREATE OR REPLACE TRIGGER PROD_TRIGGER
  AFTER UPDATE OF QOH ON PRODUCTS
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
      'PRODUCTS',
      'UPDATE',
      :NEW.PID
    );
  END PROD_TRIGGER;
  /
  SHOW ERRORS