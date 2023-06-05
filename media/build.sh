#!/bin/bash

docker build \
  --build-arg RT_BUILD=tencentos/tencentos_server31 \
  --build-arg RT_BASE=tencentos/tencentos_server31 \
  --tag zhengcan/ffmpeg-opencv-runtime \
  -f Dockerfile.rt \
  .
r=$? && if [ $r != 0 ]; then exit $r; fi

docker build \
  --build-arg RS_BUILD=tencentos/tencentos_server31 \
  --tag zhengcan/ffmpeg-opencv-rust \
  -f Dockerfile.rs \
  .
r=$? && if [ $r != 0 ]; then exit $r; fi

docker push zhengcan/ffmpeg-opencv-runtime
docker push zhengcan/ffmpeg-opencv-rust
