#!/usr/bin/env docker build . --tag=sybase:17 --network=host --file

FROM ubuntu:23.10

RUN apt update && apt -y install build-essential libpcre3 libpcre3-dev zlib1g zlib1g-dev libssl-dev wget

ARG RUN_USER=sybdba
ARG RUN_GROUP=sybdba
ARG RUN_UID=2000
ARG RUN_GUI=2000
ENV HOME=/home/sybdba

RUN groupadd -r $RUN_GROUP -g $RUN_GUI && useradd -u $RUN_UID -g $RUN_GROUP -d $HOME -s /bin/bash $RUN_USER

RUN mkdir $HOME
RUN chown -R $RUN_USER:$RUN_GROUP $HOME

RUN mkdir /opt/sqlanywhere17
RUN chown -R $RUN_USER:$RUN_GROUP /opt/sqlanywhere17

RUN mkdir /db
RUN chown -R $RUN_USER:$RUN_GROUP /db

WORKDIR $HOME
USER $RUN_USER

COPY --chown=500:500 installer ./installer
RUN tar -xvf ./installer/sqlany17.tar -C ./
RUN ./sqlany17/setup -I_accept_the_license_agreement -nogui -ss -type CREATE
