CREATE OR REPLACE PACKAGE space_booking_pkg AS
    -- Procedure to show available spaces in a building
    PROCEDURE show_available_spaces(p_building_name VARCHAR2);

    -- Procedure to book a space
    PROCEDURE book_space(
        p_space_id NUMBER,
        p_customer_id NUMBER,
        p_booking_start_date DATE,
        p_booking_end_date DATE
    );

    -- Procedure to cancel a booking
    PROCEDURE cancel_booking(p_booking_id NUMBER);

    -- Procedure to process a payment
    PROCEDURE process_payment(
        p_payment_id IN NUMBER,         -- Unique Payment ID
        p_booking_id IN NUMBER,         -- Associated Booking ID
        p_payment_type IN VARCHAR2,     -- Payment method (e.g., CREDIT, DEBIT)
        p_payment_date IN DATE          -- Payment date
    );

    -- Function to check availability of a space
    FUNCTION is_space_available(p_space_id NUMBER, p_start_date DATE, p_end_date DATE) RETURN BOOLEAN;

    -- Function to get average rating of a space
    FUNCTION get_space_rating(p_space_id NUMBER) RETURN NUMBER;

END space_booking_pkg;
/

CREATE OR REPLACE PACKAGE BODY space_booking_pkg AS

    -- Procedure: Show available spaces in a building
    PROCEDURE show_available_spaces(p_building_name VARCHAR2) IS
        v_cursor SYS_REFCURSOR;
        v_space_id NUMBER;
        v_space_type VARCHAR2(255);
        v_status VARCHAR2(20);
        v_space_price NUMBER;
    BEGIN
        OPEN v_cursor FOR
            SELECT SPACE_ID, SPACE_TYPE, STATUS, SPACE_PRICE
            FROM SPACE
            WHERE BUILDING_ID = (SELECT BUILDING_ID FROM BUILDING WHERE BUILDING_NAME = p_building_name)
              AND STATUS = 'AVAILABLE';
              
        DBMS_OUTPUT.PUT_LINE('Available Spaces in ' || p_building_name || ':');
        LOOP
            FETCH v_cursor INTO v_space_id, v_space_type, v_status, v_space_price;
            EXIT WHEN v_cursor%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE('Space ID: ' || v_space_id || 
                                 ', Type: ' || v_space_type || 
                                 ', Price: ' || v_space_price || 
                                 ', Status: ' || v_status);
        END LOOP;
        CLOSE v_cursor;
    END show_available_spaces;

    -- Procedure: Book a space
    PROCEDURE book_space(
        p_space_id NUMBER,
        p_customer_id NUMBER,
        p_booking_start_date DATE,
        p_booking_end_date DATE
    ) IS
        v_booking_id NUMBER;
        v_space_available BOOLEAN;
        v_total_hours NUMBER;
    BEGIN
        -- Check if the space is available
        v_space_available := is_space_available(p_space_id, p_booking_start_date, p_booking_end_date);
        IF NOT v_space_available THEN
            DBMS_OUTPUT.PUT_LINE('Space is not available for the selected dates.');
            RETURN;
        END IF;

        -- Calculate booking total hours
        v_total_hours := (p_booking_end_date - p_booking_start_date) * 24;

        -- Insert booking record
        SELECT NVL(MAX(BOOKING_ID), 200) + 1 INTO v_booking_id FROM BOOKING;

        INSERT INTO BOOKING (BOOKING_ID, CUSTOMER_ID, BOOKING_START_DATE, BOOKING_END_DATE, BOOKING_TOTAL_HOURS)
        VALUES (v_booking_id, p_customer_id, p_booking_start_date, p_booking_end_date, v_total_hours);

        -- Update space status
        UPDATE SPACE
        SET STATUS = 'Booked', BOOKING_ID = v_booking_id
        WHERE SPACE_ID = p_space_id;

        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Booking successful! Booking ID: ' || v_booking_id);
    END book_space;

    -- Procedure: Cancel a booking
    PROCEDURE cancel_booking(p_booking_id NUMBER) IS
    v_count NUMBER;
  BEGIN
    -- Check if the booking ID exists
    SELECT COUNT(*)
    INTO v_count
    FROM BOOKING
    WHERE BOOKING_ID = p_booking_id;

    -- If booking ID does not exist, raise an error
    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Error: Booking ID ' || p_booking_id || ' does not exist.');
    END IF;

    -- Step 1: Delete related payments first
    DELETE FROM PAYMENT
    WHERE BOOKING_ID = p_booking_id;

    -- Step 2: Update space status
    UPDATE SPACE
    SET STATUS = 'AVAILABLE', BOOKING_ID = NULL
    WHERE BOOKING_ID = p_booking_id;

    -- Step 3: Delete booking record
    DELETE FROM BOOKING
    WHERE BOOKING_ID = p_booking_id;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Booking with ID ' || p_booking_id || ' has been canceled.');
  END cancel_booking;

 

    -- Procedure: Process a payment
    PROCEDURE process_payment(
        p_payment_id IN NUMBER,         -- Unique Payment ID
        p_booking_id IN NUMBER,         -- Associated Booking ID
        p_payment_type IN VARCHAR2,     -- Payment method (e.g., CREDIT, DEBIT)
        p_payment_date IN DATE          -- Payment date
    ) IS
        v_booking_exists NUMBER;        -- Variable to check booking existence
        v_total_hours NUMBER;           -- Duration of the booking in hours
        v_space_id NUMBER;              -- Space associated with the booking
        v_space_price NUMBER;           -- Price per hour for the space
        v_total_amount NUMBER;          -- Calculated total payment amount
    BEGIN
        -- Step 1: Check if the booking exists
        SELECT COUNT(*)
        INTO v_booking_exists
        FROM BOOKING
        WHERE BOOKING_ID = p_booking_id;

        IF v_booking_exists = 0 THEN
            -- If booking does not exist, raise an error
            RAISE_APPLICATION_ERROR(-20001, 'Booking ID does not exist.');
        END IF;

        -- Step 2: Retrieve booking duration and associated space
        SELECT B.BOOKING_TOTAL_HOURS, S.SPACE_ID, S.SPACE_PRICE
        INTO v_total_hours, v_space_id, v_space_price
        FROM BOOKING B
        JOIN SPACE S ON B.BOOKING_ID = S.BOOKING_ID
        WHERE B.BOOKING_ID = p_booking_id;

        -- Step 3: Calculate the total amount
        v_total_amount := v_total_hours * v_space_price;

        -- Step 4: Insert payment record
        INSERT INTO PAYMENT (PAYMENT_ID, BOOKING_ID, TOTAL_AMOUNT, PAYMENT_TYPE, PAYMENT_DATE)
        VALUES (p_payment_id, p_booking_id, v_total_amount, p_payment_type, p_payment_date);

        -- Step 5: Output payment details
        DBMS_OUTPUT.PUT_LINE('Payment successfully processed.');
        DBMS_OUTPUT.PUT_LINE('Booking ID: ' || p_booking_id);
        DBMS_OUTPUT.PUT_LINE('Space ID: ' || v_space_id);
        DBMS_OUTPUT.PUT_LINE('Total Hours: ' || v_total_hours);
        DBMS_OUTPUT.PUT_LINE('Price Per Hour: ' || v_space_price);
        DBMS_OUTPUT.PUT_LINE('Total Amount: ' || v_total_amount);

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            -- Handle cases where booking or space details are missing
            DBMS_OUTPUT.PUT_LINE('Error: Booking or associated space details not found.');
            ROLLBACK;
        WHEN OTHERS THEN
            -- Handle any unexpected errors
            DBMS_OUTPUT.PUT_LINE('Error occurred: ' || SQLERRM);
            ROLLBACK;
    END process_payment;

    -- Function: Check space availability
    FUNCTION is_space_available(p_space_id NUMBER, p_start_date DATE, p_end_date DATE) RETURN BOOLEAN IS
        v_count NUMBER;
    BEGIN
        SELECT COUNT(*)
        INTO v_count
        FROM SPACE
        WHERE SPACE_ID = p_space_id
          AND STATUS = 'AVAILABLE'
          AND NOT EXISTS (
              SELECT 1
              FROM BOOKING
              WHERE BOOKING_ID = SPACE.BOOKING_ID
                AND ((p_start_date BETWEEN BOOKING_START_DATE AND BOOKING_END_DATE) OR
                     (p_end_date BETWEEN BOOKING_START_DATE AND BOOKING_END_DATE))
          );
          
        RETURN v_count > 0;
    END is_space_available;

    -- Function: Get average rating of a space
    FUNCTION get_space_rating(p_space_id NUMBER) RETURN NUMBER IS
        v_avg_rating NUMBER;
    BEGIN
        SELECT AVG(RATING)
        INTO v_avg_rating
        FROM REVIEW
        WHERE SPACE_ID = p_space_id;

        IF v_avg_rating IS NULL THEN
            RETURN 0;
        ELSE
            RETURN v_avg_rating;
        END IF;
    END get_space_rating;

END space_booking_pkg;
/


---------------------------------- Triggers -------------------------------------

-- 1. Trigger to Update the Booking Table When a Space is Booked

CREATE OR REPLACE TRIGGER update_space_status_after_booking
AFTER INSERT ON BOOKING
FOR EACH ROW
BEGIN
    UPDATE SPACE
    SET STATUS = 'Booked', BOOKING_ID = :NEW.BOOKING_ID
    WHERE SPACE_ID = (SELECT SPACE_ID FROM SPACE WHERE SPACE.BOOKING_ID IS NULL AND SPACE.BUILDING_ID IN (SELECT BUILDING_ID FROM BUILDING WHERE BUILDING_ID = :NEW.BOOKING_ID));
END;
/



