#!/usr/bin/env bash
export PROXY=${PROXY:-""}
export PHP_VERSION='7.1'
export IMAGE_NAME=haakco/ubuntu2004-php71
./baseBuild.sh
