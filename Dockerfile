FROM jenkins/jenkins:2.189-alpine
MAINTAINER Alex Alter-Pesotskiy <33gri@bk.ru>

# Install plugins from plugins.txt
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt

# Install jenkins-job-builder
USER root
ENV BUILDER_VERSION 2.10.0
RUN apk update && apk add wget && apk add curl && apk add git && rm -rf /var/cache/apk/* && rm -rf /var/lib/apt/lists/*
RUN apk add --no-cache python
RUN apk add --no-cache py-pip
RUN pip install jenkins-job-builder==${BUILDER_VERSION}
USER jenkins
