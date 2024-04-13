#!/usr/bin/env bash
set -euoE pipefail

pushd "$(dirname "${BASH_SOURCE[0]}")/../" >/dev/null

gcloud run deploy "${SERVICE}" \
  --image "europe-docker.pkg.dev/${PROJECT_ID}/alexos/${SERVICE}":"${CI_COMMIT_SHA}" \
  --project "${PROJECT_ID}" \
  --platform managed \
  --region "${REGION}"  \
  --service-account run-"${SERVICE}"@"${PROJECT_ID}".iam.gserviceaccount.com \
  --port "${PORT}" \
  --max-instances 1 \
  --allow-unauthenticated

popd >/dev/null
