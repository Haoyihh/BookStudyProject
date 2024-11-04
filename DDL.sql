-- Login as Admin user from SQL Developer and run below commands

-- Begin block to drop the existing user if it exists
BEGIN
   -- Drop the user 'PROJECT' if it exists
   BEGIN
      EXECUTE IMMEDIATE 'DROP USER PROJECT CASCADE';
   EXCEPTION
      WHEN OTHERS THEN
         -- Ignore if user does not exist
         NULL;
   END;
END;
/
-- Create the new user with a secure password
CREATE USER PROJECT IDENTIFIED BY "BookmySpace#";

-- Set default tablespace and quota for the new user
ALTER USER PROJECT DEFAULT TABLESPACE users QUOTA UNLIMITED ON users;

-- Set temporary tablespace for the new user
ALTER USER PROJECT TEMPORARY TABLESPACE TEMP;

-- Grant basic connection and session privileges
GRANT CONNECT TO PROJECT;

-- Grant the necessary object and session creation privileges
GRANT CREATE SESSION, CREATE VIEW, CREATE TABLE, ALTER SESSION, CREATE SEQUENCE TO PROJECT;

-- Grant additional administrative and resource privileges
-- Grant only specific roles if needed. 'RESOURCE' is a broad privilege and includes unnecessary permissions.
GRANT CREATE SYNONYM, CREATE DATABASE LINK TO PROJECT;

-- Optionally, grant the 'UNLIMITED TABLESPACE' privilege
-- Use cautiously to avoid excessive resource usage by the user.
GRANT UNLIMITED TABLESPACE TO PROJECT;

-- End of script
/
