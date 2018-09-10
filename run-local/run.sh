#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="${SCRIPT_DIR}/.."

source ${SCRIPT_DIR}/func.sh

function getCortexLiteImage() {
  echo $(${DOCKER} images --filter=reference='quay.io/weaveworks/cortex-lite:latest' --format="{{ .Repository }}:{{ .Tag }}" | sort | uniq)
}

function buildLite() {
  pushd ${PROJECT_DIR}
  eval "$(${MK} docker-env -p ${KS_ENV})"
  make cmd/lite/.uptodate
  popd > /dev/null
}

echo "Checking for ${KS_ENV} minikube profile..."
${MK} status -p ${KS_ENV} > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "${KS_ENV} profile not found, creating ..."
  ${MK} start --cpus 4 --memory 8192 --kubernetes-version v1.10.0 --profile ${KS_ENV} --log_dir ${SCRIPT_DIR}/logs
fi

eval "$(${MK} docker-env -p ${KS_ENV})"
echo "${KS_ENV} minikube profile setup, continuing..."

CORTEX_LITE_IMG=$(getCortexLiteImage)

echo "Checking for ${KS_ENV} image..."

if [ -z "${CORTEX_LITE_IMG}" ]; then
  echo "Need to build ${KS_ENV} image..."
  buildLite

  if [ -z "${CORTEX_LITE_IMG}" ]; then
    echo "Build failed, or the image went away. Exiting."
    exit 1
  fi
fi

echo "Found cortex-lite image in minikube docker: ${CORTEX_LITE_IMG}. Continuing..."

echo "Applying ksonnet bits to ${KS_ENV} environment..."
pushd ${SCRIPT_DIR}/ksonnet > /dev/null
kubectl config use-context ${KS_ENV}
${KS} apply --insecure-skip-tls-verify ${KS_ENV}
popd > /dev/null
