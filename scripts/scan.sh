#!/usr/bin/env bash
set -uoE pipefail

IMAGE_NAME=${IMAGE_NAME}:${CI_COMMIT_SHA}-$(echo "${CI_COMMIT_TIMESTAMP}" | sed 's/[:+]/./g')

if [[ -z "${DOCKERFILE:-}" ]]; then
  DOCKERFILE="Dockerfile"
fi

pushd "$(dirname "${BASH_SOURCE[0]}")/../" >/dev/null || exit 1

errors=0

echo "-------------------------------------------------------------------------------"
echo "-> [INFO] Scanning for secret leakage ..."
gitleaks git --redact --report-format json --report-path ./gitleaks.json
rc=$?
if [[ $rc -ne 0 ]]; then
  errors=$((errors + 1))
  echo "-> [ERROR] Gitleaks found secrets in the codebase. Check ./gitleaks.json for details."
  exit $rc
fi

echo "-------------------------------------------------------------------------------"
echo "-> [INFO] Running Snyk Code Scan ..."
snyk code test --org="${SNYK_ORG_ID}" --json-file-output=./snyk-code.json
rc=$?
if [[ $rc -ne 0 ]]; then
  errors=$((errors + 1))
  echo "-> [ERROR] Snyk Code Scan found issues. Check ./snyk-code.json for details."
  exit $rc
fi


if [[ -n "${SNYK_LANGUAGE:-}" ]]; then
  echo "-------------------------------------------------------------------------------"
  echo "-> [INFO] Running Snyk Library Scan ..."
  snyk test --all-projects --org="${SNYK_ORG_ID}" --json-file-output=./snyk-library.json
  rc=$?
  if [[ $rc -ne 0 ]]; then
    errors=$((errors + 1))
    echo "-> [ERROR] Snyk Library Scan found issues. Check ./snyk-library.json for details."
    exit $rc
  fi
fi

echo "-------------------------------------------------------------------------------"
echo "-> [INFO] Running Snyk Container Scan ..."
snyk container test "${IMAGE_NAME}" --file="${DOCKERFILE}" --app-vulns --org="${SNYK_ORG_ID}" --json-file-output=./snyk-container.json
rc=$?
if [[ $rc -ne 0 ]]; then
  errors=$((errors + 1))
  echo "-> [ERROR] Snyk Container Scan found issues. Check ./snyk-container.json for details."
  exit $rc
fi

echo "-------------------------------------------------------------------------------"
echo "-> [INFO] Running Snyk IaC Scan ..."
snyk iac test --org="${SNYK_ORG_ID}" --json-file-output=./snyk-iac.json
rc=$?
if [[ $rc -ne 0 ]]; then
  errors=$((errors + 1))
  echo "-> [ERROR] Snyk IaC Scan found issues. Check ./snyk-iac.json for details."
  exit $rc
fi

if [[ $errors -ne 0 ]]; then
  echo "==============================================================================="
  echo "-> [ERROR] One or more scans failed. Please check the logs above."
  echo "==============================================================================="
  exit 1
fi

popd >/dev/null || exit 1

echo "-> [INFO] Secret Scan complete"
