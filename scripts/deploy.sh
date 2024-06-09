#!/usr/bin/env bash
set -euoE pipefail

pushd "$(dirname "${BASH_SOURCE[0]}")/../terraform/" >/dev/null

terraform init -backend-config=bucket="${GCP_PROJECT_ID}"-apps-tfstate -backend-config=prefix=inkuisitor
terraform plan -var gcp_project_id="${GCP_PROJECT_ID}" \
  -var app_name="${APP_NAME}" \
  -var image_tag="${IMAGE_NAME}:${CI_COMMIT_SHA}"

# gcloud run deploy "${SERVICE}" \
#   --image "europe-docker.pkg.dev/${PROJECT_ID}/alexos/${SERVICE}":"${CI_COMMIT_SHA}" \
#   --project "${PROJECT_ID}" \
#   --platform managed \
#   --region "${REGION}"  \
#   --service-account run-"${SERVICE}"@"${PROJECT_ID}".iam.gserviceaccount.com \
#   --port "${PORT}" \
#   --max-instances 1 \
#   --allow-unauthenticated

popd >/dev/null
