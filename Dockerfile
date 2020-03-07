FROM alpine:3.11.3

# Install alpine package manifest
COPY Dockerfile.packages.txt /etc/apk/packages.txt
RUN apk add --no-cache --update $(grep -v '^#' /etc/apk/packages.txt)

RUN git clone -b master --depth=1 --single-branch https://github.com/aroq/toolbox-utils.git /toolbox-utils

RUN mkdir -p /toolbox/toolbox-wrap
COPY templates /toolbox/toolbox-wrap/

COPY /entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
