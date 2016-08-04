FROM bitnami/express:4.13.4-r3

MAINTAINER Bitnami <containers@bitnami.com>

#
# Eclipse Che
#
USER root

RUN echo "%sudo ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

ENV BITNAMI_IMAGE_VERSION=8.0.35-r1 \
    BITNAMI_APP_NAME=tomcat \
    BITNAMI_APP_USER=tomcat

RUN bitnami-pkg install java-1.8.0_91-0 --checksum 64cf20b77dc7cce3a28e9fe1daa149785c9c8c13ad1249071bc778fa40ae8773
ENV PATH=/opt/bitnami/java/bin:$PATH

RUN bitnami-pkg unpack tomcat-8.0.35-0 --checksum d86af6bade1325215d4dd1b63aefbd4a57abb05a71672e5f58e27ff2fd49325b
RUN ln -sf /opt/bitnami/$BITNAMI_APP_NAME/data /app

ENV PATH=/opt/bitnami/$BITNAMI_APP_NAME/bin:$PATH
ENV TOMCAT_HOME=/opt/bitnami/$BITNAMI_APP_NAME

RUN harpoon initialize tomcat

#
# Express
#
LABEL che:server:3000:ref=nodejs che:server:3000:protocol=http

#
# MongoDB
#

# From docker-compose.yml
ENV DATABASE_URL=mongodb://mongodb:27017/my_project_development
RUN sed -i -e "s/localhost\s*/localhost mongodb /g" /etc/hosts
RUN echo "127.0.0.1    mongodb" >> /etc/hosts

# From bitnami-docker-mongodb/Dockerfile
ENV BITNAMI_IMAGE_VERSION=3.2.7-r2 \
    BITNAMI_APP_NAME=mongodb \
    BITNAMI_APP_USER=mongo

RUN bitnami-pkg unpack mongodb-3.2.7-1 --checksum 98d972ec5f6a34b3fc7a82e76600d9ac6c209537d93402e3b29de9e066440b14
ENV PATH=/opt/bitnami/$BITNAMI_APP_NAME/sbin:/opt/bitnami/$BITNAMI_APP_NAME/bin:$PATH

# From bitnami-docker-mongodb/rootfs/app-entrypoint.sh
RUN harpoon initialize $BITNAMI_APP_NAME \
    ${MONGODB_ROOT_PASSWORD:+--rootPassword $MONGODB_ROOT_PASSWORD} \
    ${MONGODB_USER:+--username $MONGODB_USER} \
    ${MONGODB_PASSWORD:+--password $MONGODB_PASSWORD} \
    ${MONGODB_DATABASE:+--database $MONGODB_DATABASE} \
    ${MONGODB_REPLICASET_MODE:+--replicaSetMode $MONGODB_REPLICASET_MODE} \
    ${MONGODB_REPLICASET_NAME:+--replicaSetName $MONGODB_REPLICASET_NAME} \
    ${MONGODB_PRIMARY_HOST:+--primaryHost $MONGODB_PRIMARY_HOST} \
    ${MONGODB_PRIMARY_PORT:+--primaryPort $MONGODB_PRIMARY_PORT} \
    ${MONGODB_PRIMARY_USER:+--primaryUser $MONGODB_PRIMARY_USER} \
    ${MONGODB_PRIMARY_PASSWORD:+--primaryPassword $MONGODB_PRIMARY_PASSWORD}

# Eclipse Che
# CMD ["harpoon", "start", "--foreground", "tomcat"]
USER bitnami
CMD harpoon start mongodb && harpoon start --foreground tomcat
