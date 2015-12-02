FROM sdhibit/rpi-raspbian:jessie
MAINTAINER Yannick Croissant <yannick.croissant@gmail.com>

ENV QEMU_EXECVE 1
ENV QEMU_CPU arm1176
COPY . /usr/bin

RUN [ "cross-build-start" ]

# Packages
RUN apt-get update && \
    apt-get -y install git wget python make curl \
    build-essential g++ flex bison gperf ruby perl libsqlite3-dev \
    libfontconfig1-dev libicu-dev libfreetype6 libssl-dev \
    libpng-dev libjpeg-dev python libx11-dev libxext-dev

# Node.js
ENV NPM_CONFIG_LOGLEVEL info
ENV NODE_VERSION 5.3.0

RUN curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-armv6l.tar.gz" && \
    tar -xzf "node-v$NODE_VERSION-linux-armv6l.tar.gz" -C /usr/local --strip-components=1 && \
    rm "node-v$NODE_VERSION-linux-armv6l.tar.gz"

# PhantomJS
RUN git clone https://github.com/ariya/phantomjs && \
    cd phantomjs && \
    git checkout 2.0

RUN cd phantomjs && \
    ./build.sh --confirm

RUN mv ./phantomjs/bin/phantomjs /usr/local/bin/phantomjs

# Phantomas
RUN git clone https://github.com/macbre/phantomas && \
    cd phantomas && \
    git checkout v1.13.0

# Patch Phantomas to use the global PhantomJS
COPY phantomas.patch ./phantomas

RUN cd phantomas && \
    git apply phantomas.patch && \
    rm phantomas.patch

RUN cd phantomas && \
    npm install

RUN [ "cross-build-end" ]

ENTRYPOINT [ "/phantomas/bin/phantomas.js" ]
