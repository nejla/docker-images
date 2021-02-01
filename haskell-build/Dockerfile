FROM ubuntu:focal

ENV STACK_VERSION=2.5.1


RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
      curl \
      dirmngr \
      gnupg2 \
      apt-transport-https \
      ca-certificates \
      software-properties-common && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 \
      --recv-keys 9DC858229FC7DD38854AE2D88D81803C0EBFCD88 && \
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
      ca-certificates \
      docker-ce \
      git \
      libicu-dev \
      libpq-dev \
      libtinfo-dev \
      locales \
      make \
      msmtp-mta \
      netbase \
      ruby-mustache \
      ssh \
      xz-utils \
      g++ gcc libc6-dev libffi-dev libgmp-dev xz-utils zlib1g-dev \
      && \
    rm -rf /var/lib/apt/lists/* && \
    localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 && \
    mkdir -p /tmp/stack && \
    cd /tmp/stack && \
    curl -L "https://github.com/commercialhaskell/stack/releases/download/v${STACK_VERSION}/stack-${STACK_VERSION}-linux-x86_64.tar.gz" -o stack.txz && \
    tar -xf stack.txz && \
    install -m 755 stack-${STACK_VERSION}-linux-x86_64/stack /usr/bin/stack && \
    rm -rf /tmp/stack


ENV LANG=en_US.UTF-8
