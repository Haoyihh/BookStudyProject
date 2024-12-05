-- Creating required procedures and functions for Book my study Customer Management

CREATE OR REPLACE PACKAGE CUSTOMER_MANAGEMENT AS
    -- Procedure to register a new customer
    PROCEDURE REGISTER_CUSTOMER(
        p_first_name IN VARCHAR2,
        p_last_name IN VARCHAR2,
        p_email IN VARCHAR2,
        p_mobile_no IN VARCHAR2
    );

    -- Function to get total membership cost for a customer
    FUNCTION GET_TOTAL_MEMBERSHIP_COST(
        p_customer_id IN NUMBER
    ) RETURN NUMBER;

    -- Procedure to update customer information
    PROCEDURE UPDATE_CUSTOMER_INFO(
        p_customer_id IN NUMBER,
        p_first_name IN VARCHAR2,
        p_last_name IN VARCHAR2,
        p_email IN VARCHAR2,
        p_mobile_no IN VARCHAR2
    );

    -- Procedure to add a membership for a customer
    PROCEDURE ADD_CUSTOMER_MEMBERSHIP(
        p_customer_id IN NUMBER,
        p_membership_type IN VARCHAR2 -- Membership type input
    );

    -- Procedure to list all memberships for a customer
    PROCEDURE LIST_CUSTOMER_MEMBERSHIPS(
        p_customer_id IN NUMBER
    );

    -- Procedure to delete a customer and associated data
    PROCEDURE DELETE_CUSTOMER(
        p_customer_id IN NUMBER
    );

    -- Procedure to cancel the membership of the member
    PROCEDURE CANCEL_MEMBERSHIP(
        p_membership_id IN NUMBER
    );

    -- Procedure to search for customers by partial name or email
    PROCEDURE SEARCH_CUSTOMER(
        p_query IN VARCHAR2
    );

    -- Procedure to define membership start and end dates
    PROCEDURE SET_MEMBERSHIP_DURATION(
        p_customer_id IN NUMBER,
        p_membership_id IN NUMBER,
        p_start_date IN DATE,
        p_end_date IN DATE
    );
END CUSTOMER_MANAGEMENT;
/

CREATE OR REPLACE PACKAGE BODY CUSTOMER_MANAGEMENT AS

    -- Procedure to register a new customer
    PROCEDURE REGISTER_CUSTOMER(
        p_first_name IN VARCHAR2,
        p_last_name IN VARCHAR2,
        p_email IN VARCHAR2,
        p_mobile_no IN VARCHAR2
    ) AS
    BEGIN
        INSERT INTO CUSTOMER (CUSTOMER_ID, FIRST_NAME, LAST_NAME, EMAIL, MOBILE_NO)
        VALUES (CUSTOMER_SEQ.NEXTVAL, p_first_name, p_last_name, p_email, p_mobile_no);
        
         DBMS_OUTPUT.PUT_LINE(
        'Customer ' || 
        ', Name: ' || p_first_name || ' ' || p_last_name || 
        ' has been successfully registered.'
    );
        COMMIT;
       
    END;

   -- Function to get total membership cost for a customer considering the duration in months
        FUNCTION GET_TOTAL_MEMBERSHIP_COST(
        p_customer_id IN NUMBER
    ) RETURN NUMBER AS
        v_total_cost NUMBER;
    BEGIN
        -- Single query to calculate the total membership cost
        SELECT NVL(SUM(
                   M.MEMBERSHIP_PRICE * 
                   MONTHS_BETWEEN(
                       NVL(CM.END_DATE, SYSDATE), 
                       CM.START_DATE
                   )
               ), 0)
        INTO v_total_cost
        FROM CUSTOMER_MEMBERSHIP CM
        JOIN MEMBERSHIP M ON CM.MEMBERSHIP_ID = M.MEMBERSHIP_ID
        WHERE CM.CUSTOMER_ID = p_customer_id;
    
        RETURN ROUND(v_total_cost); -- Return rounded total cost
    END;

    


     -- Procedure to update customer information
    PROCEDURE UPDATE_CUSTOMER_INFO(
        p_customer_id IN NUMBER,
        p_first_name IN VARCHAR2,
        p_last_name IN VARCHAR2,
        p_email IN VARCHAR2,
        p_mobile_no IN VARCHAR2
    ) AS
    BEGIN
        UPDATE CUSTOMER
        SET FIRST_NAME = p_first_name,
            LAST_NAME = p_last_name,
            EMAIL = p_email,
            MOBILE_NO = p_mobile_no
        WHERE CUSTOMER_ID = p_customer_id;

        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Customer ID not found.');
        END IF;

        COMMIT;

        DBMS_OUTPUT.PUT_LINE('Customer ID ' || p_customer_id || ' information updated successfully.');
    END;
    
    -- Procedure to make the customer member
    
       PROCEDURE ADD_CUSTOMER_MEMBERSHIP(
        p_customer_id IN NUMBER,
        p_membership_type IN VARCHAR2
    ) AS
        v_membership_price NUMBER;
        v_membership_id NUMBER;
    BEGIN
        -- Determine the price based on membership type
        IF p_membership_type = 'MONTHLY' THEN
            v_membership_price := 60;
        ELSIF p_membership_type = 'YEARLY' THEN
            v_membership_price := 100;
        ELSE
            RAISE_APPLICATION_ERROR(-20001, 'Invalid membership type. Only MONTHLY or YEARLY allowed.');
        END IF;
    
        -- Insert the membership details into the MEMBERSHIP table
        v_membership_id := MEMBERSHIP_SEQ.NEXTVAL;
        INSERT INTO MEMBERSHIP (
            MEMBERSHIP_ID, MEMBERSHIP_TYPE, MEMBERSHIP_PRICE
        ) VALUES (
            v_membership_id, 
            p_membership_type, 
            v_membership_price
        );
    
    
        DBMS_OUTPUT.PUT_LINE('Customer ' || p_customer_id || 
                             ' sign up for ' || p_membership_type || 
                             ' membership with price ' || v_membership_price);
    
        COMMIT;
    END;
    
    
    -- Procedure to list all memberships for a customer
    PROCEDURE LIST_CUSTOMER_MEMBERSHIPS(
        p_customer_id IN NUMBER
    ) AS
    BEGIN
        FOR membership_record IN (
            SELECT MEMBERSHIP.MEMBERSHIP_TYPE, MEMBERSHIP.MEMBERSHIP_PRICE
            FROM CUSTOMER_MEMBERSHIP
            JOIN MEMBERSHIP ON CUSTOMER_MEMBERSHIP.MEMBERSHIP_ID = MEMBERSHIP.MEMBERSHIP_ID
            WHERE CUSTOMER_MEMBERSHIP.CUSTOMER_ID = p_customer_id
        ) LOOP
            DBMS_OUTPUT.PUT_LINE('Membership: ' || membership_record.MEMBERSHIP_TYPE || 
                                 ', Price: ' || membership_record.MEMBERSHIP_PRICE);
        END LOOP;
    END;

    -- Procedure to delete a customer and associated data
    PROCEDURE DELETE_CUSTOMER(
        p_customer_id IN NUMBER
    ) AS
    BEGIN
        DELETE FROM CUSTOMER_MEMBERSHIP WHERE CUSTOMER_ID = p_customer_id;
        DELETE FROM CUSTOMER WHERE CUSTOMER_ID = p_customer_id;

        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20002, 'Customer ID not found.');
        END IF;

        COMMIT;
    END;

    -- Procedure to cancel the membership
    PROCEDURE CANCEL_MEMBERSHIP(p_membership_id IN NUMBER) AS
    BEGIN
        DELETE FROM CUSTOMER_MEMBERSHIP
        WHERE MEMBERSHIP_ID = p_membership_id;

        DELETE FROM MEMBERSHIP
        WHERE MEMBERSHIP_ID = p_membership_id;

        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20002, 'Membership ID not found for deletion.');
        END IF;
        

        COMMIT;
    END;

    -- Procedure to search for customers by partial name or email
    PROCEDURE SEARCH_CUSTOMER(
        p_query IN VARCHAR2
    ) AS
    BEGIN
        FOR customer_record IN (
            SELECT CUSTOMER_ID, FIRST_NAME, LAST_NAME, EMAIL
            FROM CUSTOMER
            WHERE LOWER(FIRST_NAME) LIKE '%' || LOWER(p_query) || '%'
               OR LOWER(LAST_NAME) LIKE '%' || LOWER(p_query) || '%'
               OR LOWER(EMAIL) LIKE '%' || LOWER(p_query) || '%'
        ) LOOP
            DBMS_OUTPUT.PUT_LINE('Customer ID: ' || customer_record.CUSTOMER_ID || 
                                 ', Name: ' || customer_record.FIRST_NAME || ' ' || customer_record.LAST_NAME || 
                                 ', Email: ' || customer_record.EMAIL);
        END LOOP;
    END;

    -- Procedure to define membership start and end dates
    PROCEDURE SET_MEMBERSHIP_DURATION(
        p_customer_id IN NUMBER,
        p_membership_id IN NUMBER,
        p_start_date IN DATE,
        p_end_date IN DATE
    ) AS
        v_customer_membership_id NUMBER;
    BEGIN
        IF p_start_date >= p_end_date THEN
            RAISE_APPLICATION_ERROR(-20005, 'End date must be after start date.');
        END IF;

        BEGIN
            SELECT CUSTOMER_MEMBER_ID
            INTO v_customer_membership_id
            FROM CUSTOMER_MEMBERSHIP
            WHERE CUSTOMER_ID = p_customer_id
              AND MEMBERSHIP_ID = p_membership_id;

            UPDATE CUSTOMER_MEMBERSHIP
            SET START_DATE = p_start_date,
                END_DATE = p_end_date
            WHERE CUSTOMER_MEMBER_ID = v_customer_membership_id;

            DBMS_OUTPUT.PUT_LINE('Updated membership duration for customer ' || p_customer_id);
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                INSERT INTO CUSTOMER_MEMBERSHIP (
                    CUSTOMER_MEMBER_ID, CUSTOMER_ID, MEMBERSHIP_ID, START_DATE, END_DATE
                ) VALUES (
                    CUSTOMER_MEMBERSHIP_SEQ.NEXTVAL, p_customer_id, p_membership_id, p_start_date, p_end_date
                );

                DBMS_OUTPUT.PUT_LINE('Inserted new membership duration for customer ' || p_customer_id);
        END;

        COMMIT;
    END;

END CUSTOMER_MANAGEMENT;
/