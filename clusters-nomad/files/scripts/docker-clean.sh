#!/bin/bash
LOGFILE="/root/scripts/docker-clean.log"

echo 'BEGIN @' | tee -a $LOGFILE
date | tee -a $LOGFILE

# Prune everything
docker system prune -f

# Remove aufs diffs
rm -rf /var/lib/docker/aufs/diff/*-removing

echo 'END @' | tee -a $LOGFILE
date | tee -a $LOGFILE
