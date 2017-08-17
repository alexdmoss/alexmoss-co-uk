#!/usr/bin/env bash

GCP_PROJECT=moss-work
REPO=eu.gcr.io/$GCP_PROJECT
IMAGE_NAME=moss.work-frontend
LOCAL_PORT=80

if [ $# -ne 1 ]; then echo "Usage: $(basename "$0") <version>"; exit 1; fi

cd $(dirname "$0")
VERSION=$1
RUN_IMAGE="$REPO/$IMAGE_NAME:$VERSION"

if [[ $(docker ps | grep -c $IMAGE_NAME) -gt 0 ]]; then
  echo "[INFO] Stopping existing images ..."
  docker kill $(docker ps | grep $IMAGE_NAME | awk '{print $1}')
fi

docker run -d -p $LOCAL_PORT:80 $RUN_IMAGE

if [[ $(docker ps | grep -c $RUN_IMAGE) -gt 0 ]]; then
  echo "[INFO] Image running - available at: http://localhost:$LOCAL_PORT/"
else
  echo "[ERROR] Local docker image not running. Check logs."
fi
