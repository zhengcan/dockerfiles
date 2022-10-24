####################
# deps
FROM --platform=amd64 openjdk:11-slim-buster as openjdk


####################
# essential
FROM --platform=amd64 debian:bullseye-slim as essential

RUN apt-get update \
  && apt-get install -y --no-install-recommends binutils curl htop procps vim libmysql++3v5 \
  && rm -rf /var/lib/apt/lists/* \
  && rm /bin/sh && ln -s /bin/bash /bin/sh

COPY --from=openjdk /usr/local/openjdk-11 /usr/local/openjdk-11

ENV JAVA_HOME=/usr/local/openjdk-11 \
    PATH="/usr/local/openjdk-11/bin:$PATH"

CMD ["/bin/bash"]


####################
# builder
FROM --platform=amd64 essential as builder

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    build-essential bzip2 ca-certificates docker.io git gnupg \
    libmysql++-dev libssl-dev lsb-release pkg-config protobuf-compiler unzip zip \
  && apt-get clean

# SDK Man & Sbt
ENV SDKMAN_DIR /usr/local/sdkman
ENV SBT_VER 1.3.13
RUN curl -s get.sdkman.io | bash
RUN . "/root/.bashrc" \
  && echo "sdkman_auto_answer=true" > $SDKMAN_DIR/etc/config \
  && echo "sdkman_auto_selfupdate=false" >> $SDKMAN_DIR/etc/config \
  && echo "sdkman_insecure_ssl=false" >> $SDKMAN_DIR/etc/config \
  && echo "sdkman_debug_mode=false" >> $SDKMAN_DIR/etc/config \
  && sdk install sbt $SBT_VER \
  && ln -s $SDKMAN_DIR/candidates/sbt/current/  /opt/sbt \
  && ln -s /opt/sbt/bin/sbt                     /usr/local/bin/sbt

# FNM, Node, Yarn, PNPM
ENV PATH=$PATH:/root/.fnm:/root/.fnm/aliases/default/bin
RUN export SHELL=bash \
  && curl -fsSL https://raw.githubusercontent.com/Schniz/fnm/master/.ci/install.sh | bash
RUN . "/root/.bashrc" \
  && fnm install --lts \
  && npm install -g npm yarn pnpm
RUN ln -s /root/.fnm/aliases/default/bin/node /opt/node \
  && ln -s /root/.fnm/aliases/default/bin/corepack /usr/local/bin/corepack \
  && ln -s /root/.fnm/aliases/default/bin/node /usr/local/bin/node \
  && ln -s /root/.fnm/aliases/default/bin/npm /usr/local/bin/npm \
  && ln -s /root/.fnm/aliases/default/bin/npx /usr/local/bin/npx \
  && ln -s /root/.fnm/aliases/default/bin/pnpm /usr/local/bin/pnpm \
  && ln -s /root/.fnm/aliases/default/bin/pnpx /usr/local/bin/pnpx \
  && ln -s /root/.fnm/aliases/default/bin/yarn /usr/local/bin/yarn \
  && ln -s /root/.fnm/aliases/default/bin/yarnpkg /usr/local/bin/yarnpkg
RUN npm config list \
  && yarn config list \
  && pnpm config list

# Rust
ENV PATH=/root/.cargo/bin:$PATH
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain nightly \
  && cargo --version
RUN cargo install sccache \
  && echo '[build]' >> /root/.cargo/config.toml \
  && echo 'rustc-wrapper = "/root/.cargo/bin/sccache"' >> /root/.cargo/config.toml


####################
# jemalloc
FROM --platform=amd64 builder as jemalloc

ENV JEMALLOC_VER=5.3.0
RUN mkdir -p /jemalloc \
  cd /jemalloc \
  && curl -fLO https://github.com/jemalloc/jemalloc/releases/download/${JEMALLOC_VER}/jemalloc-${JEMALLOC_VER}.tar.bz2 \
  && tar -jxvf jemalloc-${JEMALLOC_VER}.tar.bz2 \
  && cd jemalloc-${JEMALLOC_VER} \
  && ./configure \
  && make -j $(($(nproc) - 2)) \
  && rm -rf /usr/local \
  && mkdir -p /usr/local \
  && make install


####################
# runtime
FROM --platform=amd64 essential as runtime

COPY --from=jemalloc /usr/local /usr/local

