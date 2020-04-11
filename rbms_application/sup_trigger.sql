CREATE OR REPLACE TRIGGER SUP_TRIGGER
  AFTER INSERT ON SUPPLY
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
      'SUPPLY',
      'INSERT',
      :NEW.SUP#
    );
  END PROD_TRIGGER;
  /
  SHOW ERRORS
