#!/usr/bin/env bash
export PROXY=${PROXY:-""}
export BASE_UBUNTU_VERSION='ubuntu:20.04'
export PHP_VERSION='5.6'
export IMAGE_NAME='haakco/ubuntu2004-php56'
./baseBuild.sh
docker push "${IMAGE_NAME}"
