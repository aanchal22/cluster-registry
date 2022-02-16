#!/usr/bin/env bash
# exit immediately when a command fails
set -e
# only exit with zero if all commands of the pipeline exit successfully
set -o pipefail

REGISTRY="ghcr.io"

export IMAGE_APISERVER="${IMAGE_APISERVER:-"adobe/cluster-registry-api"}"
export IMAGE_CLIENT="${IMAGE_CLIENT:-"adobe/cluster-registry-client"}"
export TAG="${GITHUB_REF##*/}"

IMAGE_SUFFIX="-dev"

if [[ "$TAG" =~ ^v[0-9]+\.[0-9]+ ]] || [ "${TAG}" == "main" ]; then
	IMAGE_SUFFIX=""
else
	TAG="v$(cat "$(git rev-parse --show-toplevel)/VERSION")-$(git rev-parse --short HEAD)"
fi

APISERVER="${REGISTRY}/${IMAGE_APISERVER}${IMAGE_SUFFIX}"
CLIENT="${REGISTRY}/${IMAGE_CLIENT}${IMAGE_SUFFIX}"

for img in ${APISERVER} ${CLIENT}; do
	echo "Building image: $img:$TAG"
done

make --always-make image TAG="${TAG}"

docker tag "${IMAGE_APISERVER}:${TAG}" "${APISERVER}:${TAG}"
docker tag "${IMAGE_CLIENT}:${TAG}" "${CLIENT}:${TAG}"

docker push "${APISERVER}:${TAG}"
docker push "${CLIENT}:${TAG}"