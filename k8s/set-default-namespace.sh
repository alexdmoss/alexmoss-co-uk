#!/bin/bash
namespace=mw-prod
projectId=moss-work
zone=us-east1-b
cluster=moss-work-k8s
kubectl config set-context $namespace --namespace=$namespace --cluster=gke_${projectId}_${zone}_${cluster} --user=gke_${projectId}_${zone}_${cluster}
kubectl config use-context $namespace
