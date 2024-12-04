-- Customer Managemen Execution

/* Test REGISTER_CUSTOMER */
EXEC STUDY_ADMIN.CUSTOMER_MANAGEMENT.REGISTER_CUSTOMER('MIKE', 'ROSS', 'mike.ross@example.com', '1234567890');


/* Test ADD_CUSTOMER_MEMBERSHIP */
EXEC STUDY_ADMIN.CUSTOMER_MANAGEMENT.ADD_CUSTOMER_MEMBERSHIP(6, 'MONTHLY'); 

/* Test SET_MEMBERSHIP_DURATION */
EXEC STUDY_ADMIN.CUSTOMER_MANAGEMENT.SET_MEMBERSHIP_DURATION(6, 106, TO_DATE('2024-01-01', 'YYYY-MM-DD'), TO_DATE('2024-02-01', 'YYYY-MM-DD'));


/* Test GET_TOTAL_MEMBERSHIP_COST */
SET SERVEROUTPUT ON;
DECLARE
    v_total_cost NUMBER;
BEGIN
    v_total_cost := STUDY_ADMIN.CUSTOMER_MANAGEMENT.GET_TOTAL_MEMBERSHIP_COST(1); 
    DBMS_OUTPUT.PUT_LINE('Total Membership Cost for Customer 1: ' || v_total_cost);

    v_total_cost := STUDY_ADMIN.CUSTOMER_MANAGEMENT.GET_TOTAL_MEMBERSHIP_COST(2);  
    DBMS_OUTPUT.PUT_LINE('Total Membership Cost for Customer 2: ' || v_total_cost);

    v_total_cost := STUDY_ADMIN.CUSTOMER_MANAGEMENT.GET_TOTAL_MEMBERSHIP_COST(6); 
    DBMS_OUTPUT.PUT_LINE('Total Membership Cost for Customer 6: ' || v_total_cost);
END;
/


/* Test UPDATE_CUSTOMER_INFO */
EXEC STUDY_ADMIN.CUSTOMER_MANAGEMENT.UPDATE_CUSTOMER_INFO(1, 'HARVEY', 'SPECTER', 'harvey.s@example.com', '9234543210'); 


/* Test SEARCH_CUSTOMER */

BEGIN 
    STUDY_ADMIN.CUSTOMER_MANAGEMENT.SEARCH_CUSTOMER('JANH'); -- Valid: Partial name match
END;
/

EXEC STUDY_ADMIN.CUSTOMER_MANAGEMENT.SEARCH_CUSTOMER('example.com'); 


/* Test LIST_CUSTOMER_MEMBERSHIPS */

BEGIN 
    STUDY_ADMIN.CUSTOMER_MANAGEMENT.LIST_CUSTOMER_MEMBERSHIPS(1); -- Valid: Customer with memberships
END;
/



/* TEST CANCEL_MEMBERSHIP */
EXEC STUDY_ADMIN.CUSTOMER_MANAGEMENT.CANCEL_MEMBERSHIP(106); 

/* Test DELETE_CUSTOMER */
EXEC STUDY_ADMIN.CUSTOMER_MANAGEMENT.DELETE_CUSTOMER(6);



-- Space Booking Package Execution

-- sample data

--1) View Available Spaces
SET SERVEROUTPUT ON;
EXEC study_admin.space_booking_pkg.show_available_spaces('ISEC');


--2) Book a Space
EXEC study_admin.space_booking_pkg.book_space(1006, 1, TO_DATE('2024-03-06 09:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2024-03-06 11:00:00', 'YYYY-MM-DD HH24:MI:SS'))


--3) Cancel Booking
-- Using the booking ID from the previous booking
SET SERVEROUTPUT ON;

EXEC study_admin.space_booking_pkg.cancel_booking(201); 
/

-- Non-existent booking ID
SET SERVEROUTPUT ON;

EXEC study_admin.space_booking_pkg.cancel_booking(999); 
/


--4) Check Space Availability
DECLARE
    v_available BOOLEAN;
BEGIN
    v_available := study_admin.space_booking_pkg.is_space_available(1006, TO_DATE('2024-03-04 12:15:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2024-03-04 20:15:00', 'YYYY-MM-DD HH24:MI:SS'));
    IF v_available THEN
        DBMS_OUTPUT.PUT_LINE('Space is available.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Space is not available.');
    END IF;
END;
/

--5) Check rating for particular booking_id
-- Space ID 1001
SET SERVEROUTPUT ON;

DECLARE
    v_rating NUMBER;
BEGIN
    v_rating := study_admin.space_booking_pkg.get_space_rating(1001); 
    DBMS_OUTPUT.PUT_LINE('Average Rating: ' || v_rating);
END;
/


--6) Making Payment
SET SERVEROUTPUT ON;

BEGIN
    study_admin.space_booking_pkg.PROCESS_PAYMENT(
        P_PAYMENT_ID => 1, 
        P_BOOKING_ID => 206, 
        P_PAYMENT_TYPE => 'CREDIT', 
        P_PAYMENT_DATE => TO_DATE('2024-03-01 10:00:00', 'YYYY-MM-DD HH24:MI:SS')
    );
END;
/




-- Execution of Trigger to Update the Booking Table When a Space is Booked 

SELECT SPACE_ID, BUILDING_ID, STATUS, BOOKING_ID
FROM study_admin.SPACE;



/*
SELECT * FROM BOOKING WHERE BOOKING_ID = 201;

select * from booking;
select * from payment;
select * from space;
select * from customer;

SELECT * 
FROM SPACE 
WHERE BOOKING_ID = 203;
*/


