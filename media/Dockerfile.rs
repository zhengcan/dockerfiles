ARG RS_BUILD=tencentos/tencentos_server31

FROM zhengcan/ffmpeg-opencv-runtime as deps

####################
# Buildpack
####################
FROM ${RS_BUILD} as buildpack

COPY --from=deps /usr/local/        /usr/local/
COPY --from=deps /usr/local/include /usr/include/
ENV LD_LIBRARY_PATH=/usr/local/lib:/usr/local/lib64
ENV PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:/usr/local/lib64/pkgconfig

# Buildpack
RUN yum install -y git git-lfs make cmake meson ninja-build nasm expat-devel protobuf-compiler \
    openssl-devel clang-devel fontconfig-devel glibc-devel libcurl-devel libwebp-devel libatomic \
    && yum clean all

# Rust
ENV PATH=/root/.cargo/bin:$PATH
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain nightly
RUN cargo --version

# sccache
ARG SCCACHE_VER=0.5.3
RUN wget https://github.com/mozilla/sccache/releases/download/v${SCCACHE_VER}/sccache-v${SCCACHE_VER}-x86_64-unknown-linux-musl.tar.gz \
    && tar zxvf sccache-v${SCCACHE_VER}-x86_64-unknown-linux-musl.tar.gz \
    && mv sccache-v${SCCACHE_VER}-x86_64-unknown-linux-musl/sccache /usr/bin \
    && rm -rf sccache-v${SCCACHE_VER}-x86_64-unknown-linux-musl.tar.gz \
    && rm -rf sccache-v${SCCACHE_VER}-x86_64-unknown-linux-musl
RUN echo '[build]' >> /root/.cargo/config.toml \
    && echo 'rustc-wrapper = "/usr/bin/sccache"' >> /root/.cargo/config.toml

# Scripts
ENV CARGO_NET_GIT_FETCH_WITH_CLI=true
ENTRYPOINT [ "/root/.cargo/bin/cargo" ]

