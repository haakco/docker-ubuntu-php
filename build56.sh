#!/usr/bin/env bash
export PROXY=${PROXY:-""}
export PHP_VERSION='5.6'
export IMAGE_NAME=haakco/ubuntu2004-php56
./baseBuild.sh
