FROM sdhibit/rpi-raspbian:jessie
MAINTAINER Yannick Croissant <yannick.croissant@gmail.com>

ENV QEMU_EXECVE 1
# Force armv6l
ENV QEMU_CPU arm1176

COPY . /usr/bin

RUN [ "cross-build-start" ]

# Versions
ENV NODE_VERSION 5.4.1
ENV PHANTOM_VERSION 2.0
ENV PHANTOMAS_VERSION 1.13.0

# Packages
RUN apt-get update && \
    apt-get -y install git wget python make curl \
    build-essential g++ flex bison gperf ruby perl libsqlite3-dev \
    libfontconfig1-dev libicu-dev libfreetype6 libssl-dev \
    libpng-dev libjpeg-dev python libx11-dev libxext-dev

## PhantomJS
RUN git clone https://github.com/ariya/phantomjs && \
    cd phantomjs && \
    git checkout $PHANTOM_VERSION

## Compile PhantomJS
RUN cd phantomjs && \
    ./build.sh --confirm

RUN mv ./phantomjs/bin/phantomjs /usr/local/bin/phantomjs

# Node.js
ENV NPM_CONFIG_LOGLEVEL info

RUN curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-armv6l.tar.gz" && \
    tar -xzf "node-v$NODE_VERSION-linux-armv6l.tar.gz" -C /usr/local --strip-components=1 && \
    rm "node-v$NODE_VERSION-linux-armv6l.tar.gz"

# Phantomas
RUN git clone https://github.com/macbre/phantomas && \
    cd phantomas && \
    git checkout v$PHANTOMAS_VERSION

## Patch Phantomas to use the global PhantomJS
COPY phantomas.patch ./phantomas

RUN cd phantomas && \
    git apply phantomas.patch && \
    rm phantomas.patch

## Install Phantomas
RUN cd phantomas && \
    npm install

RUN [ "cross-build-end" ]

ENTRYPOINT [ "/phantomas/bin/phantomas.js" ]
