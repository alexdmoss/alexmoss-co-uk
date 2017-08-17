#!/usr/bin/env bash

GCP_PROJECT=moss-work
REPO=eu.gcr.io/$GCP_PROJECT
IMAGE_NAME=moss.work-frontend

if [ $# -ne 1 ]; then echo "Usage: $(basename "$0") <version>"; exit 1; fi

cd $(dirname "$0")
VERSION=$1
RUN_IMAGE="$REPO/$IMAGE_NAME:$VERSION"

set -x
docker build -t $RUN_IMAGE -f Dockerfile.run .

gcloud docker -- push $RUN_IMAGE
