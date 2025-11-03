#!/bin/sh
set -e

export MS365_MCP_ORG_MODE="${MS365_MCP_ORG_MODE:-1}"
export MS365_MCP_CACHE_DIR="${MS365_MCP_CACHE_DIR:-/app/cache}"

mkdir -p "$MS365_MCP_CACHE_DIR"

if [ $# -eq 0 ]; then
  set -- node dist/index.js
elif [ "${1#-}" != "$1" ]; then
  set -- node dist/index.js "$@"
fi

exec "$@"
