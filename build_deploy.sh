#!/bin/bash

count=0
for var in QUAY_USER QUAY_TOKEN; do
  if [ ! "${!var}" ]; then
    echo "$var is not set"
    count=$((count + 1))
  fi
done

[ $count -gt 0 ] && exit 1

image_name="quay.io/app-sre/vegeta-k8s"
image_tag=$(git rev-parse --short=7 HEAD)

docker build -t "${image_name}:latest" .
docker tag "${image_name}:latest" "${image_name}:${image_tag}"

docker_conf="${PWD}/.docker"
mkdir -p "${docker_conf}"
docker --config="${docker_conf}" login -u="${QUAY_USER}" -p="${QUAY_TOKEN}" quay.io

docker --config="${docker_conf}" push "${image_name}:latest"
docker --config="${docker_conf}" push "${image_name}:${image_tag}"
