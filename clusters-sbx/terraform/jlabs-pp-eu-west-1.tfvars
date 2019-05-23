vpc_cidr = "12.0.0.0/16"
vpc_developers_cidr = "172.20.0.0/16"
# pcx_id = "pcx-xxx"

public_subnet_cidr_a = "12.0.10.0/24"
private_subnet_cidr_a = "12.0.110.0/24"

public_subnet_cidr_b = "12.0.20.0/24"
private_subnet_cidr_b = "12.0.120.0/24"

public_subnet_cidr_c = "12.0.30.0/24"
private_subnet_cidr_c = "12.0.130.0/24"

instances_es_masters = {
  nb = 1
  type = "t2.medium" # RAM: 4Gb (deps : JVM)
  root_hdd_size = 8
  root_hdd_type = "gp2"
}
instances_es_workers = {
  nb = 1
  type = "t2.medium" # RAM: 4Gb (deps : JVM)
  root_hdd_size = 8
  root_hdd_type = "gp2"
  ebs_hdd_size = 10
  ebs_hdd_type = "gp2"
  ebs_hdd_name = "/dev/xvdb"
}

instances_monitor = {
  nb = 1
  type = "t2.medium" # RAM: 4Gb
  root_hdd_size = 80
  root_hdd_type = "gp2"
}

instances_consul_masters = {
  nb = 1
  type = "t2.medium" # RAM: 4Gb
  root_hdd_size = 8
  root_hdd_type = "gp2"
}

es_prefix = "pp"
project_hosted_zone_id = "Z7SKOO0O7M9HD"

slack_webhook = "https://hooks.slack.com/services/xxx"

bastion_default_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDoriW6fFu92Iamov9JV5gRIEfvlEnXDT7hjcb1UdHCJYxf/G/rbLVKggi3J9vmj15G+9QG75rrptSI2q9FWbQpqvo7W/KdbZFvu4iHKNvIwh5ZaSLbMmmWiz7ModZM3DnwDhvU8rKI15JR7+rzwPWa9RvW2nzAqIMld8qeTLvQXmEzOrjM4wrvp2uFsqXkniAfb4u6Il4uaAKdMwzLyJFIW8/3eV7j4ad9THD4Wsr8viWv+8ilD5B/pHkj0/EmfmyfbRYzLvUQhY7p7osGhJiqo8Tml1gTGRPP59J3jjjVQ0Bh8YHT5enb4b2mPQKgV2UpVru91KzacRUoGcRcP6jZ"

bastion_ingress_cidr = [
  "78.192.19.2/32", # home
  "81.250.133.68/32", # wescale
  "217.151.0.131/32" # seloger
]

seed_public_repo_dir = "https://raw.githubusercontent.com/jdxlabs/ansible-role-seed/master/files/seed-debian-8.sh"
instances_default_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDAwf9hCQ36+Y32WpJ/hLSsGheqNKnhFQz+v9H+LuD/5smoRVxjA5ZFA/clIr2SXs2H+P8XbarPSJjEDAYTtoq7SoT0EKcIS/TEH9MEzYV1gRG8+WdQx3EEv9JwdhsrQQe3qFLqETHATwEtZ7VdM6YRUlz0S9KJbGL++ssFRCQvFjrKcr7FLFA0bj/Vg6g8gBtYbwUVVkCeL64LPoSy4sKUoguKhRnQ4vMaCYQAZsFEIMJYF2Nr3SDvbR1fNieDCh3KudAbs9a73SA3Yi86tjtA73qw5u+Pkm8E76x2eZg2lO+LXX4L4M2RSjP0qSMrKebHgzmXnjPH23vFhSonmWfV"
instances_default_private_key = "-----BEGIN RSA PRIVATE KEY----- \nMIIEogIBAAKCAQEAwMH/YQkN+vmN9lqSf4S0rBoXqjSp4RUM/r/R/i7g/+bJqEVc \nYwOWRQP3JSK9kl7Nh/j/F22qz0iYxAwGE7aKu0qE9BCnCEv0xB/TBM2FdYERvPln \nUMdxBL/ScHYbK0EHt6hS6hExwE8BLWe1XTOmEVJc9EvSiWxi/vrLBUQkLxY6ynK+ \nxSxQNG4/1YOoPIAbWG8FFVZAni+uCz6EsuLClKILioUZ0OLzGgmEAGbBRCDCWBdj \na90g720dXzYngwodyrnQG7PWu90gN2IvOrY7QO96sObvj5JvBO+sdnmYNpTvi11+ \nC+DNkUoz9KkjKynmx4M5l54zx9t7xYUqJ5ln1QIDAQABAoIBAFp3Mgoym7MciHoE \njBj5CWp0XILvcINIw+6TzFSFX+f6Qs6Mrw1xU4dUkxuEsIAPqlqUi/RM7guWwMvR \n8NAzrey0zq1VW29TZq7dWMY6RtadGtwcGVcaI3rdJEDPzXSBcsPJZhCgvT7KVX0f \n3Ui+wsQCacnmBAunKNcOkVYJYwoNjIX3dvLOlMtprV/SS8t76tqyjtx0ZvJN6nP9 \ncIxGd87xRDU2VMJsZRXUKhM3NcAotQaOE7AHXpgqSmoyrFkwJFiS16TCtq3jcaHb \nV0I6OFyLfQTS6S3DWKilI3/Tu42KbNFRYZxKGtGU0qJMdWMrNZN3D/YJuIGGMP5N \nh37VeokCgYEA/QOXKgOr0+zB/y8mgDtc7R0PK136AFimFOtjeYtqcup1ZkO0Y7Sp \ngsOiBcjUwprQf7P0ipLWJFUewjfWMwDV5IBZm7ElxzTR6CHlGQfuObZXSQE7m0U9 \nVbZeZgyDL2dh23b65GXc3j5NaIg+mGC6+DJxFiUrxw5R4eHkidBA9B8CgYEAwwhc \nMpu8YaExCB+7sUlVdy/CpgnUxgzd+IYdBi3rkWNrbM8kZDSNI64zsPWf3ps14hEX \nl6CnpkNwgk0ivjGQ+sdPtOkcsFtdDiAANxg37ejHfT16TnmrY3tdHyeI0Rpj2TRg \nlAqgaldeTjgSYxwPizMad14O5K7C/hPp0iBnxYsCgYAc8HQx0gmtS79EuNfmguO2 \nG0TI6Q7XS0xzyBiwpkmeq0KSV9wiK1/YHRhDIR10xNBkSukFkJX9wd6qyEgvvUC5 \nyhR1wmVXy6rWqknR+x48a6bAKuvubpT9YMabVYMLwP9oYst/pEcHBIlGE49VTnsU \nOHDG36mKMxEajQPe33sOcQKBgHc0DOYBucoSM127x4Q8RjhqwJWrPJkwFBtqHSNB \nvdFG6sm+cYetdvZv6rgl6GiuhOh/eeP7FXzRi1qYurt0oCAm4di5AgfoT5/qfzct \nXkHTHNq3UKHWS6KqK+h2yXDEqHKBSOYy+IkGjWVRcCuTYwy5V1vN6VxsVFHm6eq8 \nU7CxAoGAS7oHG9RAvfTzDiczGzW5KwUYCInJHYn/J0KDxocnKMZ0Kh5icXgcT5TJ \nh0GRvcFd8FSj0p8WLbZ0u++RBtXNCDpGsGSYrbK8wc4ZaeYBG5f5SHKQViHDwEZw \n+PjFTu5My0BS10T1nS62ipWfEKh5VtLCReXL+rzrhqO91KqJB00= \n-----END RSA PRIVATE KEY----- \n"