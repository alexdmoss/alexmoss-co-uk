#!/usr/bin/env bash
set -euoE pipefail

pushd "$(dirname "${BASH_SOURCE[0]}")/../" >/dev/null


if [[ ${CI_SERVER:-} == "yes" ]]; then
  wget --no-verbose -O hugo.tar.gz https://github.com/gohugoio/hugo/releases/download/v0.90.1/hugo_extended_0.90.1_Linux-64bit.tar.gz && \
  tar zxf hugo.tar.gz && \
  mv ./hugo /usr/local/bin/ && \
  rm hugo.tar.gz
fi

mkdir -p "www/"

pushd "www/" > /dev/null
rm -rf ./*
popd >/dev/null

pushd "src/" >/dev/null
hugo --source .
popd >/dev/null


pushd "$(dirname "${BASH_SOURCE[0]}")/../" >/dev/null

image_name="europe-docker.pkg.dev/${PROJECT_ID}/alexos/${SERVICE}"

docker pull "${image_name}":latest || true
docker build --cache-from "${image_name}":latest --tag "${image_name}":latest .

if [[ ${CI_SERVER:-} == "yes" ]]; then
  docker tag "${image_name}":latest "${image_name}":"${CI_COMMIT_SHA}"
  docker push "${image_name}":"${CI_COMMIT_SHA}"
  docker push "${image_name}":latest
fi

popd >/dev/null 
