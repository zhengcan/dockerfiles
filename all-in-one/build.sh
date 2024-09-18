#!/bin/bash

docker build -t zhengcan/dev:media-bd                           --target imagemagick  -f Dockerfile.media   .
r=$? && if [ $r != 0 ]; then exit $r; fi
docker build -t zhengcan/dev:media                              --target runtime      -f Dockerfile.media   . 
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

docker push -a zhengcan/dev
docker push -a zhengcan/run
