SET SERVEROUTPUT ON;

start cust_trigger;
start cust_update_trigger;
start prod_trigger;
start pur_trigger;
start qoh_neg_trigger;
start qoh_update_trigger;
start sup_trigger;


CREATE OR REPLACE PACKAGE RBMS AS

 -- PROCEDURES: 'SHOW_X'----------------------------------------------------------------------------------------------
    PROCEDURE SHOW_CUSTOMERS(RET_VAL OUT VARCHAR) ;
    PROCEDURE SHOW_EMPLOYEES(RET_VAL OUT VARCHAR) ;
    PROCEDURE SHOW_PRODUCTS(RET_VAL OUT VARCHAR) ;
    PROCEDURE SHOW_PURCHASES(RET_VAL OUT VARCHAR) ;
    PROCEDURE SHOW_SUPPLIERS(RET_VAL OUT VARCHAR) ;
    PROCEDURE SHOW_SUPPLY(RET_VAL OUT VARCHAR) ;
    PROCEDURE SHOW_LOG(RET_VAL OUT VARCHAR) ;
    
    -- Procedure: 'ADD_PURCHASE'
    
    PROCEDURE ADD_PURCHASE(E_ID IN EMPLOYEES.EID%TYPE, P_ID IN PRODUCTS.PID%TYPE, C_ID IN CUSTOMERS.CID%TYPE, PUR_QTY IN NUMBER, RET_VAL OUT VARCHAR);

    -- Procedure: 'ADD_PRODUCT'

    PROCEDURE ADD_PRODUCT(P_ID IN PRODUCTS.PID%TYPE, P_NAME IN PRODUCTS.PNAME%TYPE, AMT IN NUMBER, THRESHOLD IN NUMBER, OG_PRICE IN NUMBER, DIS_RATE IN NUMBER, RET_VAL OUT VARCHAR);

    -- Procedure: 'REPORT_MONTHLY_SALE'

    PROCEDURE REPORT_MONTHLY_SALE(P_ID IN PRODUCTS.PID%TYPE, RET_VAL OUT VARCHAR);

END RBMS;
/
SHOW ERRORS

CREATE or REPLACE PACKAGE BODY RBMS AS

 -- PROCEDURES: 'SHOW_X' ----------------------------------------------------------------------------------------------
    PROCEDURE SHOW_CUSTOMERS(RET_VAL OUT VARCHAR) IS
    BEGIN
        RET_VAL := 'SHOW_CUSTOMERS X';
        FOR c IN (SELECT * FROM CUSTOMERS) LOOP
            dbms_output.put_line('Customer ID: ' || c.cid || ' - ' || c.cname);
            RET_VAL:= RET_VAL || ('Customer ID: ' || c.cid || ' - ' || c.cname || ' X');
        END LOOP;
    END SHOW_CUSTOMERS;

    PROCEDURE SHOW_EMPLOYEES(RET_VAL OUT VARCHAR)  IS
    BEGIN
        RET_VAL := 'SHOW_EMPLOYEES X';
        FOR e IN (SELECT * FROM EMPLOYEES) LOOP
            dbms_output.put_line('Employee ID: ' || e.eid || ' - ' || e.ename);
            RET_VAL:= RET_VAL || ('Employee ID: ' || e.eid || ' - ' || e.ename || ' X');
        END LOOP;
    END SHOW_EMPLOYEES;

    PROCEDURE SHOW_PRODUCTS(RET_VAL OUT VARCHAR)  IS
    BEGIN
        RET_VAL := 'SHOW_PRODUCTS X';
        FOR p IN (SELECT * FROM PRODUCTS) LOOP
            dbms_output.put_line('Product ID: ' || p.pid || ' - ' || p.pname);
            RET_VAL := RET_VAL || ('Product ID: ' || p.pid || ' - ' || p.pname)|| ' X';
        END LOOP;
    END SHOW_PRODUCTS;

    PROCEDURE SHOW_PURCHASES(RET_VAL OUT VARCHAR)  IS
    BEGIN
        RET_VAL := 'SHOW_PURCHASES X';
        FOR pur IN (SELECT * FROM PURCHASES) LOOP
            dbms_output.put_line('Purchase #: ' || pur.pur# || ' - ' || pur.ptime);
            RET_VAL:= RET_VAL || ('Purchase #: ' || pur.pur# || ' - ' || pur.ptime || ' X');
        END LOOP;
    END SHOW_PURCHASES;

    PROCEDURE SHOW_SUPPLIERS(RET_VAL OUT VARCHAR)  IS
    BEGIN
        RET_VAL := 'SHOW_SUPPLIERS X';
        FOR s IN (SELECT * FROM SUPPLIERS) LOOP
            dbms_output.put_line('Supplier ID: ' || s.sid || ' - ' || s.sname);
            RET_VAL:= RET_VAL || ('Supplier ID: ' || s.sid || ' - ' || s.sname) || ' X';
        END LOOP;
    END SHOW_SUPPLIERS;

    PROCEDURE SHOW_SUPPLY(RET_VAL OUT VARCHAR)  IS 
    BEGIN
        RET_VAL := 'SHOW_SUPPLY X';
        FOR sup IN (SELECT * FROM SUPPLY) LOOP
            dbms_output.put_line('Supply #: ' || sup.sup# || ' - Quantity: ' || sup.quantity);
            RET_VAL:= RET_VAL || ('Supply #: ' || sup.sup# || ' - Quantity: ' || sup.quantity || ' X');
        END LOOP;
    END SHOW_SUPPLY;

    PROCEDURE SHOW_LOG(RET_VAL OUT VARCHAR)  IS
    BEGIN
        RET_VAL := 'SHOW_LOG X';
        FOR l IN (SELECT * FROM LOGS)LOOP
            dbms_output.put_line('Log #: ' || l.log#);
            RET_VAL:= RET_VAL || ('Log #: ' || l.log# || ' X');
        END LOOP;
    END SHOW_LOG;
    
    -- Procedure: 'ADD_PURCHASE'
    
    PROCEDURE ADD_PURCHASE(E_ID IN EMPLOYEES.EID%TYPE, P_ID IN PRODUCTS.PID%TYPE, C_ID IN CUSTOMERS.CID%TYPE, PUR_QTY IN NUMBER, RET_VAL OUT VARCHAR) IS
        OG_PRICE NUMBER;
        DIS_RATE NUMBER;
        UNIT_PRICE NUMBER;
        TOTAL_PRICE NUMBER;

        EID_FLAG NUMBER;
        PID_FLAG NUMBER;
        CID_FLAG NUMBER;
        RESUPPLY_FLAG NUMBER;
        RESUPPLY_AMT NUMBER;

        EID_ERROR EXCEPTION;
        EID_EXIST_ERROR EXCEPTION;
        PID_ERROR EXCEPTION;
        PID_EXIST_ERROR EXCEPTION;
        CID_ERROR EXCEPTION;
        CID_EXIST_ERROR EXCEPTION;
        PUR_QTY_ERROR EXCEPTION;

    BEGIN
        EID_FLAG := 0;
        PID_FLAG := 0;
        CID_FLAG := 0;

        SELECT COUNT(*) INTO EID_FLAG FROM EMPLOYEES WHERE EID = E_ID;
        SELECT COUNT(*) INTO PID_FLAG FROM PRODUCTS WHERE PID = P_ID;
        SELECT COUNT(*) INTO CID_FLAG FROM CUSTOMERS WHERE CID = C_ID;
        
        IF (LENGTH(E_ID) > 3) THEN RAISE EID_ERROR;
        END IF;
        IF (SUBSTR(E_ID,1,1) != 'e') THEN RAISE EID_ERROR;
        END IF;
        IF (EID_FLAG < 1) THEN RAISE EID_EXIST_ERROR;
        END IF;
        IF (LENGTH(P_ID) > 4) THEN RAISE PID_ERROR;
        END IF;
        IF (SUBSTR(P_ID,1,1) != 'p') THEN RAISE PID_ERROR;
        END IF;
        IF (PID_FLAG < 1) THEN RAISE PID_EXIST_ERROR;
        END IF;
        IF (LENGTH(C_ID) > 4) THEN RAISE CID_ERROR;
        END IF;
        IF (SUBSTR(C_ID,1,1) != 'c') THEN RAISE CID_ERROR;
        END IF;
        IF (CID_FLAG < 1) THEN RAISE CID_EXIST_ERROR;
        END IF;
        IF (LENGTH(TO_CHAR(PUR_QTY)) > 5) THEN RAISE PUR_QTY_ERROR;
        END IF;

        SELECT original_price, discnt_rate INTO OG_PRICE, DIS_RATE
        FROM PRODUCTS
        WHERE PID = P_ID;

        UNIT_PRICE := OG_PRICE - (OG_PRICE * DIS_RATE);
        TOTAL_PRICE := UNIT_PRICE * PUR_QTY;
        
        INSERT INTO PURCHASES 
        (
          PUR#,
          EID,
          PID,
          CID,
          QTY,
          PTIME,
          TOTAL_PRICE
        )
        VALUES
        (
          PUR_NUM.NEXTVAL,
          E_ID,
          P_ID,
          C_ID,
          PUR_QTY,
          SYSDATE,
          TOTAL_PRICE
        );

        dbms_output.put_line(E_ID || ' SUCCESSFULLY COMPLETED PURCHASE OF '|| PUR_QTY || ' ' || P_ID || ' TO ' || C_ID || ' ON ' || SYSDATE || '.');
        RET_VAL := (E_ID || ' SUCCESSFULLY COMPLETED TRANSACTION OF '|| PUR_QTY || ' ' || P_ID || ' TO ' || C_ID || ' ON ' || SYSDATE || '.');

        SELECT COUNT(*) INTO RESUPPLY_FLAG FROM RESUPPLY WHERE PID = P_ID;
        SELECT AMT INTO RESUPPLY_AMT FROM RESUPPLY WHERE PID = P_ID;

        IF (RESUPPLY_FLAG > 0) THEN
            RET_VAL := RET_VAL || (' X PRODUCT ID ' || P_ID || ' IS BELOW QOH THRESHOLD. NEW SUPPLY IS REQUIRED.');
            RET_VAL := RET_VAL || (' X PRODUCT ID ' || P_ID || ' - SUPPLY ORDERED.');
            RET_VAL := RET_VAL || (' X PRODUCT ID ' || P_ID|| ' NOW HAS ' || RESUPPLY_AMT || ' AVALIABLE.');
        END IF;
        
        
        DELETE FROM RESUPPLY
        WHERE PID = P_ID;
        

        EXCEPTION

        WHEN EID_ERROR THEN
        RAISE_APPLICATION_ERROR (-20010, 'EID INPUT ERROR. FORMAT: e##');
        WHEN EID_EXIST_ERROR THEN
        RAISE_APPLICATION_ERROR (-20011, 'EID INPUT ERROR. EMPLOYEE DOES NOT EXIST IN DATABASE.');
        WHEN PID_ERROR THEN
        RAISE_APPLICATION_ERROR (-20012, 'PID INPUT ERROR. FORMAT: p###');
        WHEN PID_EXIST_ERROR THEN
        RAISE_APPLICATION_ERROR (-20013, 'EID INPUT ERROR. PRODUCT DOES NOT EXIST IN DATABASE.');
        WHEN CID_ERROR THEN
        RAISE_APPLICATION_ERROR (-20014, 'CID INPUT ERROR. FORMAT: c###');
        WHEN CID_EXIST_ERROR THEN
        RAISE_APPLICATION_ERROR (-20015, 'EID INPUT ERROR. CUSTOMER DOES NOT EXIST IN DATABASE.');
        WHEN PUR_QTY_ERROR THEN
        RAISE_APPLICATION_ERROR (-20016, 'QTY INPUT ERROR. FORMAT: NUBMER(5 DIGITS MAX).');
        

    END ADD_PURCHASE;

    -- Procedure: 'ADD_PRODUCT' --------------------------------------------------------------------------------------------------------------------
    
    PROCEDURE ADD_PRODUCT(P_ID IN PRODUCTS.PID%TYPE, P_NAME IN PRODUCTS.PNAME%TYPE, AMT IN NUMBER, THRESHOLD IN NUMBER, OG_PRICE IN NUMBER, DIS_RATE IN NUMBER, RET_VAL OUT VARCHAR) IS


        PID_ERROR EXCEPTION;
        PNAME_ERROR EXCEPTION;
        QOH_ERROR EXCEPTION;
        THRESHOLD_ERROR EXCEPTION;
        PRICE_ERROR EXCEPTION;
        DIS_RATE_ERROR EXCEPTION;
    BEGIN

        IF (LENGTH(P_ID) > 4) THEN RAISE PID_ERROR;
        END IF;
        IF (SUBSTR(P_ID,1,1) != 'p') THEN RAISE PID_ERROR;
        END IF;
        IF (LENGTH(P_NAME) > 15) THEN RAISE PNAME_ERROR;
        END IF;
        IF (LENGTH(TO_CHAR(AMT)) > 5) THEN RAISE QOH_ERROR;
        END IF;
        IF (LENGTH(TO_CHAR(THRESHOLD)) > 5) THEN RAISE THRESHOLD_ERROR;
        END IF;
        IF (LENGTH(TO_CHAR(DIS_RATE)) > 4) THEN RAISE DIS_RATE_ERROR;
        END IF;
        IF (DIS_RATE < 0) THEN RAISE DIS_RATE_ERROR;
        END IF;
        IF (DIS_RATE > 0.8) THEN RAISE DIS_RATE_ERROR;
        END IF;

        INSERT INTO PRODUCTS 
        (
            pid,
            pname,
            qoh,
            qoh_threshold,
            original_price,
            discnt_rate
        )
        VALUES
        (
            P_ID,
            P_NAME,
            AMT,
            THRESHOLD,
            OG_PRICE,
            DIS_RATE
        );

        dbms_output.put_line('SUCCESSFULLY ADDED ' || P_NAME|| ' INTO INVENTORY WITH ' || AMT || ' ON HAND.');
        RET_VAL:= ('SUCCESSFULLY ADDED ' || P_NAME|| ' INTO INVENTORY WITH ' || AMT || ' ON HAND.');

        EXCEPTION
        WHEN PID_ERROR THEN
        RAISE_APPLICATION_ERROR (-20012, 'PID INPUT ERROR. FORMAT: p###');
        WHEN PNAME_ERROR THEN
        RAISE_APPLICATION_ERROR (-20017, 'PNAME INPUT ERROR. FORMAT: VARCHAR(15).');
        WHEN QOH_ERROR THEN
        RAISE_APPLICATION_ERROR (-20018, 'QUANTITY INPUT ERROR. FORMAT: NUMBER(5).');
        WHEN THRESHOLD_ERROR THEN
        RAISE_APPLICATION_ERROR (-20019, 'QUANTITY THRESHOLD INPUT ERROR. FORMAT: NUMBER(4).');
        WHEN PRICE_ERROR THEN
        RAISE_APPLICATION_ERROR (-20020, 'PRICE INPUT ERROR. FORMAT: NUMBER(6,2).');
        WHEN DIS_RATE_ERROR THEN
        RAISE_APPLICATION_ERROR (-20021, 'DISCOUNT RATE INPUT ERROR. FORMAT: NUMBER(3,2).');
    
    END ADD_PRODUCT;


    PROCEDURE REPORT_MONTHLY_SALE(P_ID IN PRODUCTS.PID%TYPE, RET_VAL OUT VARCHAR) IS

        PRODUCT_NAME VARCHAR(15);
        MONTH_COUNTER VARCHAR(3);
        YEAR_COUNTER VARCHAR(4);
        AVG_SALE_PRICE NUMBER(6,2);
        SALE_SUM NUMBER(38,2);
        SALE_AMT NUMBER;

        

        PID_FLAG NUMBER;
        PID_ERROR EXCEPTION;
        PID_EXIST_ERROR EXCEPTION;

    BEGIN
        PID_FLAG := 0;

        SELECT COUNT(*) INTO PID_FLAG FROM PRODUCTS WHERE PID = P_ID;

        IF (LENGTH(P_ID) > 4) THEN RAISE PID_ERROR;
        END IF;
        IF (PID_FLAG < 1) THEN RAISE PID_EXIST_ERROR;
        END IF;

        MONTH_COUNTER := '---';
        YEAR_COUNTER := '----';

        SELECT UPPER(PNAME) INTO PRODUCT_NAME FROM PRODUCTS WHERE PID = P_ID;

        RET_VAL:= ('MONTHLY SALE REPORT ON ' || PRODUCT_NAME);

        FOR X IN (SELECT QTY, PTIME, TOTAL_PRICE FROM PURCHASES WHERE PID = P_ID ORDER BY PTIME) LOOP

            IF (YEAR_COUNTER = '----') THEN
                SALE_SUM := 0;
                SALE_AMT := 0;
                YEAR_COUNTER := TO_CHAR(X.PTIME, 'YYYY');
                MONTH_COUNTER := TO_CHAR(X.PTIME, 'Mon');

            END IF;

            IF (YEAR_COUNTER != TO_CHAR(X.PTIME, 'YYYY')) THEN
                AVG_SALE_PRICE := SALE_SUM / SALE_AMT;
                RET_VAL := RET_VAL || ( ' X ' || PRODUCT_NAME || ' - ' || MONTH_COUNTER || ' ' || YEAR_COUNTER || ' -  TOTAL QTY SOLD: ' || SALE_AMT || 
                ' - TOTAL SALE AMOUNT: ' ||  SALE_SUM ||' WITH THE AVERAGE SALE PRICE BEING ' || AVG_SALE_PRICE || '.');
                SALE_SUM := 0;
                SALE_AMT := 0;
                YEAR_COUNTER := TO_CHAR(X.PTIME, 'YYYY');


                IF (MONTH_COUNTER != TO_CHAR(X.PTIME, 'Mon')) THEN

                    AVG_SALE_PRICE := SALE_SUM / SALE_AMT;
                    RET_VAL := RET_VAL || ( ' X ' || PRODUCT_NAME || ' - ' || MONTH_COUNTER || ' ' || YEAR_COUNTER || ' -  TOTAL QTY SOLD: ' || SALE_AMT || 
                    ' - TOTAL SALE AMOUNT: ' ||  SALE_SUM ||' WITH THE AVERAGE SALE PRICE BEING ' || AVG_SALE_PRICE || '.');
                    SALE_SUM := 0;
                    SALE_AMT := 0;
                    MONTH_COUNTER := TO_CHAR(X.PTIME, 'Mon');

                END IF;
            END IF;

            SALE_AMT := SALE_AMT + X.QTY;
            SALE_SUM := SALE_SUM + X.TOTAL_PRICE;

        END LOOP;
        

        AVG_SALE_PRICE := SALE_SUM / SALE_AMT;
        RET_VAL := RET_VAL || ( ' X ' || PRODUCT_NAME || ' - ' || MONTH_COUNTER || ' ' || YEAR_COUNTER || ' -  TOTAL QTY SOLD: ' || SALE_AMT || 
        ' - TOTAL SALE AMOUNT: ' ||  SALE_SUM ||' WITH THE AVERAGE SALE PRICE BEING ' || AVG_SALE_PRICE || '.');

        EXCEPTION
        WHEN PID_ERROR THEN
        RAISE_APPLICATION_ERROR (-20012, 'PID INPUT ERROR. FORMAT: p###');
        WHEN PID_EXIST_ERROR THEN
        RAISE_APPLICATION_ERROR (-20013, 'EID INPUT ERROR. PRODUCT DOES NOT EXIST IN DATABASE.');

    END REPORT_MONTHLY_SALE;

END RBMS;
/
SHOW ERRORS