#!/bin/sh
set -e

chmod -R 777 ./data
docker-compose up -d
