#!/bin/bash
set -e

cp /srv/ssl/* /mnt/certs

set -- su-exec rabbitmq "$@"

exec "$@"
