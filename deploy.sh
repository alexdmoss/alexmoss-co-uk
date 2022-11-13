#!/usr/bin/env bash
set -euoE pipefail

gcloud run deploy alexmoss-co-uk \
          --image "${IMAGE_NAME}":"${CI_COMMIT_SHA}" \
          --project "${MW_PROJECT_ID}" \
          --platform managed \
          --region europe-west1  \
          --service-account run-alexmoss-co-uk@"${MW_PROJECT_ID}".iam.gserviceaccount.com \
          --port 32080 \
          --min-instances 1 \
          --max-instances 2 \
          --allow-unauthenticated
