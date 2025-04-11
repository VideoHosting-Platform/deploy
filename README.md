Чтобы запустить всю инфраструктуру
```
docker compose -f infra.yaml up --build -d 
```

Чтобы запустить один сервис или несколько(например, minio)
```
docker compose -f infra.yaml up -d minio
```