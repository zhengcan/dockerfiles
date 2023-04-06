#!/bin/bash

docker build \
  --build-arg BUILD_IMG=tencentos/tencentos_server31 \
  --build-arg RUNTIME_IMG=tencentos/tencentos_server31 \
  --tag zhengcan/ffmpeg-opencv-runtime .
r=$? && if [ $r != 0 ]; then exit $r; fi

docker push zhengcan/ffmpeg-opencv-runtime


