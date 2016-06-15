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

Complete the setup of the nomad cluser.

```
gcloud compute ssh ns-1
```

```
nomad server-join ns-2 ns-3
```

```
nomad status
```

### Complete the setup of the consul cluster

```
consul join ns-2 ns-3
```

```
consul members
```

### Complete the setup of the vault cluster

```
export VAULT_ADDR=http://ns-1:8200
```

```
vault init
```
```
vault unseal
```
```
vault status
```
```
vault auth <root-token>
```

Enable and configure the MySQL secret backend.

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
gcloud compute ssh ns-1
```

```
nomad node-status
```
