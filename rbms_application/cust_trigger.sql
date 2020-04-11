CREATE OR REPLACE TRIGGER CUST_TRIGGER
  AFTER UPDATE OF VISITS_MADE ON CUSTOMERS
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
      'CUSTOMERS',
      'UPDATE',
      :NEW.CID
    );
  END CUST_TRIGGER;
  /
  SHOW ERRORS