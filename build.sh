#!/bin/bash

declare -a JDKS=("openjdk" "dragonwell")

for JDK in ${JDKS[@]} ; do
  docker build --build-arg JDK=$JDK --target builder --tag zhengcan/openjdk-runtime:builder-$JDK .
  docker build --build-arg JDK=$JDK --target runtime --tag zhengcan/openjdk-runtime:runtime-$JDK .
done

