-- 1. Build out structural logical namespaces
\set ON_ERROR_STOP on
BEGIN;

-- This is acting as source system.
CREATE SCHEMA IF NOT EXISTS source_system;

-- this is landing area from source and cleanup with ETL.
CREATE SCHEMA IF NOT EXISTS staging;

-- This is the marts schema for snowflake reporting.
CREATE SCHEMA IF NOT EXISTS marts;

-- 2. Execute scripts relative to this file so Docker and host psql can both run it
\ir '01_source_system/Time_TB_RAW_TRANSACTION_DIMENSION.sql'
\ir '01_source_system/Time_TB_RAW_TRANSACTION_NUMBER.sql'
\ir '01_source_system/load_source_data.sql'

-- Staging tables
\ir '02_data_warehouse/02_staging/Narathip_stg_dimension.sql'
\ir '02_data_warehouse/02_staging/Narathip_stg_number.sql'

-- Rebuild mart tables so this setup also upgrades an existing database.
-- Source tables are not dropped; their source CSVs were loaded above.
DROP VIEW IF EXISTS marts.vw_sales_analytics;
DROP TABLE IF EXISTS marts.fact_sales;
DROP TABLE IF EXISTS marts.dim_area;
DROP TABLE IF EXISTS marts.dim_product_type;
DROP TABLE IF EXISTS marts.dim_sales_channel;
DROP TABLE IF EXISTS marts.dim_order_date;

-- Marts
\ir '02_data_warehouse/02_mart/Time_table_mart_example.sql'
\ir '02_data_warehouse/02_mart/Natthachaimongkol_mart.sql'
\ir '02_data_warehouse/02_mart/Natthachaimongkol_vw_sales_analytics.sql'

-- Existing staging example
\ir '02_data_warehouse/02_staging/Time_table_staging_example.sql'


-- 3. Execute operational code objects
\ir '03_procedure/Narathip_etl_dimension.sql'
\ir '03_procedure/Narathip_etl_number.sql'

\ir '03_procedure/Time_landing_procedure_example.sql'
\ir '03_procedure/Natthachaimongkol_sp_dimension.sql'
\ir '03_procedure/Natthachaimongkol_sp_fact.sql'

-- Populate the cleaned staging tables and the mart.
CALL staging.etl_transaction_dimension();
CALL staging.etl_transaction_number();
CALL marts.sp_populate_dimensions();
CALL marts.sp_populate_fact_sales();

COMMIT;