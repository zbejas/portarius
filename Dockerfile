# Build
FROM ubuntu:22.04 AS base

RUN apt update 
RUN apt install -y curl git wget unzip python3
RUN apt clean

RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

RUN flutter channel stable
RUN flutter upgrade

RUN mkdir /portarius/
COPY . /portarius/
WORKDIR /portarius/
RUN flutter build web

EXPOSE 80

# Runtime
FROM nginx:alpine
LABEL org.opencontainers.image.source="https://github.com/zbejas/portarius"
COPY --from=base /portarius/build/web /usr/share/nginx/html