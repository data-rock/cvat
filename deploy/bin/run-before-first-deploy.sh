#!/bin/bash -eu

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"; pwd)" # Figure out where the script is running
. "$SCRIPT_DIR"/robust-bash.sh
. "$SCRIPT_DIR"/config.sh

# make sure aws cli is installed
require_binary aws

require_env_var CLOUDFORMATION_TEMP_BUCKET_NAME

# Determine the stack name
STACK_NAME="${STACK_PREFIX}"-"$STACK_SUFFIX"

echo "🌳 --stack-name $STACK_NAME"

TEMPLATE_FILE="$SCRIPT_DIR/../cloudformation/deploy.yml"
PACKAGED_TEMPLATE_FILE="$SCRIPT_DIR/../cloudformation/$(basename "$TEMPLATE_FILE" .yml)".packaged.yml

# Determine the parameters
PARAMETER_FILE="$SCRIPT_DIR/../cloudformation/parameters_$STACK_SUFFIX.json"
PARAMETER_OVERRIDES=$(jq -r '.Parameters
         | to_entries
         | map("\(.key)=\(.value)")
         | join(" ")' $PARAMETER_FILE)
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
      $PARAMETER_OVERRIDES \
      CreateCvatApiService=false \
      CreateCvatUIService=false \
    --stack-name "$STACK_NAME" \
    --capabilities CAPABILITY_IAM \
    --capabilities CAPABILITY_NAMED_IAM \
    "$@"