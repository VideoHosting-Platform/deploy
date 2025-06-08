#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

### Конфигурация порт-форвардинга
declare -A PORT_FORWARD_COMMANDS=(
  # GUI
#   [loki-grafana]="kubectl port-forward svc/loki-grafana 3100:80"
  [rabbitmq-ui]="kubectl port-forward  -n messaging svc/rabbitmq 15672:15672"
  [minio-ui]="kubectl port-forward -n minio services/minio 9000:9000"
  # CLI/API
  [rabbitmq-api]="kubectl port-forward -n messaging svc/rabbitmq 5672:5672"
  [minio-api]="kubectl port-forward -n minio  svc/minio-console 9001:9001"
)

LOG_DIR="./logs"
mkdir -p "$LOG_DIR"

PIDS=()

### Функция для запуска порта
start_port_forward() {
  local name=$1
  local cmd=${PORT_FORWARD_COMMANDS[$name]}

  echo "[START] $name -> $cmd"
  # перенаправляем stdout/stderr в логи
  eval "$cmd" > "$LOG_DIR/$name.out" 2> "$LOG_DIR/$name.err" &
  PIDS+=($!)
}

### Функция для остановки всех форвардингов
cleanup() {
  echo
  echo "=== Stopping port-forward processes ==="
  for pid in "${PIDS[@]}"; do
    if kill -0 "$pid" &>/dev/null; then
      echo "Killing PID $pid"
      kill "$pid"
    fi
  done
  exit 0
}

# Натрапливаемся на выход и убиваем всех детей (o_O)
trap cleanup SIGINT SIGTERM EXIT

echo "=== Starting port forwarding for local development ==="

# Запускаем web-GUI
for svc in rabbitmq-ui minio-ui; do
  start_port_forward "$svc"
done

# Ожидаем пару секунд, чтобы сервисы запустились
sleep 2

# Запускаем CLI/API
for svc in rabbitmq-api minio-api; do
  start_port_forward "$svc"
done

echo
echo "=== Port forwarding processes started: ${PIDS[*]} ==="
echo "Логи можно посмотреть в $LOG_DIR/"

### Открываем в браузере (Linux/macOS)
open_url() {
  local url=$1
  if command -v xdg-open &>/dev/null; then
    xdg-open "$url"
  elif command -v open &>/dev/null; then
    open "$url"
  else
    echo "Please open in browser: $url"
  fi
}

echo
echo "=== Открываем GUI в браузере ==="
open_url "http://localhost:9000"  # MinIO UI
open_url "http://localhost:15672" # RabbitMQ UI

### Переменные окружения для приложений
echo
echo "=== Environment variables ==="

export MINIO_HOST=localhost
export MINIO_PORT=9000
export MINIO_BUCKET_NAME="videos"
export MINIO_ACCESS_KEY="minioadmin"
export MINIO_SECRET_KEY="minioadmin"


export RABBITMQ_HOST=localhost
export RABBITMQ_PORT=5672
export RABBITMQ_USER="user"
export RABBITMQ_PASSWORD="password"

export RABBITMQ_CONSUMER_NAME="video_processing"
export RABBITMQ_PRODUCER_NAME="db_upload"

export RABBITMQ_HOST=localhost
export RABBITMQ_AMQP_PORT=5672
export RABBITMQ_HTTP_PORT=15672
export RABBITMQ_HTTP_PORT=15672
export MINIO_ENDPOINT=localhost:9000
export MINIO_ACCESS_KEY="minioadmin"
export MINIO_SECRET_KEY="minioadmin"

cat <<EOF
# Используйте эти переменные в вашем приложении:
rabbitmq:
    host: $RABBITMQ_HOST
    port: $RABBITMQ_PORT
    user: $RABBITMQ_USER
    password: $RABBITMQ_PASSWORD

minio:
    host: $MINIO_HOST
    port: $MINIO_PORT
    access_key: $MINIO_ACCESS_KEY
    secret_key: $MINIO_SECRET_KEY
    bucket_name: $MINIO_BUCKET_NAME

web ui:
    minio: http://localhost:9000
    rabbitmq: http://localhost:15672
EOF

# Ждём сигналов, чтобы не завершить скрипт сразу
echo "=== Press Ctrl+C to stop port forwarding ==="
wait
