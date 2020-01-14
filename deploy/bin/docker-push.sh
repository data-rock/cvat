#!/bin/bash -eu
echo "🌳 Logging in to docker"
$(aws ecr get-login --no-include-email --region ap-southeast-2)

EXPECT_AWS_ACCOUNT='980755931163'

export ECR_REPO_URL="$EXPECT_AWS_ACCOUNT.dkr.ecr.ap-southeast-2.amazonaws.com/$ECR_IMAGE"
echo "🌳 Tagging and pushing :latest"

docker tag "$DEV_ECR_IMAGE" "$ECR_REPO_URL:latest"
docker push "$ECR_REPO_URL:latest"

if [ ! -z "${GIT_EXACT_TAG:-}" ] ; then
  echo "🌳 This is a tagged release 🎖"
  echo "🌳   - tagging and pushing :$GIT_EXACT_TAG"

  docker tag "$DEV_ECR_IMAGE" "$ECR_REPO_URL:$GIT_EXACT_TAG"
  docker push "$ECR_REPO_URL:$GIT_EXACT_TAG"
fi