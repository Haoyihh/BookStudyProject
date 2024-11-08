# Book My Study

##Objective

Welcome to the Book My Study (BMS) database setup guide. The project is to design and develop a robust database system to support a business that offers study place bookings, incorporating a variety of payment models and customer membership types. 

## Database Setup Steps

###Step 1: Login as Oracle Database Admin
Ensure you have Oracle Database Admin credentials. Login to your Oracle database to start setting up the Book My Study (BMS) database.

###Step 2: Create Database Users
STUDY_ADMIN Creation Script (1_BMS_STUDY_ADMIN_CREATION.sql): Creates the STUDY_ADMIN user with administrative permissions.

###Step 3: Connect as STUDY_ADMIN from SQL Developer
Utilize SQL Developer to connect to the database using the correct STUDY_ADMIN credentials.

###Step 4: Execute DDL Statements - Create Tables
DDL Creation Script (2_BMS_DDL_creation.sql): Execute DDL statements to create tables, ensuring to drop existing tables if necessary and to maintain the parent-child table hierarchy. Also, manage sequences accordingly.

###Step 5: Execute DML Statements - Insert Sample Records
DML Statements Script (3_BMS_DML_creation.sql): Insert sample records into the database using the STUDY_ADMIN user.

###Step 6: Create Views
View Creation Script (4_BMS_View_creation.sql): Define views for reporting and data access purposes, executing this script as STUDY_ADMIN.
