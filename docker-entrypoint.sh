#!/bin/bash
set -e

cp /srv/ssl/* /mnt/certs

exec "$@"
