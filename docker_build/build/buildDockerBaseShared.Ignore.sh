#!/usr/bin/env bash
export DOCKER_BUILDKIT=1
export BUILDX_EXPERIMENTAL=1

## The location of the actual build script
THIS_SCRIPT_DIR=$(realpath $(dirname "$0"))
export THIS_SCRIPT_DIR

## The location of the script to build the specific image
## This should be passed in
## The docker build is run from this directory
SCRIPT_DIR="${SCRIPT_DIR:-${THIS_SCRIPT_DIR}}"
export SCRIPT_DIR

THIS_DOCKER_RUN_DIR=$(realpath "${THIS_SCRIPT_DIR}/../../")

DOCKER_RUN_DIR="${DOCKER_RUN_DIR:-${THIS_DOCKER_RUN_DIR}}"
export DOCKER_RUN_DIR

## Load the settings for the build
source "${SCRIPT_DIR}/buildDockerBase.settings.env"
export BUILD_PULL
export BUILD_PUSH
export BUILD_LOCAL
export DISABLE_BUILD_CACHE
export DOCKER_COMPRESSION_TYPE
export DOCKER_COMPRESSION_LEVEL
export BUILD_IMAGE_REGISTRY_BASE
export BUILD_IMAGE_REGISTRY_COMPANY
export USE_BRANCH_FOR_BASE_IMAGE_VERSION
export USE_BRANCH_FOR_BUILD_IMAGE_VERSION
export EXTRA_FLAGS_DEFAULT

BRANCH_NAME_FROM_GIT=$( (git symbolic-ref HEAD 2>/dev/null || echo "(unnamed branch)")|cut -d/ -f3-)
export BRANCH_NAME_FROM_GIT

## Remove any slashes from the branch name else tags will fail
## Most like this need more work to handle more characters
export TAG_BASE_BRANCH_NAME_FROM_GIT="${BRANCH_NAME_FROM_GIT//\//-}"

export DOCKER_FILE="${DOCKER_FILE:-"Dockerfile"}"
EXTRA_FLAGS="${EXTRA_FLAGS:-}"

export BASE_IMAGE_NAME="${BASE_IMAGE_NAME}"
if [[ ${USE_BRANCH_FOR_BASE_IMAGE_VERSION} == 'TRUE' ]]; then
  BASE_IMAGE_VERSION="${TAG_BRANCH_NAME_FROM_GIT}"
else
  BASE_IMAGE_VERSION="${BASE_IMAGE_VERSION:-latest}"
fi
export BASE_IMAGE_VERSION
export BASE_IMAGE_NAME_FULL="${BASE_IMAGE_NAME}:${BASE_IMAGE_VERSION}"
EXTRA_FLAGS="${EXTRA_FLAGS} --build-arg BASE_IMAGE_NAME=${BASE_IMAGE_NAME}"
EXTRA_FLAGS="${EXTRA_FLAGS} --build-arg BASE_IMAGE_VERSION=${BASE_IMAGE_VERSION}"

export BUILD_IMAGE_NAME="${BUILD_IMAGE_NAME}"
if [[ ${USE_BRANCH_FOR_BUILD_IMAGE_VERSION} == 'TRUE' ]]; then
  BUILD_IMAGE_VERSION="${TAG_BASE_BRANCH_NAME_FROM_GIT}"
else
  BUILD_IMAGE_VERSION="${BUILD_IMAGE_VERSION:-latest}"
fi
export BUILD_IMAGE_VERSION
export BUILD_IMAGE_NAME_FULL="${BUILD_IMAGE_NAME}:${BUILD_IMAGE_VERSION}"
EXTRA_FLAGS="${EXTRA_FLAGS} --build-arg BUILD_IMAGE_NAME=${BUILD_IMAGE_NAME}"
EXTRA_FLAGS="${EXTRA_FLAGS} --build-arg BUILD_IMAGE_VERSION=${BUILD_IMAGE_VERSION}"

export BUILD_IMAGE_REGISTRY_BASE="${BUILD_IMAGE_REGISTRY_BASE:-}"
export BUILD_IMAGE_REGISTRY_COMPANY="${BUILD_IMAGE_REGISTRY_COMPANY:-}"

if [[ "${BUILD_IMAGE_REGISTRY_COMPANY}" != "" ]]; then
  EXTRA_FLAGS="${EXTRA_FLAGS} --build-arg BUILD_IMAGE_REGISTRY_COMPANY=${BUILD_IMAGE_REGISTRY_COMPANY}"
  BUILD_REGISTRY_FULL="${BUILD_IMAGE_REGISTRY_BASE}/${BUILD_IMAGE_REGISTRY_COMPANY}"
else
  BUILD_REGISTRY_FULL="${BUILD_IMAGE_REGISTRY_BASE}"
fi
export BUILD_REGISTRY_FULL

if [[ "${BUILD_REGISTRY_FULL}" != "" ]]; then
  EXTRA_FLAGS="${EXTRA_FLAGS} --build-arg BUILD_REGISTRY_FULL=${BUILD_REGISTRY_FULL}"
  REGISTRY_BUILD_IMAGE_NAME_FULL="${BUILD_REGISTRY_FULL}/${BUILD_IMAGE_NAME}:${BUILD_IMAGE_VERSION}"
  REGISTRY_BUILD_CACHE_NAME_FULL="${BUILD_REGISTRY_FULL}/buildcache/${BUILD_IMAGE_NAME}:buildcache"
else
  REGISTRY_BUILD_IMAGE_NAME_FULL="${BUILD_IMAGE_NAME}:${BUILD_IMAGE_VERSION}"
  REGISTRY_BUILD_CACHE_NAME_FULL="${BUILD_IMAGE_NAME}/buildcache:buildcache"
fi
export REGISTRY_BUILD_IMAGE_NAME_FULL
export REGISTRY_BUILD_CACHE_NAME_FULL

EXTRA_FLAGS="${EXTRA_FLAGS} --build-arg REGISTRY_BUILD_IMAGE_NAME_FULL=${REGISTRY_BUILD_IMAGE_NAME_FULL}"

export EXTRA_FLAGS

## For local builds is better to just use the local cache default
## But you can enable registry caching if you are using it in you CI/CD
## So its cached for the next build

export CACHE_TO_LOCAL=" --cache-to type=local,dest=/tmp/buildkit/cache,oci-mediatypes=true,image-manifest=true,mode=max,compression=${DOCKER_COMPRESSION_TYPE},compression-level=${DOCKER_COMPRESSION_LEVEL},force-compression=true,ref=${REGISTRY_BUILD_CACHE_NAME_FULL}"
export CACHE_FROM_LOCAL=" --cache-from type=local,src=/tmp/buildkit/cache,ref=${REGISTRY_BUILD_CACHE_NAME_FULL}"

export CACHE_TO_REGISTRY=" --cache-to type=registry,oci-mediatypes=true,image-manifest=true,mode=max,compression=${DOCKER_COMPRESSION_TYPE},compression-level=${DOCKER_COMPRESSION_LEVEL},force-compression=true,ref=${REGISTRY_BUILD_CACHE_NAME_FULL}"
export CACHE_FROM_REGISTRY=" --cache-from type=registry,ref=${REGISTRY_BUILD_CACHE_NAME_FULL}"

if [[ "${DISABLE_BUILD_CACHE}" == 'TRUE' ]]; then
  BUILD_CACHE=" --no-cache "
else
  BUILD_CACHE=" ${CACHE_TO_LOCAL} ${CACHE_FROM_LOCAL} ${CACHE_TO_REGISTRY} ${CACHE_FROM_REGISTRY}"
fi
export BUILD_CACHE


if [[ "${BUILD_PULL}" != 'TRUE' ]]; then
  PULL_BASE_IMAGE=" "
else
  PULL_BASE_IMAGE=" --pull "
fi
export PULL_BASE_IMAGE

echo "ScriptDir: ${SCRIPT_DIR}"
echo ""
echo ""
echo "Branch: ${BRANCH_NAME_FROM_GIT}"
echo ""
echo "BASE_IMAGE_NAME_FULL: ${BASE_IMAGE_NAME_FULL}"
echo "REGISTRY_BUILD_IMAGE_NAME_FULL: ${REGISTRY_BUILD_IMAGE_NAME_FULL}"
echo ""
echo "DOCKER_FILE: ${DOCKER_FILE}"
echo "SCRIPT_DIR: ${SCRIPT_DIR}"
echo "DISABLE_BUILD_CACHE: ${DISABLE_BUILD_CACHE}"
echo "BUILD_CACHE: ${BUILD_CACHE}"
echo "BUILD_PULL: ${BUILD_PULL}"
echo ""
echo ""

export CMD_BASE='docker buildx build --rm '"${PULL_BASE_IMAGE}"' '"${BUILD_CACHE}"
export CMD_SUFFIX='--file "'${DOCKER_FILE}'" -t "'${REGISTRY_BUILD_IMAGE_NAME_FULL}'" '"${EXTRA_FLAGS}"' .'

export CMD_REMOTE_OUTPUT="--output type=image,oci-mediatypes=true,name=${REGISTRY_BUILD_IMAGE_NAME_FULL},push=true,compression=${DOCKER_COMPRESSION_TYPE},compression-level=${DOCKER_COMPRESSION_LEVEL},force-compression=true"
export CMD_REMOTE_PLATFORM="linux/arm64/v8,linux/amd64"
export CMD_PUSH="${CMD_BASE} --platform ${CMD_REMOTE_PLATFORM} ${CMD_REMOTE_OUTPUT} ${CMD_SUFFIX}"

if [[ "$(uname -p)" == "x86_64" ]]; then
  LOCAL_PLATFORM='linux/amd64'
else
  LOCAL_PLATFORM='linux/arm64/v8'
fi
export LOCAL_PLATFORM

CMD_LOCAL_OUTPUT="--output type=docker,oci-mediatypes=true,name=${REGISTRY_BUILD_IMAGE_NAME_FULL},compression=${DOCKER_COMPRESSION_TYPE},compression-level=${DOCKER_COMPRESSION_LEVEL},force-compression=true"
export CMD_LOCAL="${CMD_BASE} --platform ${LOCAL_PLATFORM} ${CMD_LOCAL_OUTPUT} ${CMD_SUFFIX}"

if [[ "${BUILD_PUSH}" == 'TRUE' ]]; then
  echo ""
  echo "CMD_BASE: ${CMD_BASE}"
  echo "CMD_REMOTE_PLATFORM: ${CMD_REMOTE_PLATFORM}"
  echo "CMD_REMOTE_OUTPUT: ${CMD_REMOTE_OUTPUT}"
  echo "CMD_SUFFIX: ${CMD_SUFFIX}"
  echo "DOCKER_RUN_DIR: ${DOCKER_RUN_DIR}"
  echo ""
  echo "CMD_PUSH: ${CMD_PUSH}"
  echo ""
  bash -c "cd ${DOCKER_RUN_DIR};${CMD_PUSH}"
fi

if [[ "${BUILD_LOCAL}" == 'TRUE' ]]; then
  echo ""
  echo "CMD_BASE: ${CMD_BASE}"
  echo "LOCAL_PLATFORM: ${LOCAL_PLATFORM}"
  echo "CMD_LOCAL_OUTPUT: ${CMD_LOCAL_OUTPUT}"
  echo "CMD_SUFFIX: ${CMD_SUFFIX}"
  echo "DOCKER_RUN_DIR: ${DOCKER_RUN_DIR}"
  echo ""
  echo "CMD_LOCAL: ${CMD_LOCAL}"
  echo ""
  bash -c "cd ${DOCKER_RUN_DIR};${CMD_LOCAL}"
fi
