CREATE OR REPLACE TRIGGER QOH_UPDATE
  AFTER INSERT ON PURCHASES
  FOR EACH ROW

  DECLARE
  SUPPLIER_ID VARCHAR(2);
  ORGINAL_AMT NUMBER;
  THRESHOLD NUMBER;
  ORDERING_AMT NUMBER;
  NEW_AMT NUMBER;

  BEGIN

    SELECT qoh, qoh_threshold INTO ORGINAL_AMT, THRESHOLD
    FROM PRODUCTS
    WHERE PID = :NEW.PID;

    Update PRODUCTS
      SET qoh = qoh - :NEW.QTY
    WHERE PID = :NEW.PID;

    IF (ORGINAL_AMT - :NEW.QTY < THRESHOLD) THEN
       DBMS_OUTPUT.PUT_LINE('PRODUCT ID ' || :NEW.PID || ' IS BELOW QOH THRESHOLD. NEW SUPPLY IS REQUIRED.');
            
            SELECT * INTO SUPPLIER_ID FROM (SELECT S.SID FROM SUPPLY S WHERE PID = :NEW.PID) WHERE ROWNUM = 1;

            ORDERING_AMT := THRESHOLD + 6;

         INSERT INTO SUPPLY 
         (
           SUP#,
           PID,
           SID,
           SDATE,
           QUANTITY
         )
         VALUES
         (
           SUP_NUM.NEXTVAL,
           :NEW.PID,
           SUPPLIER_ID,
           SYSDATE,
           ORDERING_AMT
         );

         DBMS_OUTPUT.PUT_LINE('PRODUCT ID ' || :NEW.PID || ' - SUPPLY ORDERED.');
      

        Update PRODUCTS
        SET QOH = ORDERING_AMT + QOH
        WHERE PID = :NEW.PID;

        SELECT QOH INTO NEW_AMT
        FROM PRODUCTS
        WHERE PID = :NEW.PID;

        -- Insert rows in a Table
        
        INSERT INTO RESUPPLY 
        (
          PID,
          AMT
        )
        VALUES
        (
          :NEW.PID,
          NEW_AMT
        );

        DBMS_OUTPUT.PUT_LINE('PRODUCT ID ' || :NEW.PID || ' NOW HAS ' || NEW_AMT || ' AVALIABLE.');


      END IF;
  END;
  /
  SHOW ERRORS