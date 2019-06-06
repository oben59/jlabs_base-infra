.DEFAULT_GOAL:=help
SHELL:=/bin/bash

OWNER=jlabs
REGION=eu-west-1
CONFIG_PATH=./../../../../config

help:
	$(info e.g. "make tf-plan-aws-pp LAYER=001-vpc" )

tf-init:
	cd ./providers/$(PROVIDER)/terraform/$(LAYER)/; \
	terraform init \
		-backend-config "region=$(REGION)" \
		-backend-config "dynamodb_table=$(OWNER)-$(ENV)-$(REGION)-tfstate-lock" \
		-backend-config "bucket=$(OWNER)-$(ENV)-$(REGION)-tfstate" \
		-backend-config "key=$(LAYER).tfstate" \
		-force-copy

tf-plan: tf-init
	cd ./providers/$(PROVIDER)/terraform/$(LAYER)/; \
	terraform plan \
		-var-file $(CONFIG_PATH)/$(OWNER)-$(ENV)-$(PROVIDER)-tf-$(LAYER).tfvars \
		-var-file $(CONFIG_PATH)/$(OWNER)-$(ENV)-$(PROVIDER)-tf.tfvars

tf-apply: tf-init
	cd ./providers/$(PROVIDER)/terraform/$(LAYER)/; \
	terraform apply \
		-var-file $(CONFIG_PATH)/$(OWNER)-$(ENV)-$(PROVIDER)-tf-$(LAYER).tfvars \
		-var-file $(CONFIG_PATH)/$(OWNER)-$(ENV)-$(PROVIDER)-tf.tfvars -auto-approve

tf-destroy: tf-init
	cd ./providers/$(PROVIDER)/terraform/$(LAYER)/; \
	terraform destroy \
		-var-file $(CONFIG_PATH)/$(OWNER)-$(ENV)-$(PROVIDER)-tf-$(LAYER).tfvars \
		-var-file $(CONFIG_PATH)/$(OWNER)-$(ENV)-$(PROVIDER)-tf.tfvars -auto-approve

eks-create:
	eksctl create cluster \
		-f ./config/$(OWNER)-$(ENV)-aws-eks.yml

eks-update:
	eksctl update cluster \
		-f ./config/$(OWNER)-$(ENV)-aws-eks.yml

eks-delete:
	eksctl delete cluster \
		-f ./config/$(OWNER)-$(ENV)-aws-eks.yml


tf-plan-aws-pp: PROVIDER=aws
tf-plan-aws-pp: ENV=pp
tf-plan-aws-pp: tf-plan

tf-apply-aws-pp: PROVIDER=aws
tf-apply-aws-pp: ENV=pp
tf-apply-aws-pp: tf-apply

tf-destroy-aws-pp: PROVIDER=aws
tf-destroy-aws-pp: ENV=pp
tf-destroy-aws-pp: tf-destroy

eks-create-pp: ENV=pp
eks-create-pp: eks-create

eks-update-pp: ENV=pp
eks-update-pp: eks-update

eks-delete-pp: ENV=pp
eks-delete-pp: eks-delete
