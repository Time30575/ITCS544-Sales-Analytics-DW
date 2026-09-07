# Team Database Sync Guide

Every time you pull changes from the `main` branch, run these commands inside your built-in VS Code terminal to sync your local Docker Postgres database with the team's latest SQL updates.

### 1. to startup docker
```bash
docker compose up -d
```

### 1.5.1 Run only once! When you just start docker-postgres first time, after first time the table data is there in postgres eventhough you just restart docker.
```bash
docker exec -i Sales_analytics_wh psql -U admin -d Sales_analytics -v ON_ERROR_STOP=1 -f /docker-entrypoint-initdb.d/scripts/init_all.sql
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
### 2.2 check table : all are in psql
\dt source_system.*
\dt landing.*
\dt staging.*
\dt marts.*

#### 2.3 quit psql
\q


### 3. develop your SQL object in each .sql file

### 4. test your .sql change
```bash
docker exec -i Sales_analytics_wh psql -U admin -d Sales_analytics `
-v ON_ERROR_STOP=1 `
-f /docker-entrypoint-initdb.d/scripts/YOUR_CHANGED_FILE_NAME.sql
```



Individual procedure call : Run this command to call the procedure, do change procedure name:
```bash
docker exec -it Sales_analytics_wh psql -U admin -d Sales_analytics -c "CALL landing.prc_load_source_to_landing();"
```

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
docker compose down -d
```

### to stop container, and delete the data (volume), this will remove everything !!
```bash
docker compose down -v
```