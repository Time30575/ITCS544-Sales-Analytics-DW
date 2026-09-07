-- 1. Build out structural logical namespaces
CREATE SCHEMA IF NOT EXISTS source_system;
CREATE SCHEMA IF NOT EXISTS landing;
CREATE SCHEMA IF NOT EXISTS staging;
CREATE SCHEMA IF NOT EXISTS marts;

-- 2. Execute scripts relative to this file so Docker and host psql can both run it
\ir '01_source_system/create_source_tables.sql'
\ir '02_data_warehouse/01_landing.sql'
\ir '02_data_warehouse/02_staging.sql'
\ir '02_data_warehouse/03_mart.sql'

-- 3. Execute operational code objects
\ir '03_procedure/01_landing_procedure.sql'