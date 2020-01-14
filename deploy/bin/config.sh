#!/bin/bash -eu
CONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"; pwd)" # Figure out where the script is running

# We're not running in codebuild
$("$CONFIG_DIR"/semver-from-git.sh)

export STACK_PREFIX="cvat"
export AWS_DEFAULT_REGION=ap-southeast-2
export CLOUDFORMATION_TEMP_BUCKET_NAME="datarock-cvat-cloudformation-deploy-temp"
export CVAT_IMAGE_REPO="datarock/cvat"
export CVAT_UI_IMAGE_REPO="datarock/cvat_ui"

if [ ! -z "${DEPLOY_PRODUCTION-}" ]; then
  # Production settings
  export EXPECT_AWS_ACCOUNT="492445691754"
else
  # Development settings
  export EXPECT_AWS_ACCOUNT="980755931163"
fi

if [ ! -z "${DEPLOY_PRODUCTION-}" ]; then
  # Production settings
  export STACK_SUFFIX="prod"
else
  # Development settings
  export STACK_SUFFIX="test"
fi
