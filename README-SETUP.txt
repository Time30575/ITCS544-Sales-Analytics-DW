# Team Database Sync Guide

Every time you pull changes from the `main` branch, run these commands inside your built-in VS Code terminal to sync your local Docker Postgres database with the team's latest SQL updates.

### 1. to startup docker
```bash
docker compose up -d
```

### 2. Run the master SQL script inside the current Docker container
```bash
docker exec -i Sales_analytics_wh psql -U admin -d Sales_analytics -v ON_ERROR_STOP=1 -f /docker-entrypoint-initdb.d/scripts/init_all.sql
```

### 3. Run these command to verify database connection (it will launch psql in your terminal)
```bash
docker exec -it Sales_analytics_wh psql -U admin -d Sales_analytics
```

### inside psql, can just skip by "\q" ###
### 3.1 check schema
```psql
\dn
```
### 3.2 check table : all are in psql
\dt source_system.*
\dt landing.*
\dt staging.*
\dt marts.*

#### 3.3 quit psql
\q



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

### to stop container
```bash
docker compose down -d
```