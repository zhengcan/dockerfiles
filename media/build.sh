#!/bin/bash

SUFFIX=
BUILDER_IMG=zhengcan/ffmpeg-opencv-runtime:bd${SUFFIX}
STANDARD_IMG=zhengcan/ffmpeg-opencv-runtime:latest${SUFFIX}
TACC_IMG=mirrors.tencent.com/tacc/ffmpeg-opencv-runtime:latest${SUFFIX}
RUST_IMG=zhengcan/ffmpeg-opencv-rust:latest${SUFFIX}

# Builder
docker build \
  --tag ${BUILDER_IMG} \
  -f Dockerfile.bd \
  .
r=$? && if [ $r != 0 ]; then exit $r; fi

# Runtime
# - standard
docker build \
  --build-arg BUILDER_IMG=${BUILDER_IMG} \
  --tag ${STANDARD_IMG} \
  --target standard \
  -f Dockerfile.rt \
  .
r=$? && if [ $r != 0 ]; then exit $r; fi
# - tacc
docker build \
  --build-arg BUILDER_IMG=${BUILDER_IMG} \
  --tag ${TACC_IMG} \
  --target tacc \
  -f Dockerfile.rt \
  .
r=$? && if [ $r != 0 ]; then exit $r; fi

# with Rust
docker build \
  --tag ${RUST_IMG} \
  -f Dockerfile.rs \
  .
r=$? && if [ $r != 0 ]; then exit $r; fi

# test with Rust
docker run --rm -it -v `pwd`/test:/test -w /test ${RUST_IMG} run 

# Push
if [[ "$PUSH" != "n" ]] && [[ "$PUSH" != "N" ]]; then
  docker push ${STANDARD_IMG}
  docker push ${TACC_IMG}
  docker push ${RUST_IMG}
fi

