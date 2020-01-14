#!/bin/bash -eu

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"; pwd)" # Figure out where the script is running
. "$SCRIPT_DIR"/robust-bash.sh
. "$SCRIPT_DIR"/config.sh

# build the images
$("$SCRIPT_DIR"/docker-build.sh)

# push the images
$("$SCRIPT_DIR"/docker-push.sh)

# make sure aws cli is installed
require_binary aws

require_env_var GIT_SEMVER_FROM_TAG

# define the variables
STACK_PREFIX='cvat'
CLOUDFORMATION_TEMP_BUCKET_NAME='datarock-cvat-cloudformation-deploy-temp'

# Determine the stack name
STACK_NAME="${STACK_PREFIX}"-"$STACK_SUFFIX"

echo "🌳 --stack-name $STACK_NAME"

TEMPLATE_FILE="$SCRIPT_DIR/../cloudformation/deploy.yml"
PACKAGED_TEMPLATE_FILE="$SCRIPT_DIR/../cloudformation/$(basename "$TEMPLATE_FILE" .yml)".packaged.yml

# Determine the parameters
PARAMETER_FILE="$SCRIPT_DIR/../cloudformation/parameters_$STACK_SUFFIX.yml"
PARAMETER_OVERRIDES=$(sed -e 's/"//g; s/:[^:\/\/]/=/g; s/$/"/g; s/ *=/=/g; s/^/"/g' $PARAMETER_FILE)
echo " 🌳 --parameter-overrides $PARAMETER_OVERRIDES"

# Ensure that the deployment bucket exists
if ! aws s3api head-bucket --bucket "$CLOUDFORMATION_TEMP_BUCKET_NAME" ; then
  echo "🌳 Creating S3 bucket '$CLOUDFORMATION_TEMP_BUCKET_NAME' for deployment"
  aws s3api create-bucket --bucket "$CLOUDFORMATION_TEMP_BUCKET_NAME"  --create-bucket-configuration LocationConstraint=ap-southeast-2
else
  echo "🌳 Using S3 bucket '$CLOUDFORMATION_TEMP_BUCKET_NAME' for deployment"
fi

echo "🌳 Packaging $TEMPLATE_FILE into $PACKAGED_TEMPLATE_FILE (and uploading to S3)"
aws cloudformation package  --template-file "$TEMPLATE_FILE" \
    --s3-bucket "$CLOUDFORMATION_TEMP_BUCKET_NAME" \
    --output-template-file "$PACKAGED_TEMPLATE_FILE"

echo "🌳 Deploying $STACK_NAME"
aws cloudformation deploy --no-fail-on-empty-changeset \
    --template-file "$PACKAGED_TEMPLATE_FILE" \
    --parameter-overrides \
      CvatImageTag=$GIT_SEMVER_FROM_TAG
      $PARAMETER_OVERRIDES \
    --stack-name "$STACK_NAME" \
    --capabilities CAPABILITY_IAM \
    --capabilities CAPABILITY_NAMED_IAM "$@"
