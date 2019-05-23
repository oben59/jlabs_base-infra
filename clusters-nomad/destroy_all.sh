#!/bin/bash

while true; do
    read -p "Are you sure ?.. [y/n] " yn
    case $yn in
        [Yy]* )
            for step in 05-entrypoints 04-nomad-workers 03-nomad-masters 02-monitoring 01-logstore 01-access-rights; do
                echo "------------------------------------------------------------------------------------------------------------"
                echo "-- Destroy Layer : $step"
                echo "------------------------------------------------------------------------------------------------------------"
                ansible-playbook plays/destroy/destroy.yml -e layer_name=$step -e auto_apply=true #-vvv
            done
            break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

# (/!\ then, remove all consul secrets)
# rm -rf ../secrets/jlabs-pp-ctn-eu-west-1/consul/tls/* (Y)

