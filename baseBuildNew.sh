#!/usr/bin/env bash
export PROXY="${PROXY:-''}"
export PHP_VERSION="${PHP_VERSION:-'7.4'}"
export IMAGE_NAME="${IMAGE_NAME:-'haakco/ubuntu2004-php74'}"
export BASE_UBUNTU_VERSION="${BASE_UBUNTU_VERSION:-'ubuntu:20.04'}"
export DOCKER_BUILDKIT=1

echo "Building From: ${BASE_UBUNTU_VERSION}"
echo "Building PHP: ${PHP_VERSION}"
echo "Proxy Set to: ${PROXY}"
echo "Tagged as : ${IMAGE_NAME}"
echo ""
echo ""

eval  $(docker-machine env blue)

docker context create blue --default-stack-orchestrator=swarm --docker "host=${DOCKER_HOST},ca=${DOCKER_CERT_PATH}/ca.pem,cert=${DOCKER_CERT_PATH}/cert.pem,key=${DOCKER_CERT_PATH}/key.pem"
docker context use blue
docker buildx create blue --name blue --driver docker-container --use
docker buildx use blue
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
docker run --privileged --rm tonistiigi/binfmt --install all
docker buildx inspect --bootstrap

#
CMD='docker buildx build --push --platform  linux/arm/v7,linux/arm64,linux/amd64 --build-arg BASE_UBUNTU_VERSION='"${BASE_UBUNTU_VERSION}"' --build-arg PHP_VERSION='"${PHP_VERSION}"' --build-arg PROXY='"${PROXY}"' --tag '"${IMAGE_NAME}"' .'
#CMD='docker buildx build --push --platform  linux/amd64 --build-arg BASE_UBUNTU_VERSION='"${BASE_UBUNTU_VERSION}"' --build-arg PHP_VERSION='"${PHP_VERSION}"' --build-arg PROXY='"${PROXY}"' --tag '"${IMAGE_NAME}"' .'

echo "Build commmand: ${CMD}"
echo ""
${CMD}
