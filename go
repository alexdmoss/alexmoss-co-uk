#!/usr/bin/env bash
set -euo pipefail

if [[ -z ${IMAGE_NAME:-} ]]; then
  IMAGE_NAME=moss-work
fi 

function help() {
  echo -e "Usage: go <command>"
  echo -e
  echo -e "    help               Print this help"
  echo -e "    render             Creates gitbook assets"
  echo -e "    build              Build binary locally"
  echo -e "    deploy             Deploy to Kubernetes"
  echo -e 
  exit 0
}

function render() {

  _console_msg "Building gitbook assets" INFO true

  cd content/
  gitbook install hide-published-with image-class image-class bring-yer-favicon ga
  gitbook build
  cd ../

  _console_msg "Build complete" INFO true

}

function build() {

  if [[ ${DRONE:-} == "true" ]]; then
    _assert_variables_set GCP_PROJECT_ID K8S_DEPLOYER_CREDS DRONE_COMMIT_SHA
    image=eu.gcr.io/${GCP_PROJECT_ID}/${IMAGE_NAME}:${DRONE_COMMIT_SHA}
    _console_msg "-> Authenticating with GCloud"
    echo "${K8S_DEPLOYER_CREDS}" | gcloud auth activate-service-account --key-file -
    gcloud auth configure-docker
  else
    image=${IMAGE_NAME}:latest
  fi

  _console_msg "Building docker image" INFO true

  docker build -t ${image} .

  if [[ ${DRONE:-} == "true" ]]; then
    docker push ${image}
  fi

  _console_msg "Build complete" INFO true

}

function deploy() {

  _assert_variables_set GCP_PROJECT_ID

  pushd $(dirname $BASH_SOURCE[0]) >/dev/null

  # when running in CI, we need to set up gcloud/kubeconfig
  if [[ ${DRONE:-} == "true" ]]; then
    _assert_variables_set K8S_DEPLOYER_CREDS K8S_CLUSTER_NAME DRONE_COMMIT_SHA
    _console_msg "-> Authenticating with GCloud"
    echo "${K8S_DEPLOYER_CREDS}" | gcloud auth activate-service-account --key-file -
    region=$(gcloud container clusters list --project=${GCP_PROJECT_ID} --filter "NAME=${K8S_CLUSTER_NAME}" --format "value(zone)")
    _console_msg "-> Authenticating to cluster ${K8S_CLUSTER_NAME} in project ${GCP_PROJECT_ID} in ${region}"
    gcloud container clusters get-credentials ${K8S_CLUSTER_NAME} --project=${GCP_PROJECT_ID} --region=${region}
  else
    _assert_variables_set DRONE_COMMIT_SHA
  fi

  popd >/dev/null

  pushd "k8s/" >/dev/null

  _console_msg "Applying Kubernetes yaml"

  kustomize edit set image ${IMAGE_NAME}=eu.gcr.io/${GCP_PROJECT_ID}/${IMAGE_NAME}:${DRONE_COMMIT_SHA}
  kustomize build . | kubectl apply -f -
  kubectl rollout status deploy/${IMAGE_NAME} -n moss-work

  popd >/dev/null

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

if [[ ${1:-} =~ ^(help|build|deploy|render)$ ]]; then
  COMMAND=${1}
  shift
  $COMMAND "$@"
else
  help
  exit 1
fi
