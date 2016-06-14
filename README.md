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

```
nomad status
```

### Provision the Consul Cluster

```
gcloud compute ssh ns-1
```

```
consul join ns-2 ns-3
```

```
$ consul members
Node  Address          Status  Type    Build  Protocol  DC
ns-1  10.240.0.4:8301  alive   server  0.6.4  2         dc1
ns-2  10.240.0.3:8301  alive   server  0.6.4  2         dc1
ns-3  10.240.0.2:8301  alive   server  0.6.4  2         dc1
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

```
vault auth <root-token>
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

```
gcloud compute addresses create hashistack-lb
```

```
gcloud compute http-health-checks create hashistack
```

```
gcloud compute target-pools create hashistack \
  --health-check hashistack
```

```
gcloud compute target-pools add-instances hashistack \
  --instances nc-1,nc-2,nc-3,nc-4,nc-5
```

```
gcloud compute addresses list
```

```
gcloud compute forwarding-rules create hashistack \
  --port-range 9998-9999 \
  --address STATIC_EXTERNAL_IP \
  --target-pool hashistack
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
