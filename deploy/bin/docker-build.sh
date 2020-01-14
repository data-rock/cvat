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
echo "🌳 Building Dockerfile for $CVAT_UI_IMAGE:$GIT_COMMIT_HASH"
docker build -t "$CVAT_IMAGE" \
             -f Dockerfile \
             --build-arg TF_ANNOTATION="no" \
             --build-arg AUTO_SEGMENTATION="no" \
             --build-arg USER="django" \
             --build-arg DJANGO_CONFIGURATION="production" \
             --build-arg WITH_TESTS="no" \
             --build-arg TZ="Etc/UTC" \
             --build-arg OPENVINO_TOOLKIT="no" \
             .
# build CVAT_UI_IMAGE
echo "🌳 Building Dockerfile for $CVAT_UI_IMAGE:$GIT_COMMIT_HASH"
docker build -t "$CVAT_UI_IMAGE" \
             -f Dockerfile.ui \
             --build-arg REACT_APP_API_PROTOCOL="https" \
             --build-arg REACT_APP_API_HOST=$CVAT_DOMAIN_NAME \
             --build-arg REACT_APP_API_PORT="8443" \
             .

echo "🌳 Logging in to docker"
$(aws ecr get-login --no-include-email --region ap-southeast-2)

CVAT_REPO_URL="$AWS_ACCOUNT.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$CVAT_IMAGE"
CVAT_UI_REPO_URL="$AWS_ACCOUNT.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$CVAT_UI_IMAGE"

echo "🌳 Tagging and pushing :$GIT_COMMIT_HASH"

# Tag images
docker tag "$CVAT_IMAGE" "$CVAT_REPO_URL:$GIT_COMMIT_HASH"
docker tag "$CVAT_UI_IMAGE" "$CVAT_UI_REPO_URL:$GIT_COMMIT_HASH"

# Push images
docker push "$CVAT_REPO_URL:$GIT_COMMIT_HASH"
docker push "$CVAT_UI_REPO_URL:$GIT_COMMIT_HASH"
