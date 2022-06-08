#!/usr/bin/env bash
export PROXY="${PROXY:-""}"
export DOCKER_FILE="Dockerfile"
export IMAGE_NAME=vanuse.azurecr.io/vanuse-web
#export EXTRA_FLAG="${EXTRA_FLAG:-" --load "}"
./baseBuild.sh
#!/usr/bin/env bash
export DOCKER_FILE="./Dockerfile"

SCRIPT_DIR=$(dirname "$0")
export SCRIPT_DIR


export IMAGE_NAME=''

export BASE_IMAGE_NAME='ubuntu'
export BASE_IMAGE_TAG='22.04'
export PHP_VERSION='8.1'

export BUILD_IMAGE_NAME="haakco/ubuntu2204-php81"
export BUILD_IMAGE_TAG="latest"

EXTRA_FLAG="${EXTRA_FLAG} --build-arg BASE_IMAGE_NAME=${BASE_IMAGE_NAME}"
EXTRA_FLAG="${EXTRA_FLAG} --build-arg BASE_IMAGE_TAG=${BASE_IMAGE_TAG}"
EXTRA_FLAG="${EXTRA_FLAG} --build-arg PHP_VERSION=${PHP_VERSION}"
export EXTRA_FLAG

"${SCRIPT_DIR}/baseBuild.sh"
