#!/usr/bin/bash

set -eoux pipefail

rm -rf /tmp/* || true

ostree container commit
