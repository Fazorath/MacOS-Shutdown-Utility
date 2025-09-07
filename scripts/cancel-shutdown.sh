#!/bin/bash
# Cancel all scheduled pmset power events.
set -euo pipefail

sudo -n /usr/bin/pmset schedule cancelall
echo "All scheduled power events cleared."
