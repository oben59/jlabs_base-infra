# Commands to build the S3 tfstate repository : 

```
terraform plan -var=target_name=[team]-[env] -var=target_region=eu-west-1 -state=[team]-[env].eu-west-1.tfstate
terraform apply -var=target_name=[team]-[env] -var=target_region=eu-west-1 -state=[team]-[env].eu-west-1.tfstate
```
