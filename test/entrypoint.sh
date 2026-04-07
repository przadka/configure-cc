#!/bin/bash
# Copy mounted credentials (root-owned) to user-owned location
if [ -f /tmp/credentials.json ]; then
  mkdir -p ~/.claude
  cp /tmp/credentials.json ~/.claude/.credentials.json
  echo "✓ Credentials loaded"
fi
exec claude
