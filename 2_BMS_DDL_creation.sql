SET SERVEROUTPUT ON;


--Create CUSTOMER table

DECLARE
    table_exists NUMBER;
BEGIN
    -- Check if the CUSTOMER table exists
    SELECT COUNT(*)
    INTO table_exists
    FROM user_tables
    WHERE table_name = 'CUSTOMER';
    
    
    --If the table exists, drop it
    IF table_exists > 0 THEN
       EXECUTE IMMEDIATE 'DROP TABLE "CUSTOMER" CASCADE CONSTRAINTS';
       DBMS_OUTPUT.PUT_LINE('Table CUSTOMER dropped successfully.');
   END IF;
   
   --Create the table
   EXECUTE IMMEDIATE 'CREATE TABLE CUSTOMER(
        CUSTOMER_ID   NUMBER NOT NULL PRIMARY KEY,
        FIRST_NAME    VARCHAR(255) NOT NULL,
        LAST_NAME     VARCHAR(255) NOT NULL,
        EMAIL         VARCHAR(255) NOT NULL,
        MOBILE_NO     VARCHAR(12) NOT NULL
    )';
    DBMS_OUTPUT.PUT_LINE('Table CUSTOMER created successsfully.');
END;
/



   
--Create MEMBERSHIP table

DECLARE
    table_exists NUMBER;
BEGIN
    -- Check if the MEMBERSHIP table exists
    SELECT COUNT(*)
    INTO table_exists
    FROM user_tables
    WHERE table_name = 'MEMBERSHIP';
    
    
    --If the table exists, drop it
    IF table_exists > 0 THEN
       EXECUTE IMMEDIATE 'DROP TABLE "MEMBERSHIP" CASCADE CONSTRAINTS';
       DBMS_OUTPUT.PUT_LINE('Table MEMBERSHIP dropped successfully.');
    END IF;
   
   --Create the table
   EXECUTE IMMEDIATE 'CREATE TABLE MEMBERSHIP(
         MEMBERSHIP_ID     NUMBER NOT NULL PRIMARY KEY,
         MEMBERSHIP_TYPE   VARCHAR(255) NOT NULL,
         MEMBERSHIP_PRICE  NUMBER(10,2) NOT NULL
    )';
    DBMS_OUTPUT.PUT_LINE('Table MEMBERSHIP created successsfully.');
END;
/



--CREATE CUSTOMER_MEMBERSHIP TABLE


DECLARE
    table_exists NUMBER;
BEGIN
    -- Check if the CUSTOMER_MEMBERSHIP table exists
    SELECT COUNT(*)
    INTO table_exists
    FROM user_tables
    WHERE table_name = 'CUSTOMER_MEMBERSHIP';

    -- If the table exists, drop it
    IF table_exists > 0 THEN
       EXECUTE IMMEDIATE 'DROP TABLE CUSTOMER_MEMBERSHIP CASCADE CONSTRAINTS';
       DBMS_OUTPUT.PUT_LINE('Table CUSTOMER_MEMBERSHIP dropped successfully.');
    END IF;

   -- Create the table with corrected constraints and syntax
   EXECUTE IMMEDIATE '
       CREATE TABLE CUSTOMER_MEMBERSHIP (
           CUSTOMER_MEMBER_ID NUMBER NOT NULL PRIMARY KEY,
           CUSTOMER_ID     NUMBER NOT NULL, 
           MEMBERSHIP_ID   NUMBER,
           START_DATE DATE NOT NULL,
           END_DATE DATE   NOT NULL,
           CONSTRAINT FK_customer_ID foreign key (customer_ID) references customer (customer_ID),
           CONSTRAINT FK_membership_ID foreign key (membership_ID) references membership (membership_ID)
       )';
    DBMS_OUTPUT.PUT_LINE('Table CUSTOMER_MEMBERSHIP created successfully.');
END;
/




--CREATE BOOKING TABLE


DECLARE
    table_exists NUMBER;
BEGIN
    -- Check if the BOOKING table exists
    SELECT COUNT(*)
    INTO table_exists
    FROM user_tables
    WHERE table_name = 'BOOKING';

    -- If the table exists, drop it
    IF table_exists > 0 THEN
       EXECUTE IMMEDIATE 'DROP TABLE BOOKING CASCADE CONSTRAINTS';
       DBMS_OUTPUT.PUT_LINE('Table BOOKING dropped successfully.');
    END IF;

    -- Create the table with a unique constraint name
    EXECUTE IMMEDIATE 'CREATE TABLE BOOKING (
        BOOKING_ID           NUMBER PRIMARY KEY,
        CUSTOMER_ID          NUMBER,
        BOOKING_START_DATE   TIMESTAMP NOT NULL,
        BOOKING_END_DATE     TIMESTAMP NOT NULL,
        BOOKING_TOTAL_HOURS  NUMBER,
        CONSTRAINT FK_BOOKING_CUSTOMER_ID FOREIGN KEY (CUSTOMER_ID) REFERENCES CUSTOMER (CUSTOMER_ID))';
    DBMS_OUTPUT.PUT_LINE('Table BOOKING created successfully.');
END;
/


--Create BUILDING table


DECLARE
    table_exists NUMBER;
BEGIN
    -- Check if the BUILDING table exists
    SELECT COUNT(*)
    INTO table_exists
    FROM user_tables
    WHERE table_name = 'BUILDING';

    -- If the table exists, drop it
    IF table_exists > 0 THEN
       EXECUTE IMMEDIATE 'DROP TABLE BUILDING CASCADE CONSTRAINTS';
       DBMS_OUTPUT.PUT_LINE('Table BUILDING dropped successfully.');
    END IF;

    -- Create the table
    EXECUTE IMMEDIATE 'CREATE TABLE BUILDING (
        BUILDING_ID        NUMBER PRIMARY KEY,
        BUILDING_NAME      VARCHAR2(20) NOT NULL,
        FLOOR_NUMBER       NUMBER
    )';
    DBMS_OUTPUT.PUT_LINE('Table BUILDING created successfully.');
END;
/




--CREATE SPACE TABLE

DECLARE
    table_exists NUMBER;
BEGIN
    -- Check if the SPACE table exists
    SELECT COUNT(*)
    INTO table_exists
    FROM user_tables
    WHERE table_name = 'SPACE';

    -- If the table exists, drop it
    IF table_exists > 0 THEN
       EXECUTE IMMEDIATE 'DROP TABLE SPACE CASCADE CONSTRAINTS';
       DBMS_OUTPUT.PUT_LINE('Table SPACE dropped successfully.');
    END IF;

    -- Create the table
    EXECUTE IMMEDIATE 'CREATE TABLE SPACE (
        SPACE_ID          NUMBER PRIMARY KEY,
        BUILDING_ID       NUMBER,
        BOOKING_ID        NUMBER,
        SPACE_TYPE        VARCHAR2(255) NOT NULL,
        SPACE_CAPACITY    NUMBER NOT NULL,
        STATUS            VARCHAR2(20) NOT NULL,
        SPACE_PRICE       NUMBER(10,2) NOT NULL,
        CONSTRAINT FK_BUILDING_ID FOREIGN KEY (BUILDING_ID) REFERENCES BUILDING (BUILDING_ID),
        CONSTRAINT FK_BOOKING_ID FOREIGN KEY (BOOKING_ID) REFERENCES BOOKING (BOOKING_ID)
    )';
    DBMS_OUTPUT.PUT_LINE('Table SPACE created successfully.');
END;
/




--Create PREFERENCE table

DECLARE
    table_exists NUMBER;
BEGIN
    -- Check if the PREFERENCE table exists
    SELECT COUNT(*)
    INTO table_exists
    FROM user_tables
    WHERE table_name = 'PREFERENCE';

    -- If the table exists, drop it
    IF table_exists > 0 THEN
       EXECUTE IMMEDIATE 'DROP TABLE PREFERENCE CASCADE CONSTRAINTS';
       DBMS_OUTPUT.PUT_LINE('Table PREFERENCE dropped successfully.');
    END IF;

    -- Create the table
    EXECUTE IMMEDIATE 'CREATE TABLE PREFERENCE (
        PREFERENCE_ID        NUMBER PRIMARY KEY,
        BUILDING_ID          NUMBER,
        PREFERENCE_RANK      NUMBER,
        CONSTRAINT FK_PREFERENCE_BUILDING_ID FOREIGN KEY (BUILDING_ID) REFERENCES BUILDING (BUILDING_ID)
    )';
    DBMS_OUTPUT.PUT_LINE('Table PREFERENCE created successfully.');
END;
/




--Create PAYMENT table


DECLARE
   table_exists NUMBER;
BEGIN
   --Check if the PAYMENT table exists
   SELECT COUNT(*)
   INTO table_exists
   FROM user_tables
   WHERE table_name = 'PAYMENT';
   
   
   --If the table exists, drop it
   IF table_exists > 0 THEN
      EXECUTE IMMEDIATE 'DROP TABLE PAYMENT CASCADE CONSTRAINTS';
      DBMS_OUTPUT.PUT_LINE('Table PAYMENT dropped successfully.');
   END IF;
   
   --Create the table
   EXECUTE IMMEDIATE 'CREATE TABLE PAYMENT(
      PAYMENT_ID      NUMBER PRIMARY KEY,
      BOOKING_ID      NUMBER,
      TOTAL_AMOUNT   NUMBER(10,2) NOT NULL,
      PAYMENT_TYPE    VARCHAR(20) NOT NULL,
      PAYMENT_DATE    DATE NOT NULL,
      CONSTRAINT FK_PAYMENT_BOOKING_ID foreign key (BOOKING_ID) references BOOKING (BOOKING_ID)
  )';
  DBMS_OUTPUT.PUT_LINE('Table PAYMENT created successfully.');
END;
/
  

--Create REVIEW table
DECLARE
   table_exists NUMBER;
BEGIN
   --Check if the REVIEW table exists
   SELECT COUNT(*)
   INTO table_exists
   FROM user_tables
   WHERE table_name = 'REVIEW';
   
   
   --If the table exists, drop it
   IF table_exists > 0 THEN
      EXECUTE IMMEDIATE 'DROP TABLE REVIEW CASCADE CONSTRAINTS';
      DBMS_OUTPUT.PUT_LINE('Table REVIEW dropped successfully.');
   END IF;
   
   --Create the table
   EXECUTE IMMEDIATE 'CREATE TABLE REVIEW(
      REVIEW_ID    NUMBER PRIMARY KEY,
      RATING       NUMBER(2,1) NOT NULL,
      COMMENTS     VARCHAR(255),
      SPACE_ID     NUMBER,
      CONSTRAINT FK_SPACE_ID foreign key (SPACE_ID) references space (SPACE_ID)
  )';
  DBMS_OUTPUT.PUT_LINE('Table REVIEW created successfully.');

END;
/

