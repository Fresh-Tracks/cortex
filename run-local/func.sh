#!/bin/bash

KS_ENV="cortex_lite"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="${SCRIPT_DIR}/.."

DOCKER=$(which docker) > /dev/null 2>&1
if [ -z "${DOCKER}" ]; then
  echo "Sorry, you need to install Docker. Exiting."
  exit 1
fi

MK=$(which minikube) >/dev/null 2>&1
if [ -z ${MK} ]; then
  echo "Sorry, you need to install minikube. Exiting."
  exit 1
fi

KS=$(which ks) > /dev/null 2>&1
if [ -z "${KS}" ]; then
  echo "Sorry, you need to install ksonnet. Exiting."
  exit 1
fi

GC=$(which gcloud) > /dev/null 2>&1
if [ -z "${KS}" ]; then
  echo "Sorry, you need to install the Google Cloud SDK (gcloud). Exiting."
  exit 1
fi
#gc beta emulators bigtable start
