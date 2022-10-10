# syntax=docker/dockerfile:1.2
ARG BASE=openjdk
ARG BASE_VER=11-slim-bullseye
FROM ${BASE}:${BASE_VER}

ARG JEMALLOC_VER=5.3.0
RUN --mount=type=tmpfs,target=/jemalloc \
  cd /jemalloc \
  && curl -fLO https://github.com/jemalloc/jemalloc/releases/download/${JEMALLOC_VER}/jemalloc-${JEMALLOC_VER}.tar.bz2 \
  && tar -jxvf jemalloc-${JEMALLOC_VER}.tar.bz2 \
  && cd jemalloc-${JEMALLOC_VER} \
  && ./configure --prefix=/opt/jemalloc \
  && make -j $(($(nproc) - 2)) \
  && make install

