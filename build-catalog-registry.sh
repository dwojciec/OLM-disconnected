#!/bin/bash
# source /root/OLM-disconnected/env.sh
echo "build image parameters :"
echo "secret file " $AIRGAP_SECRET_JSON
echo "image name " $CATALOG_OPERATOR_IMAGE

podman build --authfile ${AIRGAP_SECRET_JSON} -t ${CATALOG_OPERATOR_IMAGE}:latest -f Dockerfile .
podman rmi $(podman images -q --filter "dangling=true")
