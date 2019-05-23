#!/bin/bash

while true; do
    read -p "Are you sure ?.. [y/n] " yn
    case $yn in
        [Yy]* )
            for step in 04-monitoring 03-elasticsearch 02-bastion 01-landscape; do
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
