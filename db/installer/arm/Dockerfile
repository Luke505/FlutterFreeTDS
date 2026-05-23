#!/usr/bin/env docker build . --platform=linux/arm/v7 --tag=sybase:17 --network=host --file

FROM ubuntu:24.04

RUN apt update && apt -y install build-essential libpcre3 libpcre3-dev zlib1g zlib1g-dev libssl-dev wget file

ARG RUN_USER=sybdba
ARG RUN_GROUP=sybdba
ARG RUN_UID=2000
ARG RUN_GID=2000
ENV HOME=/home/sybdba

RUN groupadd -r $RUN_GROUP -g $RUN_GID && useradd -u $RUN_UID -g $RUN_GROUP -d $HOME -s /bin/bash $RUN_USER

RUN mkdir $HOME
RUN chown -R $RUN_USER:$RUN_GROUP $HOME

RUN mkdir /opt/sqlanywhere
RUN chown -R $RUN_USER:$RUN_GROUP /opt/sqlanywhere

RUN mkdir /db
RUN chown -R $RUN_USER:$RUN_GROUP /db

RUN test -e /lib/ld-linux.so.3 || ln -s /lib/ld-linux-armhf.so.3 /lib/ld-linux.so.3

WORKDIR $HOME
USER $RUN_USER

COPY --chown=500:500 ../files.gz/new.sqla17developerlinuxarm.tar.gz ./sqla17developerlinuxarm.tar.gz
RUN tar -xvf ./sqla17developerlinuxarm.tar.gz -C ./
RUN ./sqlany17/setup -I_accept_the_license_agreement -nogui -ss -type CREATE

ENV SQLANYSAMP=/opt/sqlanywhere/samples
ENV SQLANY17=/opt/sqlanywhere
ENV LD_LIBRARY_PATH=/opt/sqlanywhere/lib32
ENV NODE_PATH=/opt/sqlanywhere/node
ENV SQLANY17RES=/opt/sqlanywhere/res
ENV PATH=/opt/sqlanywhere/bin32:/opt/sqlanywhere/bin64:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV SQLANY=/opt/sqlanywhere
