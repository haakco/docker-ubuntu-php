#!/usr/bin/env bash
export PROXY="${PROXY:-""}"
export PHP_VERSION="${PHP_VERSION:-""}"
export IMAGE_NAME="${IMAGE_NAME}"

echo "Building PHP: ${PHP_VERSION}"
echo "Proxy Set to: ${PROXY}"
echo "Tagged as : ${IMAGE_NAME}"
echo ""
echo ""

CMD='docker build --rm --build-arg PHP_VERSION='"${PHP_VERSION}"' --build-arg PROXY='"${PROXY}"' -t '"${IMAGE_NAME}"' .'

echo "Build commmand: ${CMD}"
echo ""
${CMD}
