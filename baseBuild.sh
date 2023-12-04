#!/usr/bin/env bash
export BUILD_IMAGE_NAME="${BUILD_IMAGE_NAME}"
export BUILD_IMAGE_TAG="${BUILD_IMAGE_TAG}"
export DOCKER_FILE="${DOCKER_FILE:-"Dockerfile"}"
export EXTRA_FLAG="${EXTRA_FLAG}"

export DOCKER_BUILDKIT=1

CACHE_FROM=""
#export CACHE_DIR="/tmp/mn-server-test-cache"
#export CACHE_FROM="${CACHE_FROM} --cache-from=type=local,src=${CACHE_DIR}"
#export CACHE_FROM="${CACHE_FROM} --cache-from=type=registry,ref=${BUILD_IMAGE_NAME}:buildcache"
##export CACHE_FROM="${CACHE_FROM} --cache-to=type=local,dest=${CACHE_DIR}"
#export CACHE_FROM="${CACHE_FROM} --cache-to=type=registry,ref=${BUILD_IMAGE_NAME}:buildcache,mode=max"

#BUILD_TYPE_FLAG=" --load "
BUILD_TYPE_FLAG=" --push "
export BUILD_TYPE_FLAG

PLATFORM=""
PLATFORM=" --platform  linux/arm64/v8,linux/amd64 "
#PLATFORM=" --platform  linux/arm64/v8 "
#PLATFORM=" --platform linux/amd64 "
export PLATFORM

CMD='docker buildx build --pull --rm '"${PLATFORM}"' '"${BUILD_TYPE_FLAG}"' '"${CACHE_FROM}"' --file '"${DOCKER_FILE}"' -t '"${BUILD_IMAGE_NAME}:${BUILD_IMAGE_TAG}"' '"${EXTRA_FLAG}"' .'

echo "Build command: ${CMD}"
echo ""
${CMD}


DOCKER_PULL_CMD='docker pull '"${BUILD_IMAGE_NAME}"':'"${BUILD_IMAGE_TAG}"''
echo "Pull command: ${DOCKER_PULL_CMD}"
${DOCKER_PULL_CMD}


if [[ "${BUILD_IMAGE_NAME_OLD}" != "" ]]; then
  CMD='docker buildx build --pull --rm '"${PLATFORM}"' '"${BUILD_TYPE_FLAG}"' '"${CACHE_FROM}"' --file '"${DOCKER_FILE}"' -t '"${BUILD_IMAGE_NAME_OLD}:${BUILD_IMAGE_TAG}"' '"${EXTRA_FLAG}"' .'
  echo "Build command: ${CMD}"
  echo ""
  ${CMD}

  DOCKER_PULL_CMD='docker pull '"${BUILD_IMAGE_NAME_OLD}"':'"${BUILD_IMAGE_TAG}"''
  echo "Pull command: ${DOCKER_PULL_CMD}"
  ${DOCKER_PULL_CMD}
fi
