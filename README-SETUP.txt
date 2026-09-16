# Team Database Sync Guide

Every time you pull changes from the `main` branch, run these commands inside your built-in VS Code terminal to sync your local Docker Postgres database with the team's latest SQL updates.

### 1. to startup docker
```bash
docker compose up -d
```

### 1.5.1 Run only once! When you just start docker-postgres first time, after first time the table data is there in postgres eventhough you just restart docker.
```bash
docker exec -i Sales_analytics_wh psql -U admin -d Sales_analytics -v ON_ERROR_STOP=1 -f /docker-entrypoint-initdb.d/init_all.sql
```

### 1.5.2 reload raw csv if csv updated
```bash
Get-Content .\database\01_source_system\raw_transactions.csv -Raw |
docker exec -i Sales_analytics_wh psql -U admin -d Sales_analytics `
-v ON_ERROR_STOP=1 `
-c "BEGIN; TRUNCATE TABLE source_system.tb_raw_transaction; \copy source_system.tb_raw_transaction FROM STDIN WITH (FORMAT csv, HEADER true); COMMIT;"
```

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











### USEFUL DOCKER COMMAND ###
### to startup docker
```bash
docker compose up -d
```

### to see docker status
```bash
docker ps
```

### to verify database existing
```bash
docker exec -it Sales_analytics_wh psql -U admin -d Sales_analytics
```

### to stop container, but not delete the data (volume)
```bash
docker compose down
```

### to stop container, and delete the data (volume), this will remove everything !!
```bash
docker compose down -v
```

Individual procedure call : Run this command to call the procedure, do change procedure name:
```bash
docker exec -it Sales_analytics_wh psql -U admin -d Sales_analytics -c "CALL schema.your_procedure();"
```