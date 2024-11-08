------------------------------------------------------EXECUTE THIS SCRIPT TO CREATE VIEWS-------------------------------------------------------
--Execution Order: 6
--Execute using user: STUDY_ADMIN

ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD';
SET AUTOCOMMIT ON;
CLEAR SCREEN;
SET SERVEROUTPUT ON;


-- 1) Manager View : Space_Wise_Booking_Report 
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


-- 2) Manager View : Current_Booking_Status
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



-- 3) Manager View : Customer_Payment_Report
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
ORDER BY p.PAYMENT_DATE DESC;



--  1)⁠Customer_detail: A view to show customer booking details.
CREATE OR REPLACE VIEW CUSTOMER_DETAIL AS
SELECT 
    c.CUSTOMER_ID,
    c.FIRST_NAME,
    c.LAST_NAME,
    c.EMAIL,
    c.MOBILE_NO,
    b.BOOKING_ID,
    TO_CHAR(b.BOOKING_START_DATE, 'YYYY-MM-DD HH24:MI:SS') AS BOOKING_START_DATE,
    TO_CHAR(b.BOOKING_END_DATE, 'YYYY-MM-DD HH24:MI:SS') AS BOOKING_END_DATE,
    b.BOOKING_TOTAL_HOURS,
    p.TOTAL_AMOUNT AS PAYMENT_AMOUNT,
    p.PAYMENT_TYPE,
    TO_CHAR(p.PAYMENT_DATE, 'YYYY-MM-DD') AS PAYMENT_DATE
FROM 
    CUSTOMER c
JOIN 
    BOOKING b ON c.CUSTOMER_ID = b.CUSTOMER_ID
JOIN 
    PAYMENT p ON b.BOOKING_ID = p.BOOKING_ID
ORDER BY 
    c.CUSTOMER_ID;
    
    
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
    

--  3) Available_space: A view to display spaces that are available.
CREATE OR REPLACE VIEW AVAILABLE_SPACE AS
SELECT 
    s.SPACE_ID,
    s.SPACE_TYPE,
    s.SPACE_CAPACITY,
    s.SPACE_PRICE,
    s.STATUS,
    b.BUILDING_NAME,
    b.FLOOR_NUMBER
FROM 
    SPACE s
JOIN 
    BUILDING b ON s.BUILDING_ID = b.BUILDING_ID
WHERE 
    s.STATUS = 'Available'
ORDER BY 
    s.SPACE_ID;
    

-- 4) Payment_chart: A view to display membership types and their prices.
CREATE OR REPLACE VIEW PAYMENT_CHART AS
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