#!/usr/bin/env bash
set -euo pipefail

function help() {
  echo -e "Usage: go <command>"
  echo -e
  echo -e "    help               Print this help"
  echo -e "    render             Creates gitbook assets"
  echo -e "    build              Build binary locally"
  echo -e "    deploy             Deploy to Kubernetes"
  echo -e "    smoke              Basic smoke tests"
  echo -e 
  exit 0
}

function render() {

  _console_msg "Building gitbook assets" INFO true

  cd content/
  gitbook install .
  gitbook build
  cd ../

  _console_msg "Build complete" INFO true

}

function build() {

  _assert_variables_set GCP_PROJECT_ID IMAGE_NAME

  image=eu.gcr.io/${GCP_PROJECT_ID}/${IMAGE_NAME}:${CI_COMMIT_SHA}
  
  _console_msg "Building docker image" INFO true

  docker build -t "${image}" .
  docker push "${image}"
  
  _console_msg "Build complete" INFO true

}

function deploy() {

  _assert_variables_set GCP_PROJECT_ID IMAGE_NAME

  pushd "$(dirname "${BASH_SOURCE[0]}")/k8s" >/dev/null

  _console_msg "Applying Kubernetes yaml"

  kubectl apply -f namespace.yaml
  kustomize edit set image "${IMAGE_NAME}"=eu.gcr.io/"${GCP_PROJECT_ID}"/"${IMAGE_NAME}":"${CI_COMMIT_SHA}"
  kustomize build . | kubectl apply -f -
  kubectl rollout status deploy/"${IMAGE_NAME}" -n moss-work

  popd >/dev/null

}


function smoke() {

    local error=0

    _assert_variables_set DOMAIN

    _console_msg "Checking HTTP status codes for https://"${DOMAIN}"/ ..."
    
    _smoke_test "${DOMAIN}" https://"${DOMAIN}"/ "is the website describing the career"
    _smoke_test "${DOMAIN}" https://"${DOMAIN}"/profile/TechnicalSkills.html "modern technology"

    if [[ "${error:-}" != "0" ]]; then
        _console_msg "Tests FAILED - see messages above for for detail" ERROR
        exit 1
    else
        _console_msg "All local tests passed!"
    fi

}

function _smoke_test() {
    local domain=$1
    local url=$2
    local match=$3
    output=$(curl -H "Host: ${domain}" -s -k -L -w "\nHTTP-%{http_code}" ${url} || true)
    if [[ $(echo ${output} | grep -c "HTTP-200") -eq 0 ]]; then
        _console_msg "Test FAILED - ${url} - non-200 return code" ERROR
        error=1
    fi
    if [[ $(echo ${output} | grep -c "${match}") -eq 0 ]]; then 
        _console_msg "Test FAILED - ${url} - missing phrase" ERROR
        error=1
    else
        _console_msg "Test PASSED - ${url}" INFO
    fi
}

function _assert_variables_set() {

  local error=0
  local varname
  
  for varname in "$@"; do
    if [[ -z "${!varname-}" ]]; then
      echo "${varname} must be set" >&2
      error=1
    fi
  done
  
  if [[ ${error} = 1 ]]; then
    exit 1
  fi

}

function _console_msg() {

  local msg=${1}
  local level=${2:-}
  local ts=${3:-}

  if [[ -z ${level} ]]; then level=INFO; fi
  if [[ -n ${ts} ]]; then ts=" [$(date +"%Y-%m-%d %H:%M")]"; fi

  echo ""

  if [[ ${level} == "ERROR" ]] || [[ ${level} == "CRIT" ]] || [[ ${level} == "FATAL" ]]; then
    (echo 2>&1)
    (echo >&2 "-> [${level}]${ts} ${msg}")
  else 
    (echo "-> [${level}]${ts} ${msg}")
  fi

  echo ""

}

function ctrl_c() {
    if [ ! -z ${PID:-} ]; then
        kill ${PID}
    fi
    exit 1
}

trap ctrl_c INT

if [[ ${1:-} =~ ^(help|build|deploy|render|smoke)$ ]]; then
  COMMAND=${1}
  shift
  $COMMAND "$@"
else
  help
  exit 1
fi
