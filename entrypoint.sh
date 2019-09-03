#!/bin/sh -l
set -e

if [ $# -lt 6 ]
then
  echo "Some parameters are missing"
  exit 1
fi 
VENDOR=$1
APP_ID=$2
KBC_DEVELOPERPORTAL_USERNAME=$3
KBC_DEVELOPERPORTAL_PASSWORD=$4
TAG=$5
SOURCE_IMAGE=$6

docker pull quay.io/keboola/developer-portal-cli-v2:latest
docker images
echo "docker run --rm -e KBC_DEVELOPERPORTAL_USERNAME -e KBC_DEVELOPERPORTAL_PASSWORD quay.io/keboola/developer-portal-cli-v2:latest ecr:get-repository ${VENDOR} ${APP_ID}"
export REPOSITORY=`docker run --rm -e KBC_DEVELOPERPORTAL_USERNAME -e KBC_DEVELOPERPORTAL_PASSWORD quay.io/keboola/developer-portal-cli-v2:latest ecr:get-repository ${VENDOR} ${APP_ID}`
docker tag ${SOURCE_IMAGE}:latest ${REPOSITORY}:${TAG}
echo "Repository: ${REPOSITORY}"
eval $(docker run --rm \
  -e KBC_DEVELOPERPORTAL_USERNAME \
  -e KBC_DEVELOPERPORTAL_PASSWORD \
  quay.io/keboola/developer-portal-cli-v2:latest ecr:get-login ${VENDOR} ${APP_ID})
