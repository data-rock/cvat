#!/bin/bash -eu
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"; pwd)"
. "$SCRIPT_DIR"/lib/robust-bash.sh
. "$SCRIPT_DIR"/config.sh

require_env_var GIT_SEMVER_FROM_TAG
require_env_var EXPECT_AWS_ACCOUNT
require_env_var DEV_ECR_IMAGE

if [ ! -z "${PARKIT_DEPLOY_PRODUCTION-}" ]; then
  echo "🌳 🚨🚨🚨 Pushing PRODUCTION to ECR 🚨🚨🚨"
  export ECR_IMAGE="parkit/parkit-prod"
else
  echo "🌳 🌳🌳🌳 Pushing Development to ECR 🌳🌳🌳"
  export ECR_IMAGE="$DEV_ECR_IMAGE"
fi

echo "🌳 Building Dockerfile for $GIT_SEMVER_FROM_TAG"
docker build -t "$ECR_IMAGE" --build-arg PARK_IT_VALET_APP_VERSION="$GIT_SEMVER_FROM_TAG" .