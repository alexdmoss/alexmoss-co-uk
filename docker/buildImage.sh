#!/usr/bin/env bash

IMAGE_NAME=alexdmoss/docker-gitbook

cd $(dirname "$0")
BUILD_IMAGE="$IMAGE_NAME:latest"

set -x
docker build -t $BUILD_IMAGE -f Dockerfile.build .
