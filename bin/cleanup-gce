#!/bin/bash

gcloud sql instances delete hashiapp -q

gcloud compute instances delete \
  ns-1 ns-2 ns-3 nc-1 nc-2 nc-3 nc-4 nc-5 -q

gcloud compute forwarding-rules delete hashistack -q
gcloud compute target-pools delete hashistack -q
gcloud compute http-health-checks delete hashistack -q
gcloud compute addresses delete hashistack -q
gcloud compute firewall-rules delete fabio -q
