[![Docker Pulls](https://img.shields.io/docker/pulls/enow/kafka.svg)](https://hub.docker.com/r/enow/kafka/)
[![Docker Stars](https://img.shields.io/docker/stars/enow/kafka.svg)](https://hub.docker.com/r/enow/kafka/)
<!-- [![](https://badge.imagelayers.io/wurstmeister/kafka:latest.svg)](https://imagelayers.io/?images=wurstmeister/kafka:latest) -->

docker-kafka
============

Dockerfile for [Apache Kafka](http://kafka.apache.org/)<sub>0.9.0.1</sub> Referenced by [https://github.com/wurstmeister/kafka-docker](https://github.com/wurstmeister/kafka-docker)

The image is available directly from https://registry.hub.docker.com/

## Pre-Requisites

- install [docker-compose](https://docs.docker.com/compose/install/)
- modify the ```KAFKA_ADVERTISED_HOST_NAME``` in ```docker-compose.yml``` to match your docker host IP <br/>
(Note: Do not use localhost or 127.0.0.1 as the host ip if you want to run multiple brokers.)
- if you want to customise any Kafka parameters, simply add them as environment variables in ```docker-compose.yml```, e.g. in order to increase the ```message.max.bytes``` parameter set the environment to ```KAFKA_MESSAGE_MAX_BYTES: 2000000```. To turn off automatic topic creation set ```KAFKA_AUTO_CREATE_TOPICS_ENABLE: 'false'```

## Usage

Start a cluster:

    docker-compose up -d

Add more brokers:

    docker-compose scale kafka=3

Destroy a cluster:

    docker-compose stop

## Note

The default ```docker-compose.yml``` should be seen as a starting point. By default each broker will get a new port number and broker id on restart. Depending on your use case this might not be desirable. If you need to use specific ports and broker ids, modify the docker-compose configuration accordingly, e.g. [docker-compose-single-broker.yml](https://github.com/Writtic/docker-kafka/blob/master/docker-compose-single-broker.yml):

- ```docker-compose -f docker-compose-single-broker.yml up```

## Broker IDs

If you don't specify a broker id in your docker-compose file, it will automatically be generated (see [issues.apache.org/jira/browse/KAFKA-1070](https://issues.apache.org/jira/browse/KAFKA-1070). This allows scaling up and down. In this case it is recommended to use the ```--no-recreate``` option of ```docker-compose``` to ensure that containers are not re-created and thus keep their names and ids.


## Automatically create topics

If you want to have kafka-docker automatically create topics in Kafka during
creation, a ```KAFKA_CREATE_TOPICS``` environment variable can be
added in ```docker-compose.yml```.

Here is an example snippet from ```docker-compose.yml```:

        environment:
          KAFKA_CREATE_TOPICS: "Topic1:2:3,Topic2:3:1"

```Topic 1``` will have 2 partition and 3 replicas, <br/>```Topic 2``` will have 3 partition and 1 replica.

##Advertised hostname

You can configure the advertised hostname in different ways

1. explicitly, using ```KAFKA_ADVERTISED_HOST_NAME```
2. via a command, using ```HOSTNAME_COMMAND```, e.g. ```HOSTNAME_COMMAND: "route -n | awk '/UG[ \t]/{print $$2}'"```

When using commands, make sure you review the "Variable Substitution" section in [https://docs.docker.com/compose/compose-file/](https://docs.docker.com/compose/compose-file/)

If ```KAFKA_ADVERTISED_HOST_NAME``` is specified, it takes precedence over ```HOSTNAME_COMMAND```

For AWS deployment, you can use the Metadata service to get the container host's IP:
```
HOSTNAME_COMMAND=wget -t3 -T2 -qO-  http://169.254.169.254/latest/meta-data/local-ipv4
```
Reference: http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-metadata.html

## Tutorial

### Setup

1. Install [Docker](https://docs.docker.com/docker-for-mac/#h_installation)
2. Install [Docker-Compose](https://docs.docker.com/compose/install/)
3. Update ```docker-compose.yml``` with your docker host IP (```KAFKA_ADVERTISED_HOST_NAME```)
4. If you want to customise any Kafka parameters, simply add them as environment variables in ```docker-compose.yml```.
For example:
- to increase the ```message.max.bytes``` parameter add ```KAFKA_MESSAGE_MAX_BYTES: 2000000``` to the ```environment``` section.
- to turn off automatic topic creation set ```KAFKA_AUTO_CREATE_TOPICS_ENABLE: 'false'```
5. Start the cluster
```
$ docker-compose up
```
e.g. to start a cluster with two brokers
```
$ docker-compose scale kafka=2
```
This will start a single zookeeper instance and two Kafka instances. You can use ```docker-compose ps``` to show the running instances. If you want to add more Kafka brokers simply increase the value passed to ```docker-compose scale kafka=n```

### Kafka Shell

You can interact with your Kafka cluster via the ```start-kafka-shell.sh```:
```
$ start-kafka-shell.sh <DOCKER_HOST_IP> <ZK_HOST:ZK_PORT>
```

### Testing
To test your setup, start a shell, create a topic and start a producer:

    $ $KAFKA_HOME/bin/kafka-topics.sh --create --topic topic --partitions 4 --zookeeper $ZK --replication-factor 2
    $ $KAFKA_HOME/bin/kafka-topics.sh --describe --topic topic --zookeeper $ZK
    $ $KAFKA_HOME/bin/kafka-console-producer.sh --topic=topic --broker-list=`broker-list.sh`

Start another shell and start a consumer:

    $ $KAFKA_HOME/bin/kafka-console-consumer.sh --topic=topic --zookeeper=$ZK

### Running kafka-docker on a Mac:
Install the [Docker Toolbox](https://www.docker.com/products/docker-toolbox) or ```brew install docker-machine``` then set ```KAFKA_ADVERTISED_HOST_NAME``` to the IP that is returned by the ```docker-machine ip``` command.

Troubleshooting:
- By default a Kafka broker uses 1GB of memory, so if you have trouble starting a broker, check ```docker-compose logs```/```docker logs``` for the container and make sure you've got enough memory available on your host.
- Do not use localhost or 127.0.0.1 as the host IP if you want to run multiple brokers otherwise the brokers won't be able to communicate
