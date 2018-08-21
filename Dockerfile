

FROM nginx:1-alpine

LABEL author "curtisz <software@curtisz.com>"
LABEL description "Docker Makefile boilerplate"
LABEL license "GPLv3"
LABEL name "docker-makefile-boilerplate"
LABEL version "0.0.1"

# add this Dockerfile to the image
COPY Dockerfile /Dockerfile

# add bash to this image because srsly
RUN apk add --no-cache bash

# override default config
COPY conf/nginx.conf /etc/nginx/nginx.conf


