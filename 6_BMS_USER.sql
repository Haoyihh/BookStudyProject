SET SERVEROUTPUT ON;

DECLARE
    user_exists NUMBER;
BEGIN
    -- Check if the user exists
    SELECT COUNT(*)
    INTO user_exists
    FROM all_users
    WHERE username = 'BMS_USER';

    -- Drop the user if it exists
    IF user_exists > 0 THEN
        EXECUTE IMMEDIATE 'DROP USER BMS_USER CASCADE';
        DBMS_OUTPUT.PUT_LINE('USER BMS_USER DROPPED SUCCESSFULLY.');
    END IF;

    -- Create the user with a password
    EXECUTE IMMEDIATE 'CREATE USER BMS_USER IDENTIFIED BY "BookmystudyUser4#"';

    -- Grant basic privileges
    EXECUTE IMMEDIATE 'GRANT CONNECT TO BMS_USER';
    EXECUTE IMMEDIATE 'GRANT CREATE SESSION TO BMS_USER';

    -- Grant execute privilege on all packages, procedures, and functions owned by STUDY_ADMIN
    BEGIN
        FOR rec IN (
            SELECT object_name
            FROM all_objects
            WHERE object_type IN ('PACKAGE', 'PROCEDURE', 'FUNCTION')
              AND owner = 'STUDY_ADMIN' -- Updated to reflect the schema name
        ) LOOP
            EXECUTE IMMEDIATE 'GRANT EXECUTE ON STUDY_ADMIN.' || rec.object_name || ' TO BMS_USER';
        END LOOP;
    END;

    -- Grant access to necessary tables for data manipulation
    EXECUTE IMMEDIATE 'GRANT SELECT ON STUDY_ADMIN.CUSTOMER TO BMS_USER';
    EXECUTE IMMEDIATE 'GRANT SELECT ON STUDY_ADMIN.SPACE TO BMS_USER';
    EXECUTE IMMEDIATE 'GRANT SELECT ON STUDY_ADMIN.BOOKING TO BMS_USER';
    EXECUTE IMMEDIATE 'GRANT SELECT ON STUDY_ADMIN.REVIEW TO BMS_USER';
    EXECUTE IMMEDIATE 'GRANT SELECT ON STUDY_ADMIN.MEMBERSHIP TO BMS_USER';
    EXECUTE IMMEDIATE 'GRANT SELECT ON STUDY_ADMIN.CUSTOMER_MEMBERSHIP TO BMS_USER';
    EXECUTE IMMEDIATE 'GRANT SELECT ON STUDY_ADMIN.PAYMENT TO BMS_USER';
    EXECUTE IMMEDIATE 'GRANT EXECUTE ON STUDY_ADMIN.SPACE_BOOKING_PKG TO BMS_USER';
    

    -- Grant unlimited quota on default and temporary tablespaces
    EXECUTE IMMEDIATE 'ALTER USER BMS_USER DEFAULT TABLESPACE users QUOTA UNLIMITED ON users';
    DBMS_OUTPUT.PUT_LINE('USER BMS_USER created and granted the specified privileges successfully.');

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Something went wrong: ' || SQLERRM);
END;
/