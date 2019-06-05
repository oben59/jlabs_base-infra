.DEFAULT_GOAL:=help
SHELL:=/bin/bash

OWNER=jlabs
REGION=eu-west-1
CONFIG_PATH=../../configs

help:
	$(info e.g. "make tf-plan-aws-pp LAYER=001-vpc" )


# aws terraform

tf-init-aws:
	cd aws/terraform/$(LAYER)/; \
	terraform init \
		-backend-config "region=$(REGION)" \
		-backend-config "dynamodb_table=$(OWNER)-$(ENV)-$(REGION)-tfstate-lock" \
		-backend-config "bucket=$(OWNER)-$(ENV)-$(REGION)-tfstate" \
		-backend-config "key=$(LAYER).tfstate" \
		-force-copy

tf-plan-aws: tf-init-aws
	cd aws/terraform/$(LAYER)/; \
	terraform plan \
		-var-file $(CONFIG_PATH)/$(OWNER)-$(ENV)/terraform/commons.tfvars \
		-var-file $(CONFIG_PATH)/$(OWNER)-$(ENV)/terraform/$(LAYER).tfvars

tf-apply-aws: tf-init-aws
	cd aws/terraform/$(LAYER)/; \
	terraform apply \
		-var-file $(CONFIG_PATH)/$(OWNER)-$(ENV)/terraform/commons.tfvars \
		-var-file $(CONFIG_PATH)/$(OWNER)-$(ENV)/terraform/$(LAYER).tfvars -auto-approve

tf-destroy-aws: tf-init-aws
	cd aws/terraform/$(LAYER)/; \
	terraform destroy \
		-var-file $(CONFIG_PATH)/$(OWNER)-$(ENV)/terraform/commons.tfvars \
		-var-file $(CONFIG_PATH)/$(OWNER)-$(ENV)/terraform/$(LAYER).tfvars -auto-approve

tf-plan-aws-pp: ENV=pp
tf-plan-aws-pp: tf-plan-aws

tf-apply-aws-pp: ENV=pp
tf-apply-aws-pp: tf-apply-aws

tf-destroy-aws-pp: ENV=pp
tf-destroy-aws-pp: tf-destroy-aws


# eks

eks-create:
	eksctl create cluster \
		-f ./aws/configs/$(OWNER)-$(ENV)/eks/cluster-vars.yml

eks-update:
	eksctl update cluster \
		-f ./aws/configs/$(OWNER)-$(ENV)/eks/cluster-vars.yml

eks-delete:
	eksctl delete cluster \
		-f ./aws/configs/$(OWNER)-$(ENV)/eks/cluster-vars.yml

eks-create-pp: ENV=pp
eks-create-pp: eks-create

eks-update-pp: ENV=pp
eks-update-pp: eks-create

eks-delete-pp: ENV=pp
eks-delete-pp: eks-create


# gke

# TODO
