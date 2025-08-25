#!/bin/sh

getent hosts $HOSTNAME
printf "Hostname: %s\n" "$(hostname)"
printf "env:\n%s\n" "$(env | sort)"

/app/bin/my_system start
