# HashiConf EU 2016

## Bootstrap a Nomad Cluster

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

### Provision the Nomad Cluster

```
gcloud compute ssh ns-1
```

```
nomad server-join ns-2 ns-3
```

### Provision the Consul Cluster

```
gcloud compute ssh ns-1
```

```
consul join ns-2 ns-3
```

### Provison Vault

```
gcloud compute ssh ns-1
```

```
export VAULT_ADDR=http://127.0.0.1:8200
```

```
vault init
```

Consider creating a vault policy and setting up ACLs.

```
vault unseal
```

#### Configure the MySQL Secret Backend

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

### Bootstrap Nomad Worker Nodes

```
gcloud compute instances create nc-1 nc-2 nc-3 nc-4 nc-5 \
 --image-project ubuntu-os-cloud \
 --image ubuntu-1604-xenial-v20160516a \
 --boot-disk-size 200GB \
 --machine-type n1-standard-2 \
 --can-ip-forward \
 --metadata-from-file startup-script=client-install.sh
```

## Service Discovery with Consul

```
nomad run jobs/consul.nomad
```

```
gcloud compute ssh ns-1
```

```
consul join nc-1 nc-2 nc-3 nc-4 nc-5
```

## Load Balancing with Fabio

```
nomad run jobs/fabio.nomad
```

```
nomad status fabio
```

## Hashiapp Job

Create the JWT Secret in vault.

```
vault write secret/hashiapp jwtsecret=secret
```

Submit the hashiapp service job.

```
nomad run jobs/hashiapp.nomad
```

```
nomad status hashiapp
```

### Viewing Logs

```
nomad fs cat <hashiapp-alloc-id> alloc/logs/hashiapp.stdout.0
```
