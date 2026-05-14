#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCHEDULE="${1:-17 8 * * *}"
MARKER_BEGIN="# contacts-sync-work begin"
MARKER_END="# contacts-sync-work end"
ENTRY="$SCHEDULE CONTACTS_SYNC_REPO_DIR=$REPO_DIR $REPO_DIR/scripts/run-sync.sh"

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

crontab -l 2>/dev/null | sed "/^$MARKER_BEGIN$/,/^$MARKER_END$/d" > "$tmp" || true
{
  cat "$tmp"
  echo "$MARKER_BEGIN"
  echo "$ENTRY"
  echo "$MARKER_END"
} | crontab -

echo "Installed daily cron entry:"
echo "$ENTRY"
