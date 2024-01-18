#!/usr/bin/env bash
SCRIPT_DIR=$(dirname "$0")
export SCRIPT_DIR

export DOCKER_FILE="./Dockerfile"

export BASE_IMAGE_NAME='ubuntu'
export BASE_IMAGE_TAG='22.04'
export PHP_VERSION='8.2'

export BUILD_IMAGE_NAME_OLD="haakco/ubuntu2204-php82"
export BUILD_IMAGE_NAME="ghcr.io/haakco/ubuntu2204-php82"
export BUILD_IMAGE_TAG="latest"

EXTRA_FLAG="${EXTRA_FLAG} --build-arg BASE_IMAGE_NAME=${BASE_IMAGE_NAME}"
EXTRA_FLAG="${EXTRA_FLAG} --build-arg BASE_IMAGE_TAG=${BASE_IMAGE_TAG}"
EXTRA_FLAG="${EXTRA_FLAG} --build-arg PHP_VERSION=${PHP_VERSION}"
export EXTRA_FLAG

"${SCRIPT_DIR}/baseBuild.sh"
