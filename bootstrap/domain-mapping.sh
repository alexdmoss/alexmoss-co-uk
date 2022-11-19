#!/usr/bin/env bash
set -euoE pipefail

# MW_PROJECT_ID must also be set
export SERVICE=alexmoss-co-uk
export DOMAIN=alexmoss.co.uk
export REGION=europe-west1

echo "-> [INFO] Creating domain-mapping for ${DOMAIN} ..."
gcloud beta run domain-mappings create \
  --service "${SERVICE}" \
  --domain "${DOMAIN}" \
  --platform managed \
  --region "${REGION}" \
  --project "${MW_PROJECT_ID}"

echo "-> [INFO] Creating domain-mapping for www.${DOMAIN} ..."
gcloud beta run domain-mappings create \
  --service "${SERVICE}" \
  --domain "www.${DOMAIN}" \
  --platform managed \
  --region "${REGION}" \
  --project "${MW_PROJECT_ID}"
