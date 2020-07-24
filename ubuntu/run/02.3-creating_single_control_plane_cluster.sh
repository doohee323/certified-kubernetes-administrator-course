#!/bin/bash
set -e
#set -x

echo "====================================================================="
echo " Validataion"
echo "====================================================================="

kubectl get nodes

kubectl run nginx --image=nginx

sleep 10
kubectl get pods

sleep 10
kubectl get pods

kubectl delete pod nginx


