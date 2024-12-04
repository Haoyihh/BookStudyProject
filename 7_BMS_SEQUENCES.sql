-- Customer sequence

DECLARE
    v_max_id NUMBER;
BEGIN
    -- Find the current maximum CUSTOMER_ID
    SELECT NVL(MAX(CUSTOMER_ID), 0)
    INTO v_max_id
    FROM CUSTOMER;

    -- Drop the existing sequence if it exists
    BEGIN
        EXECUTE IMMEDIATE 'DROP SEQUENCE CUSTOMER_SEQ';
    EXCEPTION
        WHEN OTHERS THEN
            NULL; -- Ignore errors if the sequence does not exist
    END;

    -- Create the sequence starting from max + 1
    EXECUTE IMMEDIATE 'CREATE SEQUENCE CUSTOMER_SEQ START WITH ' || (v_max_id + 1) || ' INCREMENT BY 1';
END;
/


-- Membership_id sequence

BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE MEMBERSHIP_SEQ';
EXCEPTION
    WHEN OTHERS THEN
        NULL; -- Ignore errors if the sequence does not exist
END;

DECLARE
    v_last_id NUMBER;
BEGIN
    -- Fetch the maximum membership ID
    SELECT NVL(MAX(MEMBERSHIP_ID), 0) INTO v_last_id FROM MEMBERSHIP;

    -- Create the sequence starting at the next available ID
    EXECUTE IMMEDIATE 'CREATE SEQUENCE MEMBERSHIP_SEQ START WITH ' || (v_last_id + 1) || ' INCREMENT BY 1 CACHE 20';
END;
/

-- Customer_member_id sequence

DECLARE
    v_max_id NUMBER;
BEGIN
    -- Find the current maximum CUSTOMER_MEMBER_ID
    SELECT NVL(MAX(CUSTOMER_MEMBER_ID), 0)
    INTO v_max_id
    FROM CUSTOMER_MEMBERSHIP;

    -- Drop the existing sequence if it exists
    BEGIN
        EXECUTE IMMEDIATE 'DROP SEQUENCE CUSTOMER_MEMBERSHIP_SEQ';
    EXCEPTION
        WHEN OTHERS THEN
            NULL; -- Ignore if the sequence does not exist
    END;

    -- Create a new sequence starting after the maximum ID
    EXECUTE IMMEDIATE 'CREATE SEQUENCE CUSTOMER_MEMBERSHIP_SEQ START WITH ' || (v_max_id + 1) || ' INCREMENT BY 1';
END;
/