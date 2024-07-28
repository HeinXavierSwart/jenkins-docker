#!/bin/bash
#
#
set +e

# Check if the 'jenkins' network is running
network_status=$(docker network ls --filter name=^jenkins$ --format "{{.Name}}")

# If the network is not running, create it
if [ -z "$network_status" ]; then
    echo "Network 'jenkins' is not running. Starting the network..."
    docker network create jenkins
    if [ $? -eq 0 ]; then
        echo "Network 'jenkins' has been created successfully."
    else
        echo "Failed to create the 'jenkins' network."
        exit 1
    fi
else
    echo "Network 'jenkins' is already running."
fi

echo "Starting jenkins-blueocean"

docker run \
  --name jenkins-blueocean \
  --restart=on-failure \
  --detach \
  --network jenkins \
  --env DOCKER_HOST=tcp://docker:2376 \
  --env DOCKER_CERT_PATH=/certs/client \
  --env DOCKER_TLS_VERIFY=1 \
  --publish 8080:8080 \
  --publish 50000:50000 \
  --volume jenkins-data:/var/jenkins_home \
  --volume jenkins-docker-certs:/certs/client:ro \
  jenkins-blueocean

set -e
