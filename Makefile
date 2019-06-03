.DEFAULT_GOAL:=help
SHELL:=/bin/bash

OWNER=jlabs
REGION=eu-west-1

help:
	$(info e.g. "make tf-plan-pp LAYER_PATH=001-vpc" )

tf-init:
	cd aws/terraform/$(LAYER_PATH)/; \
	terraform init \
		-backend-config "region=$(REGION)" \
		-backend-config "dynamodb_table=$(OWNER)-$(ENV)-$(REGION)-tfstate-lock" \
		-backend-config "bucket=$(OWNER)-$(ENV)-$(REGION)-tfstate" \
		-backend-config "key=$(LAYER_PATH).tfstate" \
		-force-copy

tf-plan: tf-init
	cd aws/terraform/$(LAYER_PATH)/; \
	terraform plan -var-file ../../configs/$(OWNER)-$(ENV)-aws-$(LAYER_PATH).tfvars

tf-apply: tf-init
	cd aws/terraform/$(LAYER_PATH)/; \
	terraform apply -var-file ../../configs/$(OWNER)-$(ENV)-aws-$(LAYER_PATH).tfvars

tf-destroy: tf-init
	cd aws/terraform/$(LAYER_PATH)/; \
	terraform destroy -var-file ../../configs/$(OWNER)-$(ENV)-aws-$(LAYER_PATH).tfvars

tf-plan-pp: ENV=pp
tf-plan-pp: tf-plan

tf-apply-pp: ENV=pp
tf-apply-pp: tf-apply

tf-destroy-pp: ENV=pp
tf-destroy-pp: tf-destroy
