# Build an image on ECR to allow connexions

## 1) create the ECR repository "bootstrap-nomad" directly on the environnements

## 2) Build it locally
```
docker build -t bootstrap-nomad:batch img/
docker build -t bootstrap-nomad:service img-svc/
```

## 3) Push it to accounts
```
aws ecr get-login --no-include-email --region eu-west-1
docker tag bootstrap-nomad:batch <account_id>.dkr.ecr.eu-west-1.amazonaws.com/bootstrap-nomad:batch
docker push <account_id>.dkr.ecr.eu-west-1.amazonaws.com/bootstrap-nomad:batch
```
