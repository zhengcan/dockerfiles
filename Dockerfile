# syntax=docker/dockerfile:1.2

# compiler
FROM --platform=amd64 debian:bullseye-slim as compiler

RUN apt update \
  && apt install -y build-essential curl bzip2

ARG JEMALLOC_VER=5.3.0
RUN --mount=type=tmpfs,target=/jemalloc \
  cd /jemalloc \
  && curl -fLO https://github.com/jemalloc/jemalloc/releases/download/${JEMALLOC_VER}/jemalloc-${JEMALLOC_VER}.tar.bz2 \
  && tar -jxvf jemalloc-${JEMALLOC_VER}.tar.bz2 \
  && cd jemalloc-${JEMALLOC_VER} \
  && ./configure \
  && make -j $(($(nproc) - 2)) \
  && rm -rf /usr/local \
  && mkdir -p /usr/local \
  && make install

# runtime
FROM --platform=amd64 openjdk:11-slim-bullseye as runtime

RUN apt update \
  && apt install -y curl procps htop libmysql++3v5 \
  && apt clean

COPY --from=compiler /usr/local /usr/local
