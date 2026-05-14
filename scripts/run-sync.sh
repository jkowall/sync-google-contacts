#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="${CONTACTS_SYNC_REPO_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
PYTHON="${CONTACTS_SYNC_PYTHON:-$REPO_DIR/.venv/bin/python}"
LOG_DIR="${CONTACTS_SYNC_LOG_DIR:-$HOME/.google/contacts-sync-logs}"
LOCK_FILE="${CONTACTS_SYNC_LOCK_FILE:-$HOME/.google/contacts-sync.lock}"

USER_1="${CONTACTS_SYNC_USER_1:-jkowall@gmail.com}"
USER_2="${CONTACTS_SYNC_USER_2:-jonahk@spacelift.io}"
CLIENT_SECRET_1="${CONTACTS_SYNC_CLIENT_SECRET_1:-$HOME/.google/authdata/gmail.json}"
CLIENT_SECRET_2="${CONTACTS_SYNC_CLIENT_SECRET_2:-$HOME/.google/authdata/spacelift.json}"

mkdir -p "$LOG_DIR" "$(dirname "$LOCK_FILE")"

timestamp="$(date -u +%Y%m%dT%H%M%SZ)"
log_file="$LOG_DIR/$timestamp.log"

cd "$REPO_DIR"

{
  echo "contacts-sync started at $timestamp"
  echo "repo: $REPO_DIR"
  echo "users: $USER_1 $USER_2"

  flock -n 9 || {
    echo "another contacts-sync run is already active"
    exit 75
  }

  "$PYTHON" "$REPO_DIR/contacts-sync.py" \
    --user "$USER_1" \
    --user "$USER_2" \
    --client-secret-for "$USER_1=$CLIENT_SECRET_1" \
    --client-secret-for "$USER_2=$CLIENT_SECRET_2"

  echo "contacts-sync finished at $(date -u +%Y%m%dT%H%M%SZ)"
} 9>"$LOCK_FILE" 2>&1 | tee "$log_file"
