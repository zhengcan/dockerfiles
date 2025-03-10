####################
# Prepare
FROM zhengcan/dev:media AS media
FROM eclipse-temurin:17-jdk AS openjdk


####################
# Base
FROM media AS base

RUN apt update && \
  apt install -y build-essential libmysql++-dev libssl-dev lsb-release protobuf-compiler git git-lfs zip xz-utils curl wget vim


####################
# Java
FROM base AS builder
COPY --from=openjdk /opt/java/openjdk /opt/java/openjdk
ENV PATH=$PATH:/opt/java/openjdk/bin

# SDK Man & Sbt
ENV SDKMAN_DIR=/usr/local/sdkman
ENV SBT_VER=1.10.2
RUN curl -s "https://get.sdkman.io" | bash
RUN mkdir -p $SDKMAN_DIR/etc \
  && echo "sdkman_auto_answer=true" > $SDKMAN_DIR/etc/config \
  && echo "sdkman_auto_selfupdate=false" >> $SDKMAN_DIR/etc/config \
  && echo "sdkman_insecure_ssl=false" >> $SDKMAN_DIR/etc/config \
  && echo "sdkman_debug_mode=false" >> $SDKMAN_DIR/etc/config \
  && echo "#!/bin/bash" > $SDKMAN_DIR/install \
  && echo "source \"$SDKMAN_DIR/bin/sdkman-init.sh\"" >> $SDKMAN_DIR/install \
  && echo "sdk install sbt $SBT_VER" >> $SDKMAN_DIR/install \
  && chmod +x $SDKMAN_DIR/install \
  && $SDKMAN_DIR/install \
  && ln -s $SDKMAN_DIR/candidates/sbt/current/  /opt/sbt \
  && ln -s /opt/sbt/bin/sbt                     /usr/bin/sbt


####################
# Node
ENV NODE_VER=22.14.0
ENV PATH=$PATH:/opt/node/bin
RUN cd /opt \
  && curl -fLO https://nodejs.org/dist/v${NODE_VER}/node-v${NODE_VER}-linux-x64.tar.xz \
  && tar xvf node-v${NODE_VER}-linux-x64.tar.xz \
  && rm node-v${NODE_VER}-linux-x64.tar.xz \
  && mv node-v${NODE_VER}-linux-x64 node \
  && ln -s /opt/node/bin/corepack /usr/bin/corepack \
  && ln -s /opt/node/bin/node /usr/bin/node \
  && ln -s /opt/node/bin/npm /usr/bin/npm \
  && ln -s /opt/node/bin/npx /usr/bin/npx

# NPM, Yarn, PNPM
RUN npm install -g npm pnpm yarn \
  && ln -s /opt/node/bin/pnpm /usr/bin/pnpm \
  && ln -s /opt/node/bin/pnpx /usr/bin/pnpx \
  && ln -s /opt/node/bin/yarn /usr/bin/yarn \
  && ln -s /opt/node/bin/yarnpkg /usr/bin/yarnpkg
RUN npm config list \
  && yarn config list \
  && pnpm config list

# Bun
ENV PATH=$PATH:/root/.bun/bin
RUN curl -fsSL https://bun.sh/install | bash
RUN bun --revision


####################
# Rust
ENV PATH=$PATH:/root/.cargo/bin
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable \
  && cargo --version

# sccache
ARG SCCACHE_VER=0.10.0
RUN wget https://github.com/mozilla/sccache/releases/download/v${SCCACHE_VER}/sccache-v${SCCACHE_VER}-x86_64-unknown-linux-musl.tar.gz \
  && tar zxvf sccache-v${SCCACHE_VER}-x86_64-unknown-linux-musl.tar.gz \
  && mv sccache-v${SCCACHE_VER}-x86_64-unknown-linux-musl/sccache /usr/bin \
  && rm -rf sccache-v${SCCACHE_VER}-x86_64-unknown-linux-musl.tar.gz \
  && rm -rf sccache-v${SCCACHE_VER}-x86_64-unknown-linux-musl
RUN echo '[build]' >> /root/.cargo/config.toml \
  && echo 'rustc-wrapper = "/usr/bin/sccache"' >> /root/.cargo/config.toml

# binstall & watch
RUN curl -L --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash
RUN cargo binstall -y cargo-watch cargo-release

####################
# jemalloc & tcmalloc
FROM base AS malloc

RUN rm -rf /usr/local

ENV JEMALLOC_VER=5.3.0
RUN mkdir -p /jemalloc \
  && cd /jemalloc \
  && curl -fLO https://github.com/jemalloc/jemalloc/releases/download/${JEMALLOC_VER}/jemalloc-${JEMALLOC_VER}.tar.bz2 \
  && tar -jxvf jemalloc-${JEMALLOC_VER}.tar.bz2 \
  && cd jemalloc-${JEMALLOC_VER} \
  && ./configure \
  && make -j $(($(nproc) - 2)) \
  && make install

ENV TCMALLOC_VER=4.5.16
RUN apt update && apt install libtcmalloc-minimal4 \
  && mv /usr/lib/x86_64-linux-gnu/libtcmalloc_minimal.so.${TCMALLOC_VER} /usr/local/lib/libtcmalloc_minimal.so.${TCMALLOC_VER} \
  && ln -s /usr/local/lib/libtcmalloc_minimal.so.${TCMALLOC_VER} /usr/local/lib/libtcmalloc_minimal.so.4 \
  && ln -s /usr/local/lib/libtcmalloc_minimal.so.4 /usr/local/lib/libtcmalloc_minimal.so \
  && ln -s /usr/local/lib/libtcmalloc_minimal.so.4 /usr/local/lib/libtcmalloc.so


####################
# Final
FROM builder AS final

ENV JEMALLOC_SO=/usr/local/lib/libjemalloc.so
ENV TCMALLOC_SO=/usr/local/lib/libtcmalloc.so

COPY --from=malloc /usr/local/ /usr/local/
# COPY --from=malloc /usr/local/lib/libjemalloc.*     /usr/local/lib/
# RUN ln -s libjemalloc.so.2                          /usr/local/lib/libjemalloc.so

# COPY --from=malloc /usr/loca/lib/libtcmalloc*.*     /usr/local/lib/

RUN apt install -y docker.io docker-buildx


