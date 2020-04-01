FROM alpine:3.11.3

# Install alpine package manifest
COPY Dockerfile.packages.txt /etc/apk/packages.txt
RUN apk add --no-cache --update $(grep -v '^#' /etc/apk/packages.txt)

# Install fd
ENV FD_VERSION 7.5.0
RUN curl --fail -sSL -o fd.tar.gz https://github.com/sharkdp/fd/releases/download/v${FD_VERSION}/fd-v${FD_VERSION}-x86_64-unknown-linux-musl.tar.gz \
    && tar -zxf fd.tar.gz \
    && cp fd-v${FD_VERSION}-x86_64-unknown-linux-musl/fd /usr/local/bin/ \
    && rm -f fd.tar.gz \
    && rm -fR fd-v${FD_VERSION}-x86_64-unknown-linux-musl \
    && chmod +x /usr/local/bin/fd

RUN mkdir -p /toolbox && \
    git clone -b v0.1.5 --depth=1 --single-branch https://github.com/aroq/toolbox-utils.git /toolbox/toolbox-utils

RUN mkdir -p /toolbox/toolbox-wrap
COPY templates /toolbox/toolbox-wrap/templates
COPY hooks /toolbox/toolbox-wrap/hooks
COPY mounts /toolbox/toolbox-wrap/mounts

COPY /entrypoint.sh /entrypoint.sh

ENV TOOLBOX_UTILS_DIR /toolbox/toolbox-utils

ENTRYPOINT ["/entrypoint.sh"]
