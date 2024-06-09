#!/usr/bin/env bash
set -euoE pipefail

IMAGE_TAG=${CONTAINER_IMAGE_NAME}:${CI_COMMIT_SHA}-$(echo "${CI_COMMIT_TIMESTAMP}" | sed 's/[:+]/./g')

pushd "$(dirname "${BASH_SOURCE[0]}")/../terraform/" >/dev/null

terraform init -backend-config=bucket="${GCP_PROJECT_ID}"-apps-tfstate -backend-config=prefix=alexmoss-co-uk
terraform plan -var gcp_project_id="${GCP_PROJECT_ID}" \
  -var app_name="${APP_NAME}" \
  -var image_tag="${IMAGE_TAG}" \
  -var region="${REGION}"

popd >/dev/null
