#!/usr/bin/env bash

set -e

while true; do
    case "$1" in
    --provider)
        provider=$2
        shift 2 ;;
    --env)
        env=$2
        shift 2 ;;
    '')
        break;;
    *)
        echo "Invalid argument $1";
        exit 1
  esac
done

layersDir=./providers/$provider/terraform

for layer in $(ls "$layersDir"); do
    make tf-apply-$provider-$env LAYER=$layer
done

./scripts/clean.sh
