#!/bin/bash
set -ex

# Build the Docker image
docker build -t feeder-build .

# Run tests in Docker with Bitrise Build Cache support
docker run --rm \
  -v ~/.gradle/init.d:/root/.gradle/init.d \
  feeder-build ./gradlew testFdroidDebug