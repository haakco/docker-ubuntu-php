#!/usr/bin/env bash
export PROXY="${PROXY:-''}"
export PHP_VERSION="${PHP_VERSION:-'7.4'}"
export IMAGE_NAME="${IMAGE_NAME:-'haakco/ubuntu2004-php74'}"
export BASE_UBUNTU_VERSION="${BASE_UBUNTU_VERSION:-'ubuntu:20.04'}"

echo "Building From: ${BASE_UBUNTU_VERSION}"
echo "Building PHP: ${PHP_VERSION}"
echo "Proxy Set to: ${PROXY}"
echo "Tagged as : ${IMAGE_NAME}"
echo ""
echo ""

CMD='docker build --rm --build-arg BASE_UBUNTU_VERSION='"${BASE_UBUNTU_VERSION}"' --build-arg PHP_VERSION='"${PHP_VERSION}"' --build-arg PROXY='"${PROXY}"' -t '"${IMAGE_NAME}"' .'

echo "Build commmand: ${CMD}"
echo ""
${CMD}
