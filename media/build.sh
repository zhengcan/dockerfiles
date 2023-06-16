#!/bin/bash

# Builder
docker build \
  --tag zhengcan/ffmpeg-opencv-runtime:bd \
  -f Dockerfile.bd \
  .
r=$? && if [ $r != 0 ]; then exit $r; fi

# Runtime
# - standard
docker build \
  --tag zhengcan/ffmpeg-opencv-runtime \
  --target standard \
  -f Dockerfile.rt \
  .
r=$? && if [ $r != 0 ]; then exit $r; fi
# - tacc
docker build \
  --tag mirrors.tencent.com/tacc/ffmpeg-opencv-runtime \
  --target tacc \
  -f Dockerfile.rt \
  .
r=$? && if [ $r != 0 ]; then exit $r; fi

# with Rust
docker build \
  --tag zhengcan/ffmpeg-opencv-rust \
  -f Dockerfile.rs \
  .
r=$? && if [ $r != 0 ]; then exit $r; fi

docker push zhengcan/ffmpeg-opencv-runtime
docker push mirrors.tencent.com/tacc/ffmpeg-opencv-runtime
docker push zhengcan/ffmpeg-opencv-rust
