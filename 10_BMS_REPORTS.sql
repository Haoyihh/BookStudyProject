-------------------------------- Customer Management Reports  -----------------------------------------

SET SERVEROUTPUT ON;


-- Report 1: Customer Registration report

CREATE OR REPLACE FUNCTION GET_CUSTOMER_REGISTRATION_REPORT
RETURN SYS_REFCURSOR
IS
    customer_report_cursor SYS_REFCURSOR;
BEGIN
    OPEN customer_report_cursor FOR
        SELECT CUSTOMER_ID, FIRST_NAME, LAST_NAME, EMAIL, MOBILE_NO
        FROM CUSTOMER;

    RETURN customer_report_cursor;
END;
/

SET SERVEROUTPUT ON;

DECLARE
    customer_report_cursor SYS_REFCURSOR;
BEGIN
    -- Call the function to get the report
    customer_report_cursor := GET_CUSTOMER_REGISTRATION_REPORT;

    -- Directly print the query results
    DBMS_SQL.RETURN_RESULT(customer_report_cursor);
END;
/



-- Report 2: Report of all active members

CREATE OR REPLACE FUNCTION get_all_active_memberships RETURN SYS_REFCURSOR AS
    v_cursor SYS_REFCURSOR;
BEGIN
    OPEN v_cursor FOR SELECT
                                            c.customer_id,
                                            c.first_name
                                            || ' '
                                            || c.last_name AS customer_name,
                                            m.membership_type,
                                            cm.start_date,
                                            cm.end_date
                                        FROM
                                                 customer_membership cm
                                            JOIN membership m ON cm.membership_id = m.membership_id
                                            JOIN customer   c ON cm.customer_id = c.customer_id
                      WHERE
                          cm.end_date >= sysdate;

    RETURN v_cursor;
END;
/

SET SERVEROUTPUT ON;

DECLARE
    v_customer_id     NUMBER;
    v_customer_name   VARCHAR2(100);
    v_membership_type VARCHAR2(50);
    v_start_date      DATE;
    v_end_date        DATE;
    v_cursor          SYS_REFCURSOR;
BEGIN
    v_cursor := get_all_active_memberships;
    dbms_output.put_line('Active Memberships for All Customers:');
    LOOP
        FETCH v_cursor INTO
            v_customer_id,
            v_customer_name,
            v_membership_type,
            v_start_date,
            v_end_date;
        EXIT WHEN v_cursor%notfound;
        dbms_output.put_line('Customer ID: '
                             || v_customer_id
                             || ', Customer Name: '
                             || v_customer_name
                             || ', Membership Type: '
                             || v_membership_type
                             || ', Start Date: '
                             || to_char(v_start_date, 'YYYY-MM-DD')
                             || ', End Date: '
                             || to_char(v_end_date, 'YYYY-MM-DD'));

    END LOOP;

    CLOSE v_cursor;
END;
/


-- Report 3: Report to calculate the total revenue generated from all memberships in the database

CREATE OR REPLACE FUNCTION get_membership_total_revenue RETURN NUMBER AS
    v_total_revenue NUMBER;
BEGIN
    SELECT
        SUM(m.membership_price)
    INTO v_total_revenue
    FROM
             customer_membership cm
        JOIN membership m ON cm.membership_id = m.membership_id;

    RETURN nvl(v_total_revenue, 0);
END;
/

SET SERVEROUTPUT ON;

DECLARE
    v_total_revenue NUMBER;
BEGIN
    v_total_revenue := get_membership_total_revenue;
    dbms_output.put_line('Total Membership revenue: $' || v_total_revenue);
END;
/

-----------------------------Space Bokking Reports ---------------------------------


-- Report 4: Function to get available spaces across buildings
CREATE OR REPLACE FUNCTION get_available_spaces_report 
    RETURN SYS_REFCURSOR 
IS
    v_cursor SYS_REFCURSOR;
BEGIN
    OPEN v_cursor FOR
        SELECT B.BUILDING_NAME, S.SPACE_ID, S.SPACE_TYPE, S.STATUS
        FROM BUILDING B
        JOIN SPACE S ON B.BUILDING_ID = S.BUILDING_ID
        WHERE S.STATUS = 'AVAILABLE';
    
    RETURN v_cursor;
END get_available_spaces_report;
/

-- Anonymous block to display available space details for all buildings
DECLARE
    v_cursor SYS_REFCURSOR;
    v_building_name VARCHAR2(255);
    v_space_id NUMBER;
    v_space_type VARCHAR2(255);
    v_status VARCHAR2(20);
BEGIN
    -- Call the function to get available spaces for all buildings
    v_cursor := get_available_spaces_report;
    
    -- Fetch the results and display
    LOOP
        FETCH v_cursor INTO v_building_name, v_space_id, v_space_type, v_status;
        EXIT WHEN v_cursor%NOTFOUND;
        
        -- Print the results
        DBMS_OUTPUT.PUT_LINE('Building: ' || v_building_name ||
                             ', Space ID: ' || v_space_id || 
                             ', Type: ' || v_space_type || 
                             ', Status: ' || v_status);
    END LOOP;
    
    -- Close the cursor
    CLOSE v_cursor;
END;
/



-- Report 5: Function to get booking details by space ID

CREATE OR REPLACE FUNCTION get_booking_details_by_space(p_space_id NUMBER)
RETURN SYS_REFCURSOR IS
    v_cursor SYS_REFCURSOR;
BEGIN
    OPEN v_cursor FOR
        SELECT B.BOOKING_ID, B.CUSTOMER_ID, B.BOOKING_START_DATE, B.BOOKING_END_DATE, B.BOOKING_TOTAL_HOURS
        FROM BOOKING B
        JOIN SPACE S ON B.BOOKING_ID = S.BOOKING_ID
        WHERE S.SPACE_ID = p_space_id;
    
    RETURN v_cursor;
END get_booking_details_by_space;
/

-- Anonymous block to fetch and display booking details for each space
DECLARE
    v_cursor SYS_REFCURSOR;
    v_booking_id NUMBER;
    v_customer_id VARCHAR2(255);
    v_booking_start_date DATE;
    v_booking_end_date DATE;
    v_booking_total_hours NUMBER;
    v_space_id NUMBER;
BEGIN
    -- Fetch all unique space IDs from the SPACE table
    FOR rec IN (SELECT DISTINCT SPACE_ID FROM SPACE) LOOP
        -- Call the function to get booking details for each space
        v_cursor := get_booking_details_by_space(rec.SPACE_ID);

        -- Fetch and display the booking details for the current space
        LOOP
            FETCH v_cursor INTO v_booking_id, v_customer_id, v_booking_start_date, v_booking_end_date, v_booking_total_hours;
            EXIT WHEN v_cursor%NOTFOUND;

            DBMS_OUTPUT.PUT_LINE('Space ID: ' || rec.SPACE_ID || 
                                 ', Booking ID: ' || v_booking_id || 
                                 ', Customer ID: ' || v_customer_id || 
                                 ', Start Date: ' || v_booking_start_date || 
                                 ', End Date: ' || v_booking_end_date || 
                                 ', Total Hours: ' || v_booking_total_hours);
        END LOOP;

        -- Close the cursor
        CLOSE v_cursor;
    END LOOP;
END;
/

-- Report 6: Function to get average rating for a space

CREATE OR REPLACE FUNCTION get_space_avg_rating(p_space_id NUMBER)
RETURN NUMBER IS
    v_avg_rating NUMBER;
BEGIN
    SELECT AVG(RATING)
    INTO v_avg_rating
    FROM REVIEW
    WHERE SPACE_ID = p_space_id;

    RETURN NVL(v_avg_rating, 0);
END get_space_avg_rating;
/

-- Anonymous block to display average rating for all spaces
DECLARE
    v_cursor SYS_REFCURSOR;
    v_space_id NUMBER;
    v_avg_rating NUMBER;
BEGIN
    -- Open a cursor to select all space IDs
    OPEN v_cursor FOR
        SELECT SPACE_ID
        FROM SPACE;

    -- Loop through all spaces and fetch their average ratings
    LOOP
        FETCH v_cursor INTO v_space_id;
        EXIT WHEN v_cursor%NOTFOUND;

        -- Call the function for each space ID to get the average rating
        v_avg_rating := get_space_avg_rating(v_space_id);

        -- Output the space ID and average rating
        DBMS_OUTPUT.PUT_LINE('Space ID: ' || v_space_id || ', Average Rating: ' || v_avg_rating);
    END LOOP;

    -- Close the cursor
    CLOSE v_cursor;
END;
/

-- Report 7:  Function to get total payments for a customer

CREATE OR REPLACE FUNCTION get_total_payments_for_customer(p_customer_id NUMBER)
RETURN NUMBER IS
    v_total_amount NUMBER;
BEGIN
    SELECT SUM(P.TOTAL_AMOUNT)
    INTO v_total_amount
    FROM PAYMENT P
    JOIN BOOKING B ON P.BOOKING_ID = B.BOOKING_ID
    WHERE B.CUSTOMER_ID = p_customer_id;

    RETURN NVL(v_total_amount, 0);
END get_total_payments_for_customer;
/

-- Anonymous block for a particular customer
DECLARE
    v_customer_id NUMBER := 3;  -- for a particular customer
    v_total_payments NUMBER;
BEGIN
    -- Call the function and store the result in v_total_payments
    v_total_payments := get_total_payments_for_customer(v_customer_id);

    -- Display the result
    DBMS_OUTPUT.PUT_LINE('Total Payments for Customer ID ' || v_customer_id || ' : ' || v_total_payments);
END;
/

-- Anonymous block for all customers
DECLARE
    v_total_payments NUMBER;
    CURSOR customer_cursor IS
        SELECT DISTINCT CUSTOMER_ID
        FROM BOOKING;  -- Assuming all customers have at least one booking
BEGIN
    -- Loop through each customer
    FOR customer_record IN customer_cursor LOOP
        -- Call the function and get total payments for the customer
        v_total_payments := get_total_payments_for_customer(customer_record.CUSTOMER_ID);

        -- Display the result for the current customer
        DBMS_OUTPUT.PUT_LINE('Customer ID: ' || customer_record.CUSTOMER_ID || 
                             ' Total Payments: ' || v_total_payments);
    END LOOP;
END;
/


-- Report 8:  Available Space Count in a Building

CREATE OR REPLACE FUNCTION get_available_space_count(p_building_name VARCHAR2)
RETURN NUMBER IS
    v_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM SPACE S
    JOIN BUILDING B ON S.BUILDING_ID = B.BUILDING_ID
    WHERE B.BUILDING_NAME = p_building_name
      AND S.STATUS = 'AVAILABLE';

    RETURN v_count;
END get_available_space_count;
/

-- Now, execute the anonymous block to get available space counts for all buildings.
DECLARE
    v_available_space_count NUMBER;
    v_building_name VARCHAR2(100);
    CURSOR building_cursor IS
        SELECT BUILDING_NAME FROM BUILDING;  -- Select all buildings
BEGIN
    -- Loop through all buildings
    FOR building_rec IN building_cursor LOOP
        v_building_name := building_rec.BUILDING_NAME;

        -- Call the function to get available space count for the current building
        v_available_space_count := get_available_space_count(v_building_name);

        -- Display the result for the current building
        DBMS_OUTPUT.PUT_LINE('Available spaces in ' || v_building_name || ': ' || v_available_space_count);
    END LOOP;
END;
/



