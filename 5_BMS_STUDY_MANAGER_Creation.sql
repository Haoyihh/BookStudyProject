SET SERVEROUTPUT ON;

DECLARE
    user_exists NUMBER;
BEGIN
    -- Check if the user exists
    SELECT COUNT(*)
    INTO user_exists
    FROM all_users
    WHERE username = 'STUDY_MANAGER';

    -- Drop the user if it exists
    IF user_exists > 0 THEN
        EXECUTE IMMEDIATE 'DROP USER STUDY_MANAGER CASCADE';
        DBMS_OUTPUT.PUT_LINE('USER STUDY_MANAGER DROPPED SUCCESSFULLY.');
    END IF;

    -- Create the user with a password
    EXECUTE IMMEDIATE 'CREATE USER STUDY_MANAGER IDENTIFIED BY "BookmystudyManager4#"';

    -- Grant basic privileges
    EXECUTE IMMEDIATE 'GRANT CONNECT TO STUDY_MANAGER';
    EXECUTE IMMEDIATE 'GRANT CREATE SESSION TO STUDY_MANAGER';

    -- Grant execute privilege on all packages, procedures, and functions owned by STUDY_ADMIN
    BEGIN
        FOR rec IN (
            SELECT object_name
            FROM all_objects
            WHERE object_type IN ('PACKAGE', 'PROCEDURE', 'FUNCTION')
              AND owner = 'STUDY_ADMIN' -- Updated to reflect the schema name
        ) LOOP
            EXECUTE IMMEDIATE 'GRANT EXECUTE ON STUDY_ADMIN.' || rec.object_name || ' TO STUDY_MANAGER';
        END LOOP;
    END;

    -- Grant access to necessary tables for data manipulation
    EXECUTE IMMEDIATE 'GRANT SELECT ON STUDY_ADMIN.CUSTOMER TO STUDY_MANAGER';
    EXECUTE IMMEDIATE 'GRANT SELECT ON STUDY_ADMIN.SPACE TO STUDY_MANAGER';
    EXECUTE IMMEDIATE 'GRANT SELECT ON STUDY_ADMIN.BOOKING TO STUDY_MANAGER';
    EXECUTE IMMEDIATE 'GRANT SELECT ON STUDY_ADMIN.REVIEW TO STUDY_MANAGER';
    EXECUTE IMMEDIATE 'GRANT SELECT ON STUDY_ADMIN.MEMBERSHIP TO STUDY_MANAGER';
    EXECUTE IMMEDIATE 'GRANT EXECUTE ON STUDY_ADMIN.CUSTOMER_MANAGEMENT TO STUDY_MANAGER';
    EXECUTE IMMEDIATE 'GRANT EXECUTE ON STUDY_ADMIN.SPACE_BOOKING_PKG TO STUDY_MANAGER';

    -- Grant unlimited quota on default and temporary tablespaces
    EXECUTE IMMEDIATE 'ALTER USER STUDY_MANAGER DEFAULT TABLESPACE users QUOTA UNLIMITED ON users';
    DBMS_OUTPUT.PUT_LINE('USER STUDY_MANAGER created and granted the specified privileges successfully.');

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Something went wrong: ' || SQLERRM);
END;
/
