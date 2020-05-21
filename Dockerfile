FROM gradle:4.7.0-jdk8-alpine AS build

ADD --chown=gradle:gradle ./ ./
RUN gradle build --no-daemon -x test -x findbugsMain -x findbugsTest -x pmdMain -x pmdTest -x checkstyleMain -x checkstyleTest && \
    mkdir result && \
    mv build/resources/main/application.properties ./result && \
    ls -la build/libs && mv build/libs/gradle.jar ./result/backend.jar



FROM openjdk:8-jre-slim
RUN groupadd -r back && useradd -r -g back back 
WORKDIR /opt/backend
COPY --from=build --chown=back:back /home/gradle/result/* ./
USER back
ENTRYPOINT [ "java", "-jar", "/opt/backend/backend.jar", "--spring.config.location=file:/opt/backend/" ]

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
