#!/bin/sh -eu
#
#------------------------------------------------------------------------------
# [Alex Moss, 2017-07-21]
#------------------------------------------------------------------------------
#
# Runs a local docker image to build the gitbook that makes up the content of
# http://moss.work. It assumes structure/assets in content/ sub-directory.
#
# Local docker image must have been built using docker/buildImage.sh first.
#
#------------------------------------------------------------------------------

if [ $# -ne 1 ]; then 
  echo "Version not specified - incrementing point release (n.n.X)"
  PREVIOUS_VERSION=$(docker images eu.gcr.io/moss-work/moss.work-frontend --format "{{.Tag}}" | head -n1)
  n=${PREVIOUS_VERSION##*[!0-9]}; p=${PREVIOUS_VERSION%%$n}
  VERSION=$p$((n+1))
else
  VERSION=$1
fi

DOCKER_BUILD_IMAGE=alexdmoss/docker-gitbook
CWD=$(pwd)
CONTENT_DIR=content

set -x

docker run -ti --rm -v $CWD:/docs $DOCKER_BUILD_IMAGE:latest build content/

docker run -ti --rm -v $CWD:/docs $DOCKER_BUILD_IMAGE:latest pdf ./ content/_book/moss.work.pdf

mv $CWD/content/_book $CWD/docker/

$CWD/docker/runImage.sh $VERSION

rm -r $CWD/docker/_book
