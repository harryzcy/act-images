#!/bin/bash

# Mirrors sometimes serve an index whose pool files aren't synced yet (404).
# apt's Acquire::Retries doesn't cover those, so refresh the index and retry.
apt-get-retry() {
  local attempt=1
  until apt-get "$@"; do
    if [ "$attempt" -ge 3 ]; then
      echo "apt-get still failing after $attempt attempts: $*"
      return 1
    fi
    echo "apt-get failed (attempt $attempt), refreshing package index and retrying: $*"
    sleep $((attempt * 10))
    apt-get -qq update || true
    attempt=$((attempt + 1))
  done
}
