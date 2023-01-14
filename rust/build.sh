#!/bin/bash

docker build --target builder --tag zhengcan/rust:builder-aarch64 -f Dockerfile.aarch64 .
r=$? && if [ $r != 0 ]; then exit $r; fi

docker build --target runtime --tag zhengcan/rust:runtime-aarch64 -f Dockerfile.aarch64 .
r=$? && if [ $r != 0 ]; then exit $r; fi

docker build -f Dockerfile.aarch64 .
r=$? && if [ $r != 0 ]; then exit $r; fi

docker push zhengcan/rust:builder-aarch64
docker push zhengcan/rust:runtime-aarch64


