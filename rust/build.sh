#!/bin/bash

docker build --target builder --tag zhengcan/rust-aarch64:builder -f Dockerfile.aarch64 .
r=$? && if [ $r != 0 ]; then exit $r; fi

docker build --target runtime --tag zhengcan/rust-aarch64:runtime -f Dockerfile.aarch64 .
r=$? && if [ $r != 0 ]; then exit $r; fi

docker build --target runtime-opencv --tag zhengcan/rust-aarch64:runtime-opencv -f Dockerfile.aarch64 .
r=$? && if [ $r != 0 ]; then exit $r; fi

docker build -f Dockerfile.aarch64 .
r=$? && if [ $r != 0 ]; then exit $r; fi

docker push zhengcan/rust-aarch64:builder
docker push zhengcan/rust-aarch64:runtime
docker push zhengcan/rust-aarch64:runtime-opencv


