# syntax=docker/dockerfile:1.2

# compile
FROM --platform=amd64 debian:bullseye-slim as compiler

RUN apt update \
  && apt install -y build-essential curl bzip2

ARG JEMALLOC_VER=5.3.0
RUN --mount=type=tmpfs,target=/jemalloc \
  cd /jemalloc \
  && curl -fLO https://github.com/jemalloc/jemalloc/releases/download/${JEMALLOC_VER}/jemalloc-${JEMALLOC_VER}.tar.bz2 \
  && tar -jxvf jemalloc-${JEMALLOC_VER}.tar.bz2 \
  && cd jemalloc-${JEMALLOC_VER} \
  && ./configure --prefix=/opt/jemalloc \
  && make -j $(($(nproc) - 2)) \
  && make install

FROM --platform=amd64 openjdk:11-slim-bullseye as runtime

COPY --from=compiler /opt/jemalloc /opt/jemalloc
