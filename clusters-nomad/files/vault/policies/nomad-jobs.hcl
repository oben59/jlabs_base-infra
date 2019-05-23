path "secret/node-config" {
  capabilities = ["read", "list"]
}

path "secret/node-proxies" {
  capabilities = ["read", "list"]
}

path "sys/renew/*" {
  capabilities = ["update"]
}
