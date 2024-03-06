# syntax=docker/dockerfile:1

ARG RUST_VERSION=1.76
FROM rust:${RUST_VERSION}-slim-bookworm AS builder

# RUN apt-get update \
#   && apt-get install -y --no-install-recommends \ git

WORKDIR /usr/local/src

ARG REDISJSON_VERSION=2.6.9
ADD \
  https://github.com/RedisJSON/RedisJSON/archive/refs/tags/v${REDISJSON_VERSION}.tar.gz \
  ./redisjson.tar.gz

RUN <<EOF
set -e

apt-get update
apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    clang \
    cmake \
    gcc \
    git \
    libclang-dev \
    libssl-dev \
    make \
    pkg-config

update-ca-certificates

tar -zxvf redisjson.tar.gz
cd ./RedisJSON-${REDISJSON_VERSION}

cargo build --locked --release
cp ./target/release/librejson.so /usr/local/lib/
EOF

FROM bitnami/redis:7.2.4-debian-12-r9

COPY --from=builder /usr/local/lib/librejson.so /usr/local/lib/
