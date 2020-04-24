#!/usr/bin/env bash
export PROXY=${PROXY:-""}
export PHP_VERSION='7.3'
export IMAGE_NAME=haakco/ubuntu2004-php73
./baseBuild.sh
