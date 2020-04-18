#!/bin/bash -eu
CONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"; pwd)" # Figure out where the script is running

# run semver-from-git.sh
GIT_COMMIT_HASH=$(git rev-parse --short HEAD)

export GIT_COMMIT_HASH=$GIT_COMMIT_HASH
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
  export PRIVATE_SUBNET_1="subnet-fd3a2e9a"
  export PRIVATE_SUBNET_2="subnet-940384cc"
  export PUBLIC_SUBNET_1="subnet-0d632e0ab1a0ac35b"
  export PUBLIC_SUBNET_2="subnet-0740979d04cee7bf7"
  export VPC="vpc-d61d31b1"
else
  # Development settings
  export AWS_ACCOUNT="980755931163"
  export STACK_SUFFIX="test"
  export CVAT_DOMAIN_NAME="label-test.datarock.com.au"
  export CLOUDFORMATION_TEMP_BUCKET_NAME="datarock-cvat-cloudformation-deploy-temp"
  export PRIVATE_SUBNET_1="subnet-290e1a4e"
  export PRIVATE_SUBNET_2="subnet-d877f080"
  export PUBLIC_SUBNET_1="subnet-09726019e5ffaffc7"
  export PUBLIC_SUBNET_2="subnet-04a66456615238488"
  export VPC="vpc-02311d65"
fi
