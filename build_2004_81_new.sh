#!/usr/bin/env bash
export PROXY="${PROXY:-""}"
export BASE_UBUNTU_VERSION='ubuntu:20.04'
export PHP_VERSION='8.1'
export IMAGE_NAME='haakco/ubuntu2004-php81'
./baseBuildNew.sh
