#!/usr/bin/env bash

set -e

service php8.3-fpm restart
service nginx start

exec tail --follow /var/www/logs/access.log /var/www/logs/error.log
