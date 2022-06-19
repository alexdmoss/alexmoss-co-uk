#!/usr/bin/env bash
set -euoE pipefail

function help() {
  echo -e "Usage: go <command>"
  echo -e
  echo -e "    run                      Runs site locally on for fast-feedback / exploratory testing"
  echo -e "    build                    Builds the site (HTML + docker image), runs tests with image and, if in CI, pushes to registry"
  echo -e "    deploy                   Deploys site onto hosts. Assumes pre-requisites are done"
  echo -e "    test                     Runs tests using the latest docker image"
  echo -e "    smoke                    Runs smoke tests against the live site"
  echo -e 
  exit 0
}

function run() {
    pushd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null
    hugo server -p 1314 -wDs src/
    popd >/dev/null
}

function build() {

    _console_msg "Building site ..."

    pushd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null

    _assert_variables_set IMAGE_NAME

    if [[ ${CI_SERVER:-} == "yes" ]]; then
        _assert_variables_set CI_COMMIT_SHA
        _console_msg "Installing Hugo in CI image ..."
        wget --no-verbose -O hugo.tar.gz https://github.com/gohugoio/hugo/releases/download/v0.90.1/hugo_extended_0.90.1_Linux-64bit.tar.gz && \
        tar zxf hugo.tar.gz && \
        mv ./hugo /usr/local/bin/ && \
        rm hugo.tar.gz
    fi
    
    mkdir -p "www/"

    pushd "www/" > /dev/null
    rm -rf ./*
    popd >/dev/null 
    
    pushd "src/" >/dev/null
    hugo --source .
    popd >/dev/null

    pushd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null

    _console_msg "Baking docker image ..."

    docker pull "${IMAGE_NAME}":latest || true
    docker build --cache-from "${IMAGE_NAME}":latest --tag "${IMAGE_NAME}":latest .

    test "${IMAGE_NAME}":latest

    if [[ ${CI_SERVER:-} == "yes" ]]; then
        _console_msg "Pushing image to registry ..."
        docker tag "${IMAGE_NAME}":latest "${IMAGE_NAME}":"${CI_COMMIT_SHA}"
        docker push "${IMAGE_NAME}":"${CI_COMMIT_SHA}"
        docker push "${IMAGE_NAME}":latest
    fi

    popd >/dev/null 
    
    _console_msg "Build complete" INFO true 

}

function deploy() {

    _assert_variables_set IMAGE_NAME CI_COMMIT_SHA

    _console_msg "Deploying app ..." INFO true

    pushd "k8s/" >/dev/null

    kubectl apply -f namespace.yaml
    kustomize edit set image alexmoss-co-uk="${IMAGE_NAME}":"${CI_COMMIT_SHA}"
    kustomize build . | kubectl apply -f -
    kubectl rollout status deploy/alexmoss-co-uk -n=alexmoss-co-uk --timeout=60s

    _console_msg "Deployment complete" INFO true

    popd >/dev/null

}

function test() {

    local error=0
    local image=${1:-}

    _console_msg "Running local docker image tests ..."

    if [[ ${CI_SERVER:-} == "yes" ]]; then
        local_hostname=docker
    else
        local_hostname=localhost
    fi

    if [[ -z ${image} ]]; then
        image=alexmoss-co-uk:latest
    fi

    docker run --rm -d --name alexmoss-co-uk -p 32080:32080 "${image}"
    trap "docker rm -f alexmoss-co-uk >/dev/null 2>&1 || true" EXIT

    sleep 5     # wow really, does it actually need this? /sigh

    DOMAIN=alexmoss.co.uk

    _smoke_test "${DOMAIN}" http://${local_hostname}:32080/ 'alexmoss.co.uk | Alex Moss' 'Title'
    _smoke_test "${DOMAIN}" http://${local_hostname}:32080/ '<div class="content"><p>Hi, I&rsquo;m Alex Moss' 'About'
    _smoke_test "${DOMAIN}" http://${local_hostname}:32080/ '<h4>Engineering Lead' 'Employment'
    _smoke_test "${DOMAIN}" http://${local_hostname}:32080/ '<span class="skillbar-title">Kubernetes</span>' 'Skills'
    _smoke_test "${DOMAIN}" http://${local_hostname}:32080/ '<div class="service-label">Observability &amp; Reliability</div>' 'Profession'
    _smoke_test "${DOMAIN}" http://${local_hostname}:32080/ '<h1>Engineering Lead</h1>' 'Engineering'
    _smoke_test "${DOMAIN}" http://${local_hostname}:32080/ '<h1>Cloud Architect</h1>' 'Architecture'
    _smoke_test "${DOMAIN}" http://${local_hostname}:32080/ '<h1>Education</h1>' 'Education'
    _smoke_test "${DOMAIN}" http://${local_hostname}:32080/ '<h2>Father</h2>' 'Interests'
    _smoke_test "${DOMAIN}" http://${local_hostname}:32080/ '<p>CUPS OF COFFEE</p>' 'Facts'
    _smoke_test "${DOMAIN}" http://${local_hostname}:32080/ 'Say Hello!</h1>' 'Contact'
    _smoke_test "${DOMAIN}" http://${local_hostname}:32080/ 'Copyright © 2022 Alex Moss. Hugo theme by' 'Footer'

    _smoke_test "${DOMAIN}" http://${local_hostname}:32080/posts/engineer/ 'As an engineer, I love' 'Engineer Detail'
    _smoke_test "${DOMAIN}" http://${local_hostname}:32080/posts/architect/ 'As an architect, I have' 'Architect Detail'

    _smoke_test "${DOMAIN}" http://${local_hostname}:32080/healthz 'OK' 'Healthz'
    _smoke_test "${DOMAIN}" http://${local_hostname}:32080/404.html 'Four-Oh-Four' '404 Direct'

    if [[ "${error:-}" != "0" ]]; then
        _console_msg "Tests FAILED - see messages above for for detail" ERROR
        exit 1
    else
        _console_msg "All local tests passed!"
    fi

}

function smoke() {

    local error=0

    _console_msg "Checking HTTP status codes for https://${DOMAIN}/ ..."
    
    _smoke_test "${DOMAIN}" https://"${DOMAIN}"/ 'alexmoss.co.uk | Alex Moss' 'Title'
    _smoke_test "${DOMAIN}" https://"${DOMAIN}"/ '<div class="content"><p>Hi, I&rsquo;m Alex Moss' 'About'
    _smoke_test "${DOMAIN}" https://"${DOMAIN}"/ '<h4>Engineering Lead' 'Employment'
    _smoke_test "${DOMAIN}" https://"${DOMAIN}"/ '<span class="skillbar-title">Kubernetes</span>' 'Skills'
    _smoke_test "${DOMAIN}" https://"${DOMAIN}"/ '<div class="service-label">Observability &amp; Reliability</div>' 'Profession'
    _smoke_test "${DOMAIN}" https://"${DOMAIN}"/ '<h1>Engineering Lead</h1>' 'Engineering'
    _smoke_test "${DOMAIN}" https://"${DOMAIN}"/ '<h1>Cloud Architect</h1>' 'Architecture'
    _smoke_test "${DOMAIN}" https://"${DOMAIN}"/ '<h1>Education</h1>' 'Education'
    _smoke_test "${DOMAIN}" https://"${DOMAIN}"/ '<h2>Father</h2>' 'Interests'
    _smoke_test "${DOMAIN}" https://"${DOMAIN}"/ '<p>CUPS OF COFFEE</p>' 'Facts'
    _smoke_test "${DOMAIN}" https://"${DOMAIN}"/ 'Say Hello!</h1>' 'Contact'
    _smoke_test "${DOMAIN}" https://"${DOMAIN}"/ 'Copyright © 2022 Alex Moss. Hugo theme by' 'Footer'
    _smoke_test "${DOMAIN}" https://"${DOMAIN}"/posts/engineer/ 'As an engineer, I love' 'Engineer Detail'
    _smoke_test "${DOMAIN}" https://"${DOMAIN}"/posts/architect/ 'As an architect, I have' 'Architect Detail'
    _smoke_test "${DOMAIN}" https://"${DOMAIN}"/healthz 'OK' 'Healthz'
    _smoke_test "${DOMAIN}" https://"${DOMAIN}"/404.html 'Four-Oh-Four' '404 Direct'
    _smoke_test "${DOMAIN}" https://"${DOMAIN}"/woofwoof/ 'Sorry' '404 Redirected'

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
    local explanation=$4

    output=$(curl -H "Host: ${domain}" -s -k -L "${url}" || true)

    if [[ $(echo "${output}" | grep -c "${match}") -eq 0 ]]; then 
        _console_msg "Test $explanation FAILED - ${url} - missing phrase" ERROR
        error=1
    else
        _console_msg "Test $explanation PASSED - ${url}" INFO
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

  if [[ ${level} == "ERROR" ]] || [[ ${level} == "CRIT" ]] || [[ ${level} == "FATAL" ]]; then
    (echo >&2 "-> [${level}]${ts} ${msg}")
  else 
    (echo "-> [${level}]${ts} ${msg}")
  fi
}

function ctrl_c() {
    if [ ! -z "${PID:-}" ]; then
        kill "${PID}"
    fi
    exit 1
}

trap ctrl_c INT

if [[ ${1:-} =~ ^(help|run|build|deploy|test|smoke)$ ]]; then
  COMMAND=${1}
  shift
  $COMMAND "$@"
else
  help
  exit 1
fi
