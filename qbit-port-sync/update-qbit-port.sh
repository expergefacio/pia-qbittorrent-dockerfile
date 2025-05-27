#!/bin/bash

PORT_FILE="/pia-shared/port.dat"
QBIT_HOST="http://localhost:8080"
QBIT_USER="admin"
QBIT_PASS="adminadmin"
LAST_PORT=""

wait_for_qbit() {
  echo "[watchdog] Waiting for WebUI to listen..."

  for i in {1..60}; do
    if curl -4 -s -o /dev/null http://localhost:8080/; then
      echo "[watchdog] WebUI is listening!"
      return 0
    fi
    echo "[watchdog] ...still waiting ($i seconds)"
    sleep 1
  done

  echo "[watchdog] ERROR: WebUI never responded on port 8080"
  return 1
}


login() {
  curl -s --cookie-jar /tmp/cookies.txt \
       --data "username=$QBIT_USER&password=$QBIT_PASS" \
       "$QBIT_HOST/api/v2/auth/login" > /dev/null
}

set_port() {
  local PORT=$1
  echo "[watchdog] Attempting to set port: $PORT"

  login

  curl -s --cookie /tmp/cookies.txt \
       --data-urlencode "json={\"listen_port\":$PORT}" \
       "$QBIT_HOST/api/v2/app/setPreferences" > /dev/null

  local CONFIRMED_PORT=$(curl -s --cookie /tmp/cookies.txt "$QBIT_HOST/api/v2/app/preferences" \
    | tr ',' '\n' | grep '"listen_port"' | cut -d: -f2 | tr -d ' ')


  if [[ "$CONFIRMED_PORT" == "$PORT" ]]; then
    echo "[watchdog] ✅ Port set successfully to $PORT"
  else
    echo "[watchdog] ❌ Port change failed (current: $CONFIRMED_PORT)"
  fi
}

check_and_update() {
  if [[ ! -f "$PORT_FILE" ]]; then
    echo "[watchdog] No port file found yet"
    return
  fi

  NEW_PORT=$(cat "$PORT_FILE" | tr -d '\r\n')
  if [[ "$NEW_PORT" == "$LAST_PORT" || ! "$NEW_PORT" =~ ^[0-9]+$ ]]; then
    return
  fi

  echo "[watchdog] Detected new port: $NEW_PORT"
  LAST_PORT="$NEW_PORT"

  wait_for_qbit && set_port "$NEW_PORT"
}

# Run once at start
check_and_update

# Watch forever for changes
inotifywait -m -e close_write "$PORT_FILE" | while read -r _; do
  check_and_update
done