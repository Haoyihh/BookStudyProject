-- Drop the 'CustomerBookingDetails' view if it exists
BEGIN
    FOR v IN (SELECT NULL FROM USER_VIEWS WHERE VIEW_NAME = 'CUSTOMERBOOKINGDETAILS') LOOP
        EXECUTE IMMEDIATE 'DROP VIEW CustomerBookingDetails';
    END LOOP;
EXCEPTION
    WHEN OTHERS THEN
        -- Handle exceptions if necessary
        NULL;
END;
/
