# HashiConf EU 2016

## Prerequisites

[Bootstrap the HashiStack on Google Compute Engine](hashistack.md)

Login into the controller node and checkout this repository.

```
gcloud compute ssh ns-1
```

```
git clone https://github.com/kelseyhightower/hashiconf-eu-2016.git
```

```
cd hashiconf-eu-2016
```

### Create the Hashiapp Policy and Token

```
vault policy-write hashiapp vault/hashiapp-policy.hcl
```

```
vault token-create \
  -policy="hashiapp" \
  -display-name="hashiapp"
```

```
sed -i "s/HASHIAPP_TOKEN/<hashiapp-token>/" jobs/hashiapp.nomad 
```
```
sed -i "s/CLOUD_SQL/<cloud-sql-ip>/" jobs/hashiapp.nomad
```

### Create the Hashiapp Secret

```
vault write secret/hashiapp jwtsecret=secret
```

### Service Discovery with Consul

```
nomad run jobs/consul.nomad
```

```
nomad status consul
```

```
consul join nc-1 nc-2 nc-3 nc-4 nc-5
```

```
consul members
```

## Load Balancing with Fabio

```
nomad run jobs/fabio.nomad
```

```
nomad status fabio
```

### Create L3 LoadBalancer

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
gcloud compute forwarding-rules create hashistack \
  --port-range 9998-9999 \
  --address STATIC_EXTERNAL_IP \
  --target-pool hashistack
```

```
gcloud compute firewall-rules create fabio \
  --allow tcp:9998-9999 \
  --source-range 0.0.0.0/0
```

### Hashiapp Job

Submit the hashiapp service job.

```
nomad run jobs/hashiapp.nomad
```

```
nomad status hashiapp
```

#### Viewing Logs

```
nomad fs -job hashiapp alloc/logs/hashiapp.stderr.0
nomad fs -job hashiapp alloc/logs/hashiapp.stdout.0
```

#### Send Traffic

```
curl -H "Host: hashiapp.com" http://<loadbalancer-ip>:9999/version
```

### Scaling Up

```
nomad run jobs/hashiapp.nomad
```

### Rolling Upgrades

```
nomad run jobs/hashiapp.nomad
```
