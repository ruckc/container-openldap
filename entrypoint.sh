#!/bin/bash

if [ ! -f "/data/.initialized" ]; then
  /scripts/setup.sh
fi
exec /scripts/start.sh
