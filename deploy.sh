#!/usr/bin/env bash
set -euoE pipefail

gcloud run deploy alexmoss-co-uk \
          --image "${IMAGE_NAME}":"${CI_COMMIT_SHA}" \
          --project "${MW_PROJECT_ID}" \
          --platform managed \
          --region europe-west1  \
          --port 8001 \
          --min-instances 1 \
          --max-instances 3 \
          --allow-unauthenticated
