# Team Database Sync Guide

Every time you pull changes from the `main` branch, run these commands inside your built-in VS Code terminal to sync your local Docker Postgres database with the team's latest SQL updates.

### 1. to startup docker

```bash
docker compose up -d
```

### 1.5.1 Initialize or rebuild the complete database

This is the single setup script. It loads the dirty CSV prefixes plus the remaining rows from `5m Sales Records.csv`, rebuilds the mart tables, and populates staging and mart data. The 5M CSV is intentionally excluded from Git because it exceeds GitHub's regular file limit; place that file in `database/01_source_system/5m Sales Records.csv` before running setup. The temporary import table reads all columns from the combined CSV, but only the existing dimension and number columns are inserted into the raw tables. Re-running it replaces source rows with the CSV contents and drops/recreates mart tables; back up any database data you need to keep first.

```bash
docker exec -i Sales_analytics_wh psql -U admin -d Sales_analytics -v ON_ERROR_STOP=1 -f /docker-entrypoint-initdb.d/init_all.sql
```

PostgreSQL also runs it automatically when `postgres_data` is created for the first time. The area dimension tracks each country's region assignment with effective dates. The fact grain is one row per source transaction record: generated source row IDs preserve all five million records even though `Order ID` is not unique in the data.

### 1.5.2 Reload all source CSV files after a CSV update
```bash
docker exec -i Sales_analytics_wh psql -U admin -d Sales_analytics `
-v ON_ERROR_STOP=1 `
-f /docker-entrypoint-initdb.d/01_source_system/load_source_data.sql
```

The reload script truncates both source tables before loading, then combines 1,048,575 dirty-file records with rows 1,048,576 through 5,000,000 from the combined CSV. It expects the dirty files to match the beginning of the combined CSV by `Order ID`. It assigns matching generated source row IDs to the dimension and number sides so repeated order IDs do not multiply fact rows. It is safe to rerun when you intend to replace the raw source data with those files.

### 2. Run these command to verify database connection (it will launch psql in your terminal)
```bash
docker exec -it Sales_analytics_wh psql -U admin -d Sales_analytics
```

### inside psql, can just skip by "\q" ###
### 2.1 check schema
```psql
\dn
```
### 2.2 check schema : all are in psql
\dt source_system.*
\dt staging.*
\dt marts.*

#### 2.3 quit psql
\q


### 3. develop your SQL object in each .sql file

### 3.5 Name your file with nickname_Table_name.sql but in the code you can keep only Table name as uaual.
### for example : Time_table_raw_1.sql --> but in code : "CREATE TABLE IF NOT EXISTS source_system.table_raw_1"

### 4. test your .sql change
```bash
docker exec -i Sales_analytics_wh psql -U admin -d Sales_analytics `
-v ON_ERROR_STOP=1 `
-f /docker-entrypoint-initdb.d/YOUR_CHANGED_FILE_NAME.sql
```

### 5. Go to pgadmin page for UI interface and SQL code execution friendly
``` Open in Browser
http://localhost:5050

ID = admin@local.com

PASSWORD = admin123456
```

### 6. Query : call the procedure and validate your query in pgadmin sql editor.

### 7. Done with result. go to init_all.sql --> go to --2 section
add your .sql object in this FORMAT
```
\ir 'folder/folder/nickname_Table_name.sql'
```
Example : \ir '01_source_system/create_source_tables.sql'


### 8. Start Apache Superset for dashboards

Start the services with `docker compose up -d`, then open
`http://localhost:8088` and sign in with your existing Superset account.

If the warehouse connection has not been added yet, create a PostgreSQL
connection in **Settings → Database Connections** using:

- **Host:** `local_postgres`
- **Port:** `5432`
- **Database:** `POSTGRES_DB` from `.env`
- **Username / password:** `POSTGRES_USER` and `POSTGRES_PASSWORD` from `.env`

Use the `marts` schema when adding datasets. The pgAdmin login is not the
PostgreSQL database login.