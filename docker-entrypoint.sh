#!/bin/bash
set -e

cp /srv/ssl/* /mnt/certs

exec "$@"

still_booting=1
while [ "$still_booting" -ne 0 ]
do
  curl http://localhost:15672/api/overview
  still_booting=$?
  sleep 1
done
