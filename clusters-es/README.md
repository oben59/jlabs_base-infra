# ES Clusters Notes


### Some remaining manual ops

#### Grafana : Add data source :
* Name : ES
* Type : Prometheus
* Http setings : Url : http://localhost:9090
* Http setings : Access : proxy

#### Grafana : Add alerting notification channels :

##### for Slack :
* Name : team-devops-slack-channel
* Type : Slack
* Send on all alerts : []
* Include image : []
* Url : https://hooks.slack.com/services/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
* Recipient : #team-devops
* Mention : @channel @[team]-[env]

##### for Mails :
* Name : team-devops-email-channel
* Type : Email
* Send on all alerts : [x]
* Include image : [x]
* Email addresses : dev@[team].com

#### Grafana : Dashboards to import (Upload JSON) :
* libs/grafana/es-clusters.json
* libs/grafana/es-clusters-alerts.json



### Some usefull links
* [Ansible : Prometheus NodeExporter](https://github.com/prometheus/node_exporter)
* [Ansible : ES Prometheus Exporter](https://github.com/vvanholl/elasticsearch-prometheus-exporter)
* [Ansible : Rolling upgrade d'un autoscaling group AWS](http://blog.wescale.fr/2016/08/31/ansibled-rolling-upgrade-dun-autoscaling-group-aws/)
* [ES : Dev vs Prod](https://www.elastic.co/guide/en/elasticsearch/reference/current/system-config.html#dev-vs-prod)
* [ES : Memory Lock](https://www.elastic.co/guide/en/elasticsearch/reference/current/setup-configuration-memory.html#mlockall)



### Some commands to test the limits of the infrastructure
* Test CPU Usage : `stress -c 2 -t 180`
* Test Memory Usage : `stress --vm-bytes $(awk '/MemFree/{printf "%d\n", $2 * 0.9;}' < /proc/meminfo)k --vm-keep -m 1`
* Test Disk Usage : `wget https://cdimage.debian.org/debian-cd/current/amd64/iso-dvd/debian-9.1.0-amd64-DVD-1.iso`



### ES Cluster : Rolling Upgrade Process (duration: ~3h)
* make a snapshot before the process
* modify tf params with new instances types & hd sizes (+1 extra instance)
* (check the tfstate on S3 to know the instances to be tainted)
* ansible-playbook plays/build/build.yml -e layer_name=04-elasticsearch
* ansible-playbook plays/maintain/seed_check.yml -e target=es-instance-worker-3
* ansible-playbook plays/build/apply_es_cluster.yml
* ansible-playbook plays/maintain/check_es_installed.yml -e target=es_instances

* ./taint_resources.sh pp 04-elasticsearch aws_instance.es-instance-workers 0
* ansible-playbook plays/build/build.yml -e layer_name=04-elasticsearch
* ansible-playbook plays/maintain/seed_check.yml -e target=es-instance-worker-0
* ansible-playbook plays/build/apply_es_cluster.yml
* ansible-playbook plays/maintain/check_es_installed.yml -e target=es_instances
* (wait that cluster status returns to green.. ~15mn)

* ./taint_resources.sh pp 04-elasticsearch aws_instance.es-instance-workers 1
* ansible-playbook plays/build/build.yml -e layer_name=04-elasticsearch
* ansible-playbook plays/maintain/seed_check.yml -e target=es-instance-worker-1
* ansible-playbook plays/build/apply_es_cluster.yml
* ansible-playbook plays/maintain/check_es_installed.yml -e target=es_instances
* (wait that cluster status returns to green.. ~15mn)

* ./taint_resources.sh pp 04-elasticsearch aws_instance.es-instance-workers 2
* ansible-playbook plays/build/build.yml -e layer_name=04-elasticsearch
* ansible-playbook plays/maintain/seed_check.yml -e target=es-instance-worker-2
* ansible-playbook plays/build/apply_es_cluster.yml
* ansible-playbook plays/maintain/check_es_installed.yml -e target=es_instances
* (wait that cluster status returns to green.. ~15mn)

* /!\ remove the extra instance, by resetting the original nb of instances
* ./taint_resources.sh pp 04-elasticsearch aws_instance.es-instance-workers 2
* ansible-playbook plays/build/build.yml -e layer_name=04-elasticsearch
* ansible-playbook plays/maintain/check_es_installed.yml -e target=es_instances

* ansible-playbook plays/build/apply_monitoring.yml --tags=agents
* ansible-playbook plays/build/apply_monitoring_es.yml -e target=es_instances
