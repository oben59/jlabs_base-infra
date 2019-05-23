# Commands to build the S3 tfstate repository : 

```
terraform plan -var=target_name=jlabs-pp -var=target_region=eu-west-1 -state=jlabs-pp-ctn.eu-west-1.tfstate
terraform apply -var=target_name=jlabs-pp -var=target_region=eu-west-1 -state=jlabs-pp-ctn.eu-west-1.tfstate
```
