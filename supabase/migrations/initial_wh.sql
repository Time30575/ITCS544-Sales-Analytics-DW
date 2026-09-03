-- This is acting source system, just dump raw csv to it
CREATE SCHEMA IF NOT EXIST SOURCE_SYSTEM;

--This is actual production WH
CREATE SCHEMA IF NOT EXIST RAW_STAGING;
CREATE SCHEMA IF NOT EXIST CURATED;
CREATE SCHEMA IF NOT EXIST MARTS;


-- Comment to document schema purposes in the database metadata
COMMENT ON SCHEMA SOURCE_SYSTEM IS 'Unmodified raw landing area for CSV and source file ingestion.';
COMMENT ON SCHEMA RAW_STAGING   IS 'Landing extract data from source to actual, No modify data ';
COMMENT ON SCHEMA CURATED       IS 'Cleaned data from Staging, ready to be used';
COMMENT ON SCHEMA MARTS         IS 'Data modeling, ready to use for report';