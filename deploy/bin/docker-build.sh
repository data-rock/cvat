#!/bin/bash -eu

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"; pwd)"
. "$SCRIPT_DIR"/robust-bash.sh

require_env_var GIT_COMMIT_HASH
require_env_var AWS_ACCOUNT
require_env_var CVAT_IMAGE
require_env_var CVAT_UI_IMAGE
require_env_var CVAT_DOMAIN_NAME

require_binary aws

# build CVAT_UI_IMAGE
echo "🌳 Building Dockerfile for $CVAT_UI_IMAGE"
docker build -t "$CVAT_IMAGE" \
             -f Dockerfile \
             --build-arg TF_ANNOTATION="no" \
             --build-arg AUTO_SEGMENTATION="no" \
             --build-arg USER="django" \
             --build-arg DJANGO_CONFIGURATION="production" \
             --build-arg WITH_TESTS="no" \
             --build-arg TZ="Etc/UTC" \
             --build-arg OPENVINO_TOOLKIT="yes" \
             --build-arg WITH_DEXTR="yes" \
             .
# build CVAT_UI_IMAGE
echo "🌳 Building Dockerfile for $CVAT_UI_IMAGE"
docker build -t "$CVAT_UI_IMAGE" \
             -f Dockerfile.ui \
             --build-arg REACT_APP_API_URL="https://$CVAT_DOMAIN_NAME:8443" \
             .

echo "🌳 Logging in to docker"
$(aws ecr get-login --no-include-email --region ap-southeast-2)

CVAT_REPO_URL="$AWS_ACCOUNT.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$CVAT_IMAGE"
CVAT_UI_REPO_URL="$AWS_ACCOUNT.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$CVAT_UI_IMAGE"

echo "🌳 Tagging and pushing :latest"

# Tag images
docker tag "$CVAT_IMAGE" "$CVAT_REPO_URL:latest"
docker tag "$CVAT_UI_IMAGE" "$CVAT_UI_REPO_URL:latest"

# Push images
docker push "$CVAT_REPO_URL:latest"
docker push "$CVAT_UI_REPO_URL:latest"
