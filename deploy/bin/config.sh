#!/bin/bash -eu
CONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"; pwd)" # Figure out where the script is running

export STACK_PREFIX="cvat"
export AWS_DEFAULT_REGION=ap-southeast-2
export CVAT_IMAGE="datarock/cvat"
export CVAT_UI_IMAGE="datarock/cvat_ui"

if [ ! -z "${DEPLOY_PRODUCTION-}" ]; then
  # Production settings
  export AWS_ACCOUNT="492445691754"
  export STACK_SUFFIX="prod"
  export CVAT_DOMAIN_NAME="label.datarock.com.au"
  export CLOUDFORMATION_TEMP_BUCKET_NAME="datarock-cvat-cloudformation-deploy-prod-temp"
else
  # Development settings
  export AWS_ACCOUNT="980755931163"
  export STACK_SUFFIX="test"
  export CVAT_DOMAIN_NAME="label-test.datarock.com.au"
  export CLOUDFORMATION_TEMP_BUCKET_NAME="datarock-cvat-cloudformation-deploy-temp"
fi
