#!/bin/bash

GCP_PROJECT=moss-work
REPO=eu.gcr.io/$GCP_PROJECT
IMAGE_NAME=moss-work
BUILDER_IMAGE_NAME=alexdmoss/docker-gitbook
RUN_IMAGE_NAME=${REPO}/${IMAGE_NAME}
CONTENT_DIR=content
K8S_PATH=k8s
