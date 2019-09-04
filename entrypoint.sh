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

docker pull quay.io/keboola/developer-portal-cli-v2:latest

echo "B"
echo $TAG | /usr/bin/pcregrep -o '^(v?[0-9]+.[0-9]+.[0-9]+)'\$
echo "A"
export TARGET_TAG=`echo $TAG | /usr/bin/pcregrep -o '^(v?[0-9]+.[0-9]+.[0-9]+)'\$`
echo "TT: $TARGET_TAG"
if [ $TARGET_TAG -eq "" ]
then 
	TARGET_TAG=$TAG
fi

docker images
echo "Pushing image '${SOURCE_IMAGE}' with tag '${TAG}' (latest '${PUSH_LATEST}') to application '${APP_ID}' of vendor '${VENDOR}'. Using service account '${KBC_DEVELOPERPORTAL_USERNAME}'."

# login to the repository
export REPOSITORY=`docker run --rm -e KBC_DEVELOPERPORTAL_USERNAME -e KBC_DEVELOPERPORTAL_PASSWORD quay.io/keboola/developer-portal-cli-v2:latest ecr:get-repository ${VENDOR} ${APP_ID}`
eval $(docker run --rm \
  -e KBC_DEVELOPERPORTAL_USERNAME \
  -e KBC_DEVELOPERPORTAL_PASSWORD \
  quay.io/keboola/developer-portal-cli-v2:latest ecr:get-login ${VENDOR} ${APP_ID})

# tag and push
docker tag ${SOURCE_IMAGE}:latest ${REPOSITORY}:${TAG}
docker push ${REPOSITORY}:${TAG}

if [ $PUSH_LATEST -eq "true" ]
then
	echo "Pushing to latest tag"
	docker tag ${APP_IMAGE}:latest ${REPOSITORY}:latest
	docker push ${REPOSITORY}:latest
fi
