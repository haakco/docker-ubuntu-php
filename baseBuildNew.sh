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

docker context create blue
docker buildx create blue --name blue --driver docker-container --use
docker buildx use blue
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
docker buildx create --name multiarch --driver docker-container --use
docker run --privileged --rm tonistiigi/binfmt --install all
docker buildx inspect --bootstrap

#
CMD='docker buildx build --push --platform  linux/arm/v7,linux/arm64,linux/amd64 --build-arg BASE_UBUNTU_VERSION='"${BASE_UBUNTU_VERSION}"' --build-arg PHP_VERSION='"${PHP_VERSION}"' --build-arg PROXY='"${PROXY}"' --tag '"${IMAGE_NAME}"' .'
#CMD='docker buildx build --push --platform  linux/amd64 --build-arg BASE_UBUNTU_VERSION='"${BASE_UBUNTU_VERSION}"' --build-arg PHP_VERSION='"${PHP_VERSION}"' --build-arg PROXY='"${PROXY}"' --tag '"${IMAGE_NAME}"' .'

echo "Build commmand: ${CMD}"
echo ""
${CMD}
