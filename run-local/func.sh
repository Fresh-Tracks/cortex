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

KSVERSION=$(ks version | grep ksonnet | awk '{ print $3 }')
if [ "x${KSVERSION}x" != "x0.12.0x" ]; then
  echo "It looks like you're running ksonnet v${KSVERSION}, which is not ksonnet v0.12.0."
  echo "You're welcome to continue, but if things break horribly, this might be the cause."
fi

GC=$(which gcloud) > /dev/null 2>&1
if [ -z "${KS}" ]; then
  echo "Sorry, you need to install the Google Cloud SDK (gcloud). Exiting."
  exit 1
fi
