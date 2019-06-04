.DEFAULT_GOAL:=help
SHELL:=/bin/bash

OWNER=jlabs
REGION=eu-west-1

help:
	$(info e.g. "make tf-plan-aws-pp LAYER_PATH=001-vpc" )

tf-init-aws:
	cd aws/terraform/$(LAYER_PATH)/; \
	terraform init \
		-backend-config "region=$(REGION)" \
		-backend-config "dynamodb_table=$(OWNER)-$(ENV)-$(REGION)-tfstate-lock" \
		-backend-config "bucket=$(OWNER)-$(ENV)-$(REGION)-tfstate" \
		-backend-config "key=$(LAYER_PATH).tfstate" \
		-force-copy

tf-plan-aws: tf-init-aws
	cd aws/terraform/$(LAYER_PATH)/; \
	terraform plan -var-file ../../configs/$(OWNER)-$(ENV)-aws-$(LAYER_PATH).tfvars

tf-apply-aws: tf-init-aws
	cd aws/terraform/$(LAYER_PATH)/; \
	terraform apply -var-file ../../configs/$(OWNER)-$(ENV)-aws-$(LAYER_PATH).tfvars -auto-approve

tf-destroy-aws: tf-init-aws
	cd aws/terraform/$(LAYER_PATH)/; \
	terraform destroy -var-file ../../configs/$(OWNER)-$(ENV)-aws-$(LAYER_PATH).tfvars -auto-approve

tf-plan-aws-pp: ENV=pp
tf-plan-aws-pp: tf-plan-aws

tf-apply-aws-pp: ENV=pp
tf-apply-aws-pp: tf-apply-aws

tf-destroy-aws-pp: ENV=pp
tf-destroy-aws-pp: tf-destroy-aws
