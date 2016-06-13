# HashiConf EU 2016

## Cluster Bootstrapping

### Provision Control Plane

#### Provision 3 Controller Nodes

This step will also install Nomad, Consul, and Vault.

```
gcloud compute instances create ns-1 ns-2 ns-3 \
 --image-project ubuntu-os-cloud \
 --image ubuntu-1604-xenial-v20160516a \
 --boot-disk-size 200GB \
 --machine-type n1-standard-1 \
 --can-ip-forward \
 --metadata-from-file startup-script=server-install.sh
```

#### Join the Nomad Cluster

```
gcloud compute ssh ns-1
```
```
nomad server-join ns-2 ns-3
```

#### Join the Consul Cluster

```
gcloud compute ssh ns-1
```
```
consul join ns-2 ns-3
```

#### Initialize Vault

```
gcloud compute ssh ns-1
```

```
export VAULT_ADDR=http://127.0.0.1:8200
vault init
```

### Provision Worker Nodes

#### Provision 5 Worker Nodes

```
gcloud compute instances create nc-1 nc-2 nc-3 nc-4 nc-5 \
 --image-project ubuntu-os-cloud \
 --image ubuntu-1604-xenial-v20160516a \
 --boot-disk-size 200GB \
 --machine-type n1-standard-2 \
 --can-ip-forward \
 --metadata-from-file startup-script=client-install.sh
```

#### Start Consul Agent

```
gcloud compute ssh ns-1
```

```
nomad run jobs/consul.nomad
```

```
consul join nc-1 nc-2 nc-3 nc-4 nc-5
```

### Secret Automation

```
vault write secret/hashiapp jwtsecret=secret
```

### Database Automation

Use vault to manage per application instance database creds.

https://www.vaultproject.io/docs/secrets/mysql/index.html


```
vault mount mysql
```

```
vault write mysql/config/connection \
> connection_url="USERNAME:PASSWORD@tcp(HOST:PORT)/"
```

```
vault write mysql/roles/hashiapp \
  sql="CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}';GRANT ALL PRIVILEGES ON hashiapp.* TO '{{name}}'@'%';"
```
