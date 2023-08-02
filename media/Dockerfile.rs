ARG STANDARD_IMG=zhengcan/ffmpeg-opencv-runtime
ARG RUST_BASE=tencentos/tencentos_server31

FROM ${STANDARD_IMG} as deps

####################
# Buildpack
####################
FROM ${RUST_BASE} as buildpack

# FFMpeg & OpenCV
RUN yum install -y freetype-devel libjpeg-turbo-devel openjpeg2-devel turbojpeg-devel libwebp-devel fontconfig-devel \
    frei0r-devel libaom-devel libdav1d-devel snappy-devel libass-devel zimg-devel czmq-devel libxml2-devel \
    rubberband-devel soxr-devel speex-devel srt-devel svt-av1-devel svt-vp9-devel tesseract-devel libtheora-devel \
    libvmaf-devel libvorbis-devel \
    && yum clean all
COPY --from=deps  /usr/local            /usr/local
COPY --from=deps  /usr/local/include    /usr/include
ENV LD_LIBRARY_PATH=/usr/local/lib:/usr/local/lib64
ENV PKG_CONFIG_PATH=/usr/lib64/pkgconfig:/usr/local/lib/pkgconfig:/usr/local/lib64/pkgconfig

# Buildpack
RUN yum install -y git git-lfs make cmake meson ninja-build nasm expat-devel protobuf-devel \
    openssl-devel clang-devel glibc-devel libcurl-devel libatomic \
    && yum clean all

# Rust
ENV PATH=/root/.cargo/bin:$PATH
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
RUN rustup install nightly
RUN rustup check && cargo --version

# sccache
ARG SCCACHE_VER=0.5.4
RUN wget https://github.com/mozilla/sccache/releases/download/v${SCCACHE_VER}/sccache-v${SCCACHE_VER}-x86_64-unknown-linux-musl.tar.gz \
    && tar zxvf sccache-v${SCCACHE_VER}-x86_64-unknown-linux-musl.tar.gz \
    && mv sccache-v${SCCACHE_VER}-x86_64-unknown-linux-musl/sccache /usr/bin \
    && rm -rf sccache-v${SCCACHE_VER}-x86_64-unknown-linux-musl.tar.gz \
    && rm -rf sccache-v${SCCACHE_VER}-x86_64-unknown-linux-musl
RUN echo '[build]' >> /root/.cargo/config.toml \
    && echo 'rustc-wrapper = "/usr/bin/sccache"' >> /root/.cargo/config.toml

# Scripts
ENV CARGO_NET_GIT_FETCH_WITH_CLI=true
# ENTRYPOINT [ "/root/.cargo/bin/cargo" ]

