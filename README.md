# Apache Spark

An [Apache Spark](http://spark.apache.org/) container image. The image is meant to be used for creating an standalone cluster with multiple workers.

You can find it on dockerhub as `jacintoarias/spark-cluster` 

## Custom commands

This image contains a script named `start-spark` (included in the PATH). This script is used to initialize the master and the workers.

### Starting a master

To start a master run the following command:

```sh
start-spark master
```

### Starting a worker

To start a worker run the following command:

```sh
start-spark worker [MASTER]
```

## Creating a Cluster with Docker Compose

The easiest way to create a standalone cluster with this image is by using [Docker Compose](https://docs.docker.com/compose). The following snippet can be used as a `docker-compose.yml` for a simple cluster:

```YAML
version: "3"

services:
  master:
    image: jacintoarias/spark-cluster
    command: start-spark master
    hostname: master
    ports:
      - "7077:7077"
      - "8080:8080"
      - "4040:4040"
      - "50070:50070"
    volumes:
      - .:/home/spark

  worker:
    image: jacintoarias/spark-cluster
    command: start-spark worker master
    environment:
      SPARK_WORKER_CORES: 1
      SPARK_WORKER_MEMORY: 2g
    depends_on:
      - master
```

### Persistence

The image has a volume mounted at `/opt/hdfs`. To maintain states between restarts, mount a volume at this location. This should be done for the master and the workers.

### Scaling

If you wish to increase the number of workers scale the `worker` service by running the `scale` command like follows:

```sh
docker-compose scale worker=2
```

The workers will automatically register themselves with the master.
