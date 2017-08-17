#!/bin/bash
clusterName=moss-work-k8s
projectName=moss-work
gcloud container clusters get-credentials $clusterName --project $projectName
