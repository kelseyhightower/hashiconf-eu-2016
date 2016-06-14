#!/bin/bash

gcloud compute instances delete \
  ns-1 ns-2 ns-3 nc-1 nc-2 nc-3 nc-4 nc-5

gcloud compute forwarding-rules delete hashistack
gcloud compute target-pools delete hashistack
gcloud compute http-health-checks delete hashistack
gcloud compute addresses delete hashistack-lb
gcloud compute firewall-rules delete fabio
