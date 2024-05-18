#!/usr/bin/env bash
## Gets the current directory of the script so that is cam be used for
## relative paths. This is useful when the script is called from another
## directory.
SCRIPT_DIR=$(realpath $(dirname "$0"))
export SCRIPT_DIR

DOCKER_RUN_DIR=$(realpath "${SCRIPT_DIR}/../")
export DOCKER_RUN_DIR

## Set the specific ubuntuPhp.Dockerfile to use for this build.
#  If you make sure it ends in Dockerfile most editors will recognize it.

## E.g ubuntuPhp.Dockerfile, dev.ubuntuPhp.Dockerfile, prod.ubuntuPhp.Dockerfile
DOCKER_FILE="${SCRIPT_DIR}/${DOCKER_FILE_DEFAULT-ubuntuPhp.Dockerfile}"
#DOCKER_FILE="${SCRIPT_DIR}/ubuntuPhp.Dockerfile.dev"
export DOCKER_FILE

BASE_IMAGE_NAME=${BASE_IMAGE_NAME-ubuntu}
export BASE_IMAGE_NAME
## This is ignored if USE_BRANCH_FOR_BASE_IMAGE_VERSION is set to TRUE
BASE_IMAGE_VERSION="${BASE_IMAGE_VERSION-'22.04'}"
export BASE_IMAGE_VERSION

BUILD_IMAGE_NAME=${BUILD_IMAGE_NAME-"ubuntu2204-php83"}
export BUILD_IMAGE_NAME

## This is ignored if USE_BRANCH_FOR_BUILD_IMAGE_VERSION is set to TRUE
BUILD_IMAGE_VERSION="${BUILD_IMAGE_VERSION-latest}"
export BUILD_IMAGE_VERSION

## The final tag will also contain the registry settings from the settings file
## E.g {BUILD_REGISTRY_BASE}/{BUILD_REGISTRY_COMPANY}/{BUILD_IMAGE_NAME}:{BUILD_IMAGE_VERSION}

PHP_VERSION="${PHP_VERSION-8.3}"
export PHP_VERSION

EXTRA_FLAGS="${EXTRA_FLAGS_DEFAULT}"
EXTRA_FLAGS="${EXTRA_FLAGS} --build-arg PHP_VERSION=${PHP_VERSION}"
EXTRA_FLAGS="${EXTRA_FLAGS:-}"

export EXTRA_FLAGS

/usr/bin/env bash "${SCRIPT_DIR}/build/buildDockerBaseShared.Ignore.sh"
