#!/bin/sh
#
#------------------------------------------------------------------------------
# [Alex Moss, 2017-07-26]
#------------------------------------------------------------------------------
#
# Deploys the latest updated moss.work application to GCP, using Kubernetes.
# Template .yaml will be updated with latest tagged docker image in GCR.
#
# @TODO: In an ideal world, Helm templating would be in place.
#
#------------------------------------------------------------------------------

GCP_PROJECT=moss-work
REPO=eu.gcr.io/$GCP_PROJECT
IMAGE_NAME=moss.work-frontend
K8S_PATH=k8s

set -x

echo "Determining latest image pushed to GCR ..."
LATEST_TAG=$(gcloud container images list-tags $REPO/$IMAGE_NAME --sort-by="~timestamp" --limit=1 --format='value(tags)')

echo "Updating manifest with image version: $LATEST_TAG ..."
cat $K8S_PATH/$IMAGE_NAME.yml | sed 's/${IMAGE_VERSION}/'$LATEST_TAG'/' > $K8S_PATH/$IMAGE_NAME-staging.yml

echo "Updating Kubernetes deployment ..."
kubectl apply -f $K8S_PATH/$IMAGE_NAME-staging.yml

echo "Deployment complete. Housekeeping in progress ..."
rm $K8S_PATH/$IMAGE_NAME-staging.yml

echo "Script complete."
