### startup docker
```bash
docker compose up -d
```


# Team Database Sync Guide

Every time you pull changes from the `main` branch, run these commands inside your built-in VS Code terminal to sync your local Docker Postgres database with the team's latest SQL updates.

### The One-Line Sync : recreate everything
Run this single command to execute the master script inside your Docker container:
```bash
docker exec -i team_data_warehouse psql -U warehouse_user -d analytics_db -f /docker-entrypoint-initdb.d/scripts/init_all.sql
```

Run this command to call the procedure, do change procedure name:
```bash
docker exec -it team_data_warehouse psql -U warehouse_user -d analytics_db -c "CALL landing.prc_load_source_to_landing();"
```