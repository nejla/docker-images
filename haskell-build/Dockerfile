FROM ubuntu:xenial

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
      --recv-keys 575159689BEFB442 && \
    echo "deb https://download.fpcomplete.com/ubuntu $(lsb_release -cs) main" \
      > /etc/apt/sources.list.d/fpco.list && \
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
      ssh \
      stack \
      xz-utils && \
    rm -rf /var/lib/apt/lists/* && \
    localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 && \
    stack upgrade && \
    cp -f /root/.local/bin/stack /usr/bin/stack

ENV LANG=en_US.UTF-8
