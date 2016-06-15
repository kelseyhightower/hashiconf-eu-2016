# Bootstrap the HashiStack on Google Compute Engine

## Provision MySQL

```
gcloud sql instances create hashiapp \
  --tier db-n1-standard-1 \
  --activation-policy ALWAYS \
  --authorized-networks 0.0.0.0/0
```

```
gcloud sql instances set-root-password hashiapp \
  --password <password>
```

```
gcloud sql instances describe hashiapp
```

```
mysql -u root -h <database-ip> -p
Enter password: 
```

```
mysql> CREATE DATABASE hashiapp;
```

## Bootstrap a Nomad Cluster

This step will also install Nomad, Consul, and Vault.

```
gcloud compute instances create ns-1 ns-2 ns-3 \
  --image-project ubuntu-os-cloud \
  --image ubuntu-1604-xenial-v20160516a \
  --boot-disk-size 200GB \
  --machine-type n1-standard-2 \
  --can-ip-forward \
  --metadata-from-file startup-script=server-install.sh
```

### Provision the Nomad Cluster

```
nomad server-join ns-2 ns-3
```

```
nomad status
```

### Provision the Consul Cluster

```
consul join ns-2 ns-3
```

```
consul members
```

### Provison Vault

```
export VAULT_ADDR=http://ns-1:8200
```

```
vault init
```

#### Unseal Vault

```
vault unseal
```
```
vault status
```
```
Sealed: false
Key Shares: 5
Key Threshold: 3
Unseal Progress: 0

High-Availability Enabled: true
	Mode: active
	Leader: http://10.240.0.2:8200
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

```
nomad node-status
```
```
ID        DC   Name  Class   Drain  Status
ec906293  dc1  nc-5  <none>  false  ready
eb73ef71  dc1  nc-2  <none>  false  ready
a2328a47  dc1  nc-1  <none>  false  ready
537709ec  dc1  nc-3  <none>  false  ready
4e0a6bcb  dc1  nc-4  <none>  false  ready
```

