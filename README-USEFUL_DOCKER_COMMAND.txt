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