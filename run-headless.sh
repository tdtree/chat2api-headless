#!/bin/bash
# Chat2API Headless Server Launcher
# Uses xvfb-run to provide virtual display for Electron

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_FILE="/tmp/chat2api-headless.log"
PID_FILE="/tmp/chat2api-headless.pid"

start() {
  if [ -f "$PID_FILE" ] && kill -0 $(cat "$PID_FILE") 2>/dev/null; then
    echo "Chat2API is already running (PID: $(cat $PID_FILE))"
    exit 1
  fi

  mkdir -p "$PROJECT_DIR/out/main"
  cp "$PROJECT_DIR/sha3_wasm_bg.7b9ca65ddd.wasm" "$PROJECT_DIR/out/main/" 2>/dev/null

  nohup xvfb-run -a "$PROJECT_DIR/node_modules/.bin/electron" \
    "$PROJECT_DIR/out/main/headless.js" \
    --no-sandbox --disable-gpu --disable-software-rasterizer \
    > "$LOG_FILE" 2>&1 &
  PID=$!
  echo $PID > "$PID_FILE"

  sleep 5
  if kill -0 $PID 2>/dev/null; then
    echo "Chat2API proxy started (PID: $PID)"
    echo "Log: $LOG_FILE"
    echo "Health: curl http://localhost:6011/health"
  else
    echo "Failed to start Chat2API proxy"
    cat "$LOG_FILE"
    rm -f "$PID_FILE"
    exit 1
  fi
}

stop() {
  if [ -f "$PID_FILE" ]; then
    kill $(cat "$PID_FILE") 2>/dev/null
    rm -f "$PID_FILE"
    echo "Chat2API proxy stopped"
  else
    echo "Chat2API proxy is not running"
  fi
}

status() {
  if [ -f "$PID_FILE" ] && kill -0 $(cat "$PID_FILE") 2>/dev/null; then
    echo "Chat2API proxy is running (PID: $(cat $PID_FILE))"
    curl -s http://localhost:6011/health 2>/dev/null || echo "Health check failed"
  else
    echo "Chat2API proxy is not running"
  fi
}

case "${1:-start}" in
  start) start ;;
  stop) stop ;;
  restart) stop; sleep 1; start ;;
  status) status ;;
  *) echo "Usage: $0 {start|stop|restart|status}" ;;
esac
