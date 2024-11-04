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
