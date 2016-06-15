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

Edit `jobs/hashiapp.nomad` job

```
env {
  VAULT_TOKEN = "HASHIAPP_TOKEN"
  VAULT_ADDR = "http://vault.service.consul:8200"
  HASHIAPP_DB_HOST = "CLOUD_SQL:3306"
}
```

### Create the Hashiapp Secret

```
vault write secret/hashiapp jwtsecret=secret
```

## Service Discovery with Consul

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

## Hashiapp Job

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
