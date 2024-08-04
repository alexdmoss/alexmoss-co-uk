#!/usr/bin/env bash
set -euoE pipefail

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

smoke "${@:-}"
