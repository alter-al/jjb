FROM jenkins/jenkins:2.189-alpine
MAINTAINER Alex Alter-Pesotskiy

ENV CASC_JENKINS_CONFIG /var/jenkins_home/workspace/JenkinsDeploy/jenkins.yaml

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

RUN mkdir -p /var/jenkins_home/workspace/JenkinsDeploy
COPY configuration/jenkins.yaml $CASC_JENKINS_CONFIG
COPY environment.properties /var/jenkins_home/environment.properties
