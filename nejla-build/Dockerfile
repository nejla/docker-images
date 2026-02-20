FROM ubuntu:noble@sha256:cd1dba651b3080c3686ecf4e3c4220f026b521fb76978881737d24f200828b2b

ARG STACK_VERSION=3.9.1
ARG STACK_URL="https://github.com/commercialhaskell/stack/releases/download/v${STACK_VERSION}/stack-${STACK_VERSION}-linux-x86_64.tar.gz"
ARG STACK_SHA256="c4816581c445f6e4d43bf7ce6064b0d58d136e49c45e6336d612c4d8eaaedd11"
ARG RUSTC_VERSION=1.87.0
ARG RUST_ARCH='x86_64-unknown-linux-gnu'
ARG RUSTUP_VER="1.28.2"
ARG RUSTUP_SHA256='20a06e644b0d9bd2fbdbfd52d42540bdde820ea7df86e92e533c073da0cdd43c'
ARG RUSTUP_URL="https://static.rust-lang.org/rustup/archive/${RUSTUP_VER}/${RUST_ARCH}/rustup-init"

ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH


SHELL ["/bin/bash", "-c"]

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
      libxml2-dev \
      locales \
      make \
      msmtp-mta \
      netbase \
      pkg-config \
      ruby-mustache \
      ssh \
      xz-utils \
      g++ gcc libc6-dev libffi-dev libgmp-dev xz-utils zlib1g-dev \
      llvm lld \
      musl-dev \
      && \
    rm -rf /var/lib/apt/lists/* && \
    localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 && \
    mkdir -p /tmp/stack && \
    cd /tmp/stack && \
    curl -L "$STACK_URL" -o stack.txz && \
    echo "${STACK_SHA256} *stack.txz" | sha256sum -c - && \
    tar -xf stack.txz && \
    install -m 755 stack-${STACK_VERSION}-linux-x86_64/stack /usr/bin/stack && \
    rm -rf /tmp/stack

ENV LANG=en_US.UTF-8

# Install rust environment
RUN set -eux; \
    curl "$RUSTUP_URL" -o rustup-init; \
    echo "${RUSTUP_SHA256} *rustup-init" | sha256sum -c - ; \
    chmod +x rustup-init; \
    ./rustup-init -y --no-modify-path --profile minimal --default-toolchain "$RUSTC_VERSION" --default-host "$RUST_ARCH"; \
    rm rustup-init; \
    chmod -R a+w "$RUSTUP_HOME" "$CARGO_HOME"; \
    rustup target add x86_64-unknown-linux-musl; \
    rustup --version; \
    cargo --version; \
    rustc --version
