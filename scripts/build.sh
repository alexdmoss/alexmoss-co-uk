#!/usr/bin/env bash
set -euoE pipefail

pushd "$(dirname "${BASH_SOURCE[0]}")/../" >/dev/null

image_name="eu.gcr.io/${PROJECT_ID}/${SERVICE}"

docker pull "${image_name}":latest || true
docker build --cache-from "${image_name}":latest --tag "${image_name}":latest .

if [[ ${CI_SERVER:-} == "yes" ]]; then
  docker tag "${image_name}":latest "${image_name}":"${CI_COMMIT_SHA}"
  docker push "${image_name}":"${CI_COMMIT_SHA}"
  docker push "${image_name}":latest
fi

popd >/dev/null 
