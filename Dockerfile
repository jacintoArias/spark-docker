FROM singularities/hadoop:2.8
MAINTAINER Singularities

# Version
ENV SPARK_VERSION=2.4.3

# Set home
ENV SPARK_HOME=/usr/local/spark-$SPARK_VERSION

# Install dependencies
RUN apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install \
    -yq --no-install-recommends  \
      python python3 \
  && apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

# Install Spark
RUN mkdir -p "${SPARK_HOME}" \
  && export ARCHIVE=spark-$SPARK_VERSION-bin-without-hadoop.tgz \
  && export DOWNLOAD_PATH=apache/spark/spark-$SPARK_VERSION/$ARCHIVE \
  && curl -sSL https://mirrors.ocf.berkeley.edu/$DOWNLOAD_PATH | \
    tar -xz -C $SPARK_HOME --strip-components 1 \
  && rm -rf $ARCHIVE

# Install Additional software
RUN apt-get update \ 
    && apt-get install -y vim

# Configure Spark
COPY spark-env.sh $SPARK_HOME/conf/spark-env.sh

# Copy startup scripts
COPY start-spark /opt/util/bin/start-spark
COPY start-interactive.sh /opt/util/bin/start-interactive

# Configure user and environment
RUN adduser --disabled-password --gecos '' spark 
RUN mkdir -p /home/spark \
    && chown -R spark /home/spark \
    && chmod -R 700 /home/spark

WORKDIR /home/spark

ENV HDFS_USER=spark
ENV PATH=$PATH:$SPARK_HOME/bin
ENV SPARK_HOME=$SPARK_HOME 

# Add deprecated commands
# RUN echo '#!/usr/bin/env bash' > /usr/bin/master \
#   && echo 'start-spark master' >> /usr/bin/master \
#   && chmod +x /usr/bin/master \
#   && echo '#!/usr/bin/env bash' > /usr/bin/worker \
#   && echo 'start-spark worker $1' >> /usr/bin/worker \
#   && chmod +x /usr/bin/worker \
#   && chmod +x /opt/util/bin/prepare-env 

# Ports
EXPOSE 7077 8080 8081 4040