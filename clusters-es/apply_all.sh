#!/bin/bash

while true; do
    read -p "Are you sure ?.. [y/n] " yn
    case $yn in
        [Yy]* )
            for step in 01-landscape 02-bastion 03-elasticsearch 04-monitoring; do
                echo "------------------------------------------------------------------------------------------------------------"
                echo "- Apply Layer : $step"
                echo "------------------------------------------------------------------------------------------------------------"
                ansible-playbook plays/apply/apply.yml -e layer_name=$step -e auto_apply=true #-vvv
                sleep 60
            done

            echo "waits than seed scripts are installed.."
            sleep 180

            echo "------------------------------------------------------------------------------------------------------------"
            echo "- Playbook : Apply ES Cluster"
            echo "------------------------------------------------------------------------------------------------------------"
            ansible-playbook plays/apply/apply_es_cluster.yml
            ansible-playbook plays/apply/attach_es_snapshots.yml -e cluster_alias=es

            echo "------------------------------------------------------------------------------------------------------------"
            echo "- Playbook : Apply Monitoring & others"
            echo "------------------------------------------------------------------------------------------------------------"
            ansible-playbook plays/apply/apply_logrotate_es.yml
            ansible-playbook plays/apply/apply_monitoring.yml
            ansible-playbook plays/apply/apply_monitoring_es.yml

            break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
