#!/bin/bash
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -e HOST_IP=$1 -e ZOOKEEPER=$2 -i -t enow/kafka /bin/bash
