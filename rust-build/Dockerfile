FROM rust:alpine

RUN apk add --no-cache \
    llvm \
    lld \
    musl-dev \
    make \
    && \
    rustup target add x86_64-unknown-linux-musl

ENV LANG=en_US.UTF-8
