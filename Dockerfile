FROM gradle:4.7.0-jdk8-alpine AS build
LABEL maintainer="vitalygrischenko@gmail.com"

ARG REPO_URL="https://github.com/vitamin-b12/devops-training-project-backend.git"
USER root
RUN apk update && apk upgrade && \
    apk add --no-cache bash git \
    && rm -rf /var/cache/apk/*
WORKDIR /home/gradle
RUN git clone ${REPO_URL} \
    && mv devops-training-project-backend/* ${PWD} \
    && rm -rf devops-training-project-* \
    && chown -R gradle:gradle ${PWD}
RUN if [ ! -f ./gradlew ]; then \
            gradle \
                --quiet \
                --no-daemon \
                --no-build-cache \
                wrapper; \
    fi
RUN ./gradlew \
            --quiet \
            --no-daemon \
            --no-build-cache \
            build \
            -x test

FROM openjdk:8-jre-slim AS production
ENV BUILD_DIR="/home/gradle/build" \
    APP_DIR="/opt/backend" \
    APP_NAME="backend.jar"
RUN groupadd -r backend && useradd -r -g backend backend
USER backend
WORKDIR /opt/backend
COPY --from=build --chown=backend:backend $BUILD_DIR/libs/* ${APP_DIR}/${APP_NAME}
COPY --from=build --chown=backend:backend $BUILD_DIR/resources/main/application.properties ${APP_DIR}

ARG DEFAULT_DB_URL
ENV DB_URL=${DEFAULT_DB_URL:-"localhost"}
ARG DEFAULT_DB_PORT
ENV DB_PORT=${DEFAULT_DB_PORT:-"3306"}
ARG DEFAULT_DB_USERNAME
ENV DB_USERNAME=${DEFAULT_DB_USERNAME:-"root"}
ARG DEFAULT_DB_PASSWORD
ENV DB_PASSWORD=${DEFAULT_DB_PASSWORD:-"Passw0rd"}
ARG DEFAULT_DB_NAME
ENV DB_NAME=${DEFAULT_DB_NAME:-"training"}

EXPOSE 8080

ENTRYPOINT [ "java", "-jar", "backend.jar", "--spring.config.location=file:./"  ]