#!/bin/bash

# Script to run the kubectl exec command silently every 5 seconds in the background
nohup bash -c '
while true; do
  kubectl exec -it $(kubectl get pod -n storefront -l app=attacker-app -o jsonpath="{.items[0].metadata.name}") -n storefront -- /bin/sh >/dev/null 2>&1
  sleep 5
done
' >/dev/null 2>&1 &
