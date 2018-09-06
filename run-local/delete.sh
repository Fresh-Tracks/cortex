#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="${SCRIPT_DIR}/.."

source ${SCRIPT_DIR}/func.sh

echo "Deleting ksonnet bits from ${KS_ENV} environment..."
pushd ksonnet > /dev/null
kubectl config use-context ${KS_ENV}
${KS} delete --insecure-skip-tls-verify ${KS_ENV}
pkill -9 -f bigtable-emulator
popd > /dev/null
