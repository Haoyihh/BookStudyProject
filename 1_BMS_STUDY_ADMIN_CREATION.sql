--Login as Admin user from SQL Developer and run below commands to create STUDY_ADMIN
--EXECUTION ORDER : 1
--Execute using Oracle Admin account login

 
SET SERVEROUTPUT ON;

DECLARE
    user_exists NUMBER;
BEGIN
    -- Check if the user exists
    SELECT COUNT(*)
    INTO user_exists
    FROM all_users
    WHERE username = 'STUDY_ADMIN';
    
    --DROP the user if it exists
    IF user_exists > 0 THEN
     EXECUTE IMMEDIATE 'DROP USER STUDY_ADMIN CASCADE';
     DBMS_OUTPUT.PUT_LINE('USER STUDY_ADMIN DROPPED SUCCESSFULLY.');
    END IF;
    

    -- Create the user with a password 
    EXECUTE IMMEDIATE 'CREATE USER STUDY_ADMIN IDENTIFIED BY "Bookmystudy4#"';


    EXECUTE IMMEDIATE 'GRANT CONNECT, RESOURCE TO STUDY_ADMIN WITH ADMIN OPTION';
    
    -- Grant basic system privileges
    EXECUTE IMMEDIATE 'GRANT CREATE SESSION TO STUDY_ADMIN WITH ADMIN OPTION';

    --Grant object creation privileges
    EXECUTE IMMEDIATE 'GRANT CREATE VIEW, CREATE TABLE, CREATE SEQUENCE,CREATE SYNONYM TO STUDY_ADMIN';  

    --Grant user management privileges
    EXECUTE IMMEDIATE 'GRANT CREATE USER, ALTER USER, DROP USER TO STUDY_ADMIN';

    --Grant unlimited storage quota on the Data 
    EXECUTE IMMEDIATE 'ALTER USER STUDY_ADMIN DEFAULT TABLESPACE users QUOTA UNLIMITED ON data';
    DBMS_OUTPUT.PUT_LINE('USER STUDY_ADMIN created and granted the specified privileges successfully.');


EXCEPTION
    WHEN OTHERS THEN
       DBMS_OUTPUT.PUT_LINE('Something went wrong! Try again. ');
        
END;

