#!/bin/bash
set -e

function start {
  # executed when container is run
  bundle exec whenever --update-crontab --set environment=staging
}

if [ "$1" == "/sbin/my_init" ]; then
  start
fi

exec "$@"
