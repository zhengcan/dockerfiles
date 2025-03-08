#!/bin/bash

docker build -t zhengcan/dev:media-bd                           --target imagemagick  -f Dockerfile.media   .
r=$? && if [ $r != 0 ]; then exit $r; fi
docker build -t zhengcan/dev:media                              --target runtime      -f Dockerfile.media   . 
r=$? && if [ $r != 0 ]; then exit $r; fi
docker build -t zhengcan/dev:malloc                             --target malloc       -f Dockerfile.builder .
r=$? && if [ $r != 0 ]; then exit $r; fi
docker build -t zhengcan/dev:builder                                                  -f Dockerfile.builder .
r=$? && if [ $r != 0 ]; then exit $r; fi
docker build -t zhengcan/run:simple                             --target simple       -f Dockerfile.runtime .
r=$? && if [ $r != 0 ]; then exit $r; fi
docker build -t zhengcan/run:media                              --target media        -f Dockerfile.runtime .
r=$? && if [ $r != 0 ]; then exit $r; fi
docker build -t zhengcan/run:jdk-17 --build-arg JDK_TAG=17-jdk  --target java         -f Dockerfile.runtime .
r=$? && if [ $r != 0 ]; then exit $r; fi
docker build -t zhengcan/run:jre-17 --build-arg JDK_TAG=17-jre  --target java         -f Dockerfile.runtime .
r=$? && if [ $r != 0 ]; then exit $r; fi

if [[ "$DRY_RUN" == "" ]]; then
  docker push -a zhengcan/dev
  docker push -a zhengcan/run
fi

if [[ "$OKE" != "" ]]; then
  docker tag zhengcan/dev:media    mel.ocir.io/ax1j1s8oewtm/zhengcan/dev:media
  docker tag zhengcan/dev:media-bd mel.ocir.io/ax1j1s8oewtm/zhengcan/dev:media-bd
  docker tag zhengcan/dev:malloc   mel.ocir.io/ax1j1s8oewtm/zhengcan/dev:malloc
  docker tag zhengcan/dev:builder  mel.ocir.io/ax1j1s8oewtm/zhengcan/dev:builder
  docker tag zhengcan/run:simple   mel.ocir.io/ax1j1s8oewtm/zhengcan/run:simple
  docker tag zhengcan/run:media    mel.ocir.io/ax1j1s8oewtm/zhengcan/run:media
  docker tag zhengcan/run:jdk-17   mel.ocir.io/ax1j1s8oewtm/zhengcan/run:jdk-17
  docker tag zhengcan/run:jre-17   mel.ocir.io/ax1j1s8oewtm/zhengcan/run:jre-17
  docker push -a mel.ocir.io/ax1j1s8oewtm/zhengcan/dev
  docker push -a mel.ocir.io/ax1j1s8oewtm/zhengcan/run
fi

