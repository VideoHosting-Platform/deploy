HELM_RELEASE=video-hosting

### Конфигурация порт-форвардинга
declare -A PORT_FORWARD_COMMANDS=(
  # GUI
#   [loki-grafana]="kubectl port-forward svc/loki-grafana 3100:80"
  [rabbitmq-ui]="kubectl port-forward  svc/$HELM_RELEASE-rabbitmq 15672:15672"
  [minio-ui]="kubectl port-forward  svc/$HELM_RELEASE-minio-console 9090:9090"
  
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

for svc in rabbitmq-ui minio-ui; do
  start_port_forward "$svc"
done

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


echo "=== Открываем GUI в браузере ==="
open_url "http://localhost:9090"  # MinIO UI
open_url "http://localhost:15672" # RabbitMQ UI