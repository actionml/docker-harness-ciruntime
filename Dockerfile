FROM actionml/vw:10bd09ab-jni

ARG version
LABEL com.actionml.scala.vendor=ActionML \
      com.actionml.scala.version=$version

ENV SCALA_VERSION=${version} \
    SCALA_HOME=/usr/share/scala

# Note: overrides JAVA_HOME set by actionml/vw:jni
ENV JAVA_HOME /usr/lib/jvm/java-1.8-openjdk


## Install OpenJDK8 Java SDK
#
RUN set -x && apk add --update --no-cache openjdk8 && \
      [ "$JAVA_HOME" = "$(docker-java-home)" ]


## Install Scala
#
#  Note: specific version MUST BE COMPATIBLE with openjdk 1.8!
RUN apk add --no-cache --virtual=.deps tar && \
    curl -#fL -o /tmp/scala.tgz \
      "https://downloads.lightbend.com/scala/${SCALA_VERSION}/scala-${SCALA_VERSION}.tgz" && \
    mkdir $SCALA_HOME && cd $SCALA_HOME && \
    tar xzf /tmp/scala.tgz --strip-component=1 && \
  # odd but scala this stub (omits "cat: ...release: No such file or directory")
    java -version &> ${JAVA_HOME}/release && \
  # link to /usr/bin
    ln -s ./bin/* /usr/bin/ && \
  # cleanup
    rm -r man doc ./bin/*.bat /tmp/* && \
    apk del .deps


## Install Python3 runtime
#
RUN apk add --no-cache --update python3 && \
    python3 -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip3 install --upgrade pip setuptools && \
        ln -sf /usr/bin/python3 /usr/bin/python && \
        ln -sf /usr/bin/python3-config /usr/bin/python-config && \
        ln -sf /usr/bin/pydoc3 /usr/bin/pydoc && \
        ln -sf /usr/bin/pip3 /usr/bin/pip && \
    rm -r /root/.cache


## Install SDK
#
#  note: minimum to begin with
RUN  apk add --no-cache maven
