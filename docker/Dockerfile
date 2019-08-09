FROM jenkins/jenkins:2.189-alpine
MAINTAINER Alex Alter-Pesotskiy <33gri@bk.ru>

ENV CASC_JENKINS_CONFIG https://raw.githubusercontent.com/alter-al/jjb/master/configuration/jenkins.yaml

# Install Jenkins Plugins
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt

# Install tools
USER root
RUN apk update && apk add wget \
                          curl \
                          git \
                          ruby \
                          python \
                          py-pip
RUN rm -rf /var/cache/apk/*
RUN pip install jenkins-job-builder==2.10.0
USER jenkins
