#!/bin/bash
# One-time SHUTDOWN scheduler for macOS Shortcuts/CLI
# Usage:
#   schedule-shutdown.sh "<time>" [--exact]
# Time can be 12h or 24h: "11:25 PM" | "7pm" | "07:05 pm" | "23:12" | "7:05"
# --exact disables the default 10-minute pmset grace compensation.

set -euo pipefail

GRACE_MINUTES_DEFAULT=10   # subtract this so shutdown occurs at user-entered time

trim() {
  printf "%s" "$1" | tr -d '\r\n\t' | sed -E 's/：/:/g; s/^[[:space:]]+|[[:space:]]+$//g'
}
lower() { printf "%s" "$1" | tr '[:upper:]' '[:lower:]'; }

raw="$(trim "${1:-}")"
flag="$(lower "${2:-}")"

if [[ -z "$raw" ]]; then
  echo "Usage: $0 \"<time>\" [--exact]" >&2
  exit 2
fi

parse_to_24h() {
  local s="$1" out=""
  for fmt in "%I:%M %p" "%I:%M%p" "%I %p" "%I%p" "%H:%M"; do
    out="$(date -j -f "$fmt" "$s" +%H:%M 2>/dev/null || true)"
    [[ -n "$out" ]] && { printf "%s" "$out"; return; }
  done
  if [[ "$s" =~ ^([0-1]?[0-9]|2[0-3])$ ]]; then
    printf "%02d:00" "${BASH_REMATCH[1]}"; return
  fi
  printf ""
}

HHMM="$(parse_to_24h "$raw")"
if [[ -z "$HHMM" ]]; then
  echo "Could not parse time. Try '11:25 PM', '7pm', or '23:25'." >&2
  exit 2
fi

today="$(date +%m/%d/%y)"
targetToday="$today $HHMM:00"
targetSec=$(date -j -f "%m/%d/%y %H:%M:%S" "$targetToday" +%s)
nowSec=$(date +%s)

if [[ "$targetSec" -le "$nowSec" ]]; then
  intendedStamp="$(date -v+1d -j -f "%H:%M:%S" "$HHMM:00" +"%m/%d/%y %H:%M:%S")"
else
  intendedStamp="$targetToday"
fi

compMin="$GRACE_MINUTES_DEFAULT"
[[ "$flag" == "--exact" ]] && compMin=0

pmsetStamp="$(date -v-"$compMin"M -j -f "%m/%d/%y %H:%M:%S" "$intendedStamp" +"%m/%d/%y %H:%M:%S")"
pmsetSec=$(date -j -f "%m/%d/%y %H:%M:%S" "$pmsetStamp" +%s)

# Guard: if the compensation makes it earlier than now, clamp to now+60s
if [[ "$pmsetSec" -le "$nowSec" ]]; then
  pmsetStamp="$(date -v+60S +"%m/%d/%y %H:%M:%S")"
fi

# Requires sudoers allowing /usr/bin/pmset (see README)
sudo -n /usr/bin/pmset schedule shutdown "$pmsetStamp"

# Two-line output (tab before pmset time). Friendly for Shortcuts notifications too.
printf "Shutdown: %s\npmset:\t%s\n" "$intendedStamp" "$pmsetStamp"

