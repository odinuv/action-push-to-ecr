#!/bin/sh -l
set -e

if [ $# -lt 6 ]
then
  echo "Some parameters are missing"
  exit 1
fi 
VENDOR=$1
APP_ID=$2
export KBC_DEVELOPERPORTAL_USERNAME=$3
export KBC_DEVELOPERPORTAL_PASSWORD=$4
TAG=$5
SOURCE_IMAGE=$6
PUSH_LATEST=$7
IMAGE_NAME_SUFFIX=$8

docker pull quay.io/keboola/developer-portal-cli-v2:latest

export TARGET_TAG=`echo $TAG | /usr/bin/pcregrep -o1 '^refs/tags/(v?[0-9]+.[0-9]+.[0-9]+)$'`
if [ "$TARGET_TAG" = "" ]
then 
	TARGET_TAG=$TAG
fi

docker images
echo "Pushing image '${SOURCE_IMAGE}' with tag '${TARGET_TAG}' (latest '${PUSH_LATEST}') to application '${APP_ID}' of vendor '${VENDOR}'. Using service account '${KBC_DEVELOPERPORTAL_USERNAME}'."

# login to the repository
export REPOSITORY=`docker run --rm -e KBC_DEVELOPERPORTAL_USERNAME -e KBC_DEVELOPERPORTAL_PASSWORD quay.io/keboola/developer-portal-cli-v2:latest ecr:get-repository ${VENDOR} ${APP_ID}`
eval $(docker run --rm \
  -e KBC_DEVELOPERPORTAL_USERNAME \
  -e KBC_DEVELOPERPORTAL_PASSWORD \
  quay.io/keboola/developer-portal-cli-v2:latest ecr:get-login ${VENDOR} ${APP_ID})

# tag and push
docker tag ${SOURCE_IMAGE}:latest ${REPOSITORY}${IMAGE_NAME_SUFFIX}:${TARGET_TAG}
docker push ${REPOSITORY}${IMAGE_NAME_SUFFIX}:${TARGET_TAG}

if [ "$PUSH_LATEST" = "true" ]
then
	echo "Pushing to latest tag"
	docker tag ${SOURCE_IMAGE}:latest ${REPOSITORY}${IMAGE_NAME_SUFFIX}:latest
	docker push ${REPOSITORY}${IMAGE_NAME_SUFFIX}:latest
fi
