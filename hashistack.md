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
MYSQL_IPADDRESS=$(gcloud sql instances describe hashiapp \
  --format='value(ipAddresses[0].ipAddress)')
```

```
mysql -u root -h $MYSQL_IPADDRESS -p
```
```
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
  --image-family ubuntu-1604-lts \
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
  --image-family ubuntu-1604-lts \
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

## Create L3 LoadBalancer

```
gcloud compute addresses create hashistack
```

```
gcloud compute http-health-checks create hashistack \
  --port 9998 \
  --request-path "/health"
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
gcloud compute firewall-rules create fabio \
  --allow tcp:9999 \
  --source-ranges 0.0.0.0/0
```

```
gcloud compute firewall-rules create fabio-ui \
  --allow tcp:9998 \
  --source-ranges 0.0.0.0/0
```

## Setup SSH Tunnel to Consul UI

```
gcloud compute ssh ns-1 \
  --ssh-flag="-n" \
  --ssh-flag="-N" \
  --ssh-flag="-T" \
  --ssh-flag="-L" \
  --ssh-flag="8500:127.0.0.1:8500"
```
