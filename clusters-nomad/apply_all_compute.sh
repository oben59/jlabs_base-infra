#!/bin/bash

while true; do
    read -p "Are you sure ?.. [y/n] " yn
    case $yn in
        [Yy]* )

            ansible-playbook plays/apply/apply_logstore.yml
            ansible-playbook plays/apply/apply_monitoring.yml
            ansible-playbook plays/apply/apply_entry.yml

            ansible-playbook plays/apply/apply_nomad_masters.yml
            ansible-playbook plays/apply/apply_nomad_workers.yml

            ansible-playbook plays/maintain/vault_push_config.yml
            ansible-playbook plays/maintain/nomad_push_jobs.yml
            ansible-playbook plays/maintain/nomad_run_jobs.yml

            break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
