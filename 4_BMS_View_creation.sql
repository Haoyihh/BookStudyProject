------------------------------------------------------EXECUTE THIS SCRIPT TO CREATE VIEWS-------------------------------------------------------
--Execution Order: 6
--Execute using user: STUDY_ADMIN

ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD';
SET AUTOCOMMIT ON;
CLEAR SCREEN;
SET SERVEROUTPUT ON;

--------- Manager View ---------

-- 1)Space_Wise_Booking_Report 
CREATE OR REPLACE VIEW Space_Wise_Booking_Report AS
SELECT 
    b.BOOKING_ID,
    s.SPACE_ID,
    s.SPACE_TYPE,
    s.SPACE_CAPACITY,
    s.STATUS AS SPACE_STATUS,
    s.SPACE_PRICE,
    b.BOOKING_START_DATE,
    b.BOOKING_END_DATE,
    c.CUSTOMER_ID,
    c.FIRST_NAME || ' ' || c.LAST_NAME AS CUSTOMER_NAME,
    bl.BUILDING_ID,
    bl.BUILDING_NAME,
    bl.FLOOR_NUMBER
FROM BOOKING b
JOIN CUSTOMER c ON b.CUSTOMER_ID = c.CUSTOMER_ID
JOIN SPACE s ON b.BOOKING_ID = s.BOOKING_ID
JOIN BUILDING bl ON s.BUILDING_ID = bl.BUILDING_ID
ORDER BY s.SPACE_ID, b.BOOKING_START_DATE;

select * from Space_Wise_Booking_Report;

-- 2)Current_Booking_Status
CREATE OR REPLACE VIEW Current_Booking_Status AS
SELECT 
    s.SPACE_ID,
    s.SPACE_TYPE,
    s.SPACE_CAPACITY,
    s.STATUS AS SPACE_STATUS,
    s.SPACE_PRICE,
    b.BOOKING_ID,
    c.CUSTOMER_ID,
    c.FIRST_NAME || ' ' || c.LAST_NAME AS CUSTOMER_NAME,
    b.BOOKING_START_DATE,
    b.BOOKING_END_DATE,
    CASE 
        WHEN SYSDATE BETWEEN b.BOOKING_START_DATE AND b.BOOKING_END_DATE THEN 'Booked'
        ELSE 'Available'
    END AS CURRENT_STATUS
FROM SPACE s
LEFT JOIN BOOKING b ON s.BOOKING_ID = b.BOOKING_ID
LEFT JOIN CUSTOMER c ON b.CUSTOMER_ID = c.CUSTOMER_ID
ORDER BY s.SPACE_ID;

select * from Current_Booking_Status;

-- 3)Customer_Payment_Report
CREATE OR REPLACE VIEW Customer_Payment_Report AS
SELECT 
    p.PAYMENT_ID,
    p.BOOKING_ID, 
    p.TOTAL_AMOUNT, 
    p.PAYMENT_TYPE,
    p.PAYMENT_DATE,
    c.CUSTOMER_ID,
    c.FIRST_NAME || ' ' || c.LAST_NAME AS CUSTOMER_NAME,
    bk.BOOKING_START_DATE, 
    bk.BOOKING_END_DATE
FROM 
    PAYMENT p
JOIN BOOKING bk ON p.BOOKING_ID = bk.BOOKING_ID
JOIN CUSTOMER c ON bk.CUSTOMER_ID = c.CUSTOMER_ID
ORDER BY p.PAYMENT_DATE;

select * from customer_payment_report;

-- 4)Payment_chart: A view to display membership types and their prices.
CREATE OR REPLACE VIEW MEMBERSHIP_PAYMENT_CHART AS
SELECT 
    m.MEMBERSHIP_ID,
    m.MEMBERSHIP_TYPE,
    m.MEMBERSHIP_PRICE,
    c.CUSTOMER_ID,
    c.FIRST_NAME || ' ' || c.LAST_NAME AS CUSTOMER_NAME,
    cm.START_DATE,
    cm.END_DATE
FROM 
    MEMBERSHIP m
JOIN 
    CUSTOMER_MEMBERSHIP cm ON m.MEMBERSHIP_ID = cm.MEMBERSHIP_ID
JOIN 
    CUSTOMER c ON cm.CUSTOMER_ID = c.CUSTOMER_ID
ORDER BY 
    m.MEMBERSHIP_ID, c.CUSTOMER_ID;
    
select * from MEMBERSHIP_PAYMENT_CHART;


---------- Customer View ----------

-- 1) payment chart for customer

CREATE OR REPLACE VIEW PAYMENT_CHART AS
SELECT
 DISTINCT(MEMBERSHIP_TYPE),
         (MEMBERSHIP_PRICE)
FROM 
MEMBERSHIP;

select * from PAYMENT_CHART;   
    
--  2) Space_review: A view to show customer ratings and reviews of a particular space.
CREATE OR REPLACE VIEW SPACE_REVIEW AS
SELECT 
    s.SPACE_ID,
    s.SPACE_TYPE,
    s.SPACE_CAPACITY,
    r.RATING,
    r.COMMENTS
FROM 
    SPACE s
LEFT JOIN 
    REVIEW r ON s.SPACE_ID = r.SPACE_ID
ORDER BY 
    s.SPACE_ID;
    
select * from SPACE_REVIEW;    
