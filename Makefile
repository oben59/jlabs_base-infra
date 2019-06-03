SHELL := /bin/bash

OWNER=jlabs

tf-init:
  cd aws/terraform/$(LAYER_PATH)/
  terraform init

tf-plan:
  tf-init
  terraform plan -var-file ../../configs/$(OWNER)-$(ENV)-aws-$(LAYER_PATH).tfvars

tf-apply:
  tf-init
  terraform apply -var-file ../../configs/$(OWNER)-$(ENV)-aws-$(LAYER_PATH).tfvars

tf-destroy:
  tf-init
  terraform destroy -var-file ../../configs/$(OWNER)-$(ENV)-aws-$(LAYER_PATH).tfvars

tf-plan-pp:
  ENV=pp
  LAYER_PATH=001-vpc
  terraform plan -var-file ../../../configs/jlabs-pp-aws-vpc.tfvars

tf-apply-pp-001-vpc:

tf-destroy-pp-001-vpc:
