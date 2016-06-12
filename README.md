# HashiConf EU 2016

## Cluster Bootstrapping

Setup Nomad, Consul, and Vault cluster:

```
gcloud compute instances create ns-1 ns-2 ns-3 \
 --image-project ubuntu-os-cloud \
 --image ubuntu-1604-xenial-v20160516a \
 --boot-disk-size 200GB \
 --machine-type n1-standard-1 \
 --can-ip-forward \
 --metadata-from-file startup-script=server-install.sh
```

Join the server nodes

```
gcloud compute ssh ns-1
nomad server-join ns-2 ns-3
consul join ns-2 ns-3
```

### Provision Worker Nodes

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
nomad run consul.nomad
```

```
gcloud compute ssh ns-1
consul join nc-1 nc-2 nc-3 nc-4 nc-5
```

```
export VAULT_ADDR=http://127.0.0.1:8200
vault init

```

```
gcloud compute firewall-rules create consul-ui \
  --allow tcp:8500 \
  --source-ranges 0.0.0.0/0
```
