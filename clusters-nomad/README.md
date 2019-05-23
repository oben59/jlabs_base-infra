# Nomad Clusters Nodes


## Some remaining manual ops

### Prerequesites to use mfa-connect
* ensure there is an entry "awsmaster-<your_initals>" in ~/.aws/credentials
* apt install jq oathtool
* if you're right and you use zsh : it is necessary to simulate bash like this :`emulate sh -c '. ../mfa-auto-connect.sh pp jd'` 

### Consul secured tip

Si vous avez besoin de renouveler vos certificats (et vous en aurez besoin, régulièrement, just because), 
il vous suffit de supprimer le fichier "consul-node.cer" du répertoire contenant l’usine à certificats du noeud à rafraîchir et de relancer votre playbook. Un nouveau certificat sera créé, mis en place et le démon Consul sera relancé pour le prendre en compte.

### vault init command
```
vault status -address=https://nomad-master-0.node.dc1.consul:8200 \
    -ca-cert=/etc/consul.d/tls/consul-root.cer \
    -client-cert=/etc/consul.d/tls/consul-node.cer \
    -client-key=/etc/consul.d/tls/consul-node.key

vault status -address=https://vault.service.dc1.consul:8200 \
    -ca-cert=/etc/consul.d/tls/consul-root.cer \
    -client-cert=/etc/consul.d/tls/consul-node.cer \
    -client-key=/etc/consul.d/tls/consul-node.key

vault status -address=http://nomad-master-0.node.dc1.consul:8200
vault status -address=http://vault.service.dc1.consul:8200
```
