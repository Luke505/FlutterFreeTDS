#!/usr/bin/env docker build . --tag=sybase:17 --network=host --file

FROM debian:11 AS builder

RUN apt-get update && apt-get install -y libpcre3 zlib1g libssl1.1 libaio1

COPY ../files.gz/sqla17developerlinux.tar.gz /tmp/
WORKDIR /tmp

RUN tar -xzf sqla17developerlinux.tar.gz
RUN ./sqlany17/setup -I_accept_the_license_agreement -nogui -ss -type CREATE

FROM debian:11-slim

RUN apt-get update && apt-get install -y \
    libpcre3 \
    zlib1g \
    libssl1.1 \
    libaio1 \
 && rm -rf /var/lib/apt/lists/*

ARG RUN_USER=sybdba
ARG RUN_GROUP=sybdba
ARG RUN_UID=2000
ARG RUN_GID=2000
ENV HOME=/home/sybdba

RUN groupadd -r $RUN_GROUP -g $RUN_GID && useradd -u $RUN_UID -g $RUN_GROUP -d $HOME -s /bin/bash $RUN_USER

RUN mkdir $HOME
RUN chown -R $RUN_USER:$RUN_GROUP $HOME

RUN mkdir /db
RUN chown -R $RUN_USER:$RUN_GROUP /db

COPY --chown=$RUN_USER:$RUN_GROUP --from=builder /opt/sqlanywhere17 /opt/sqlanywhere17

WORKDIR $HOME
USER $RUN_USER

ENV SQLANYSAMP17=/opt/sqlanywhere17/samples
ENV SQLANY17=/opt/sqlanywhere17
ENV LD_LIBRARY_PATH=/opt/sqlanywhere17/lib64:/opt/sqlanywhere17/lib32:/opt/sqlanywhere17/bin64/jre180/lib/amd64/client:/opt/sqlanywhere17/bin64/jre180/lib/amd64/server:/opt/sqlanywhere17/bin64/jre180/lib/amd64:/opt/sqlanywhere17/bin64/jre180/lib/amd64/native_threads
ENV NODE_PATH=/opt/sqlanywhere17/node
ENV PATH=/opt/sqlanywhere17/bin64/jre180/bin:/opt/sqlanywhere17/bin64:/opt/sqlanywhere17/bin32:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
