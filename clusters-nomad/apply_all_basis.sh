#!/bin/bash

while true; do
    read -p "Are you sure ?.. [y/n] " yn
    case $yn in
        [Yy]* )
            for step in 01-access-rights 01-logstore 02-monitoring 03-nomad-masters 04-nomad-workers 05-entrypoints; do
                echo "------------------------------------------------------------------------------------------------------------"
                echo "- Build Layer : $step"
                echo "------------------------------------------------------------------------------------------------------------"
                ansible-playbook plays/apply/apply.yml -e layer_name=$step -e auto_apply=true #-vvv
                sleep 60
            done

            # echo "waits than seed scripts are installed.."
            sleep 180

            ansible-playbook plays/apply/apply_consul.yml
            ansible-playbook plays/apply/apply_vault.yml
            ansible-playbook plays/maintain/vault_init.yml

            break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
