FROM anapsix/alpine-java:8
MAINTAINER Alex Alter-Pesotskiy <33gri@bk.ru>

RUN apk update && apk add wget && apk add curl && apk add git && rm -rf /var/cache/apk/* && rm -rf /var/lib/apt/lists/*
RUN curl -L http://mirrors.jenkins-ci.org/war/latest/jenkins.war -o /opt/jenkins.war
ENV JENKINS_HOME /var/lib/jenkins
ENV JENKINS_UC http://updates.jenkins-ci.org
ENV BUILDER_VERSION 2.10.0

# Add configuration for jenkins and plugins
RUN mkdir -p /var/lib/jenkins

# Install plugins from plugins.txt
RUN mkdir -p /var/lib/jenkins/plugins
ADD plugins.txt plugins.txt
RUN cat plugins.txt | while read line; do \
      plugin_name=$(echo $line | cut -f1 -d:); \
      plugin_version=$(echo $line | cut -f2 -d:); \
      curl -L ${JENKINS_UC}/download/plugins/${plugin_name}/${plugin_version}/${plugin_name}.hpi -o ${JENKINS_HOME}/plugins/${plugin_name}.hpi; \
    done

# Install jenkins-job-builder
RUN apk add --no-cache python
RUN apk add --no-cache py-pip
RUN pip install jenkins-job-builder==${BUILDER_VERSION}

# Add configuration files
# ADD jenkins_home/* /var/lib/jenkins/

# Expose the jenkins dir as a volume
VOLUME /var/lib/jenkins

EXPOSE 8080
ENTRYPOINT java -jar /opt/jenkins.war
