#!/usr/bin/env bash
set -uoE pipefail

IMAGE_NAME=${IMAGE_NAME}:${CI_COMMIT_SHA}-$(echo "${CI_COMMIT_TIMESTAMP}" | sed 's/[:+]/./g')

if [[ -z "${DOCKERFILE:-}" ]]; then
  DOCKERFILE="Dockerfile"
fi

pushd "$(dirname "${BASH_SOURCE[0]}")/../" >/dev/null || exit 1

echo "-> [INFO] Scanning for secret leakage ..."
gitleaks git --redact --report-format json --report-path ./gitleaks.json

echo "-> [INFO] Running Snyk Code Scan ..."
snyk code test --org="${SNYK_ORG_ID}" --json-file-output=./snyk-code.json

if [[ -n "${SNYK_LANGUAGE:-}" ]]; then
  echo "-> [INFO] Running Snyk Library Scan ..."
  snyk test --all-projects --org="${SNYK_ORG_ID}" --json-file-output=./snyk-library.json
fi

echo "-> [INFO] Running Snyk Container Scan ..."
snyk container test "${IMAGE_NAME}" --file="${DOCKERFILE}" --app-vulns --org="${SNYK_ORG_ID}" --json-file-output=./snyk-container-image.json

echo "-> [INFO] Running Snyk IaC Scan ..."
snyk iac test --org="${SNYK_ORG_ID}" --json-file-output=./snyk-iac.json

popd >/dev/null || exit 1

echo "-> [INFO] Secret Scan complete"
