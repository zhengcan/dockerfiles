#!/bin/bash

declare -a JDKS=("openjdk" "dragonwell")

for JDK in ${JDKS[@]} ; do
  docker build --build-arg JDK=$JDK --target builder --tag zhengcan/openjdk-runtime:builder-$JDK .
  r=$? && if [ $r != 0 ]; then exit $r; fi
  docker build --build-arg JDK=$JDK --target runtime --tag zhengcan/openjdk-runtime:runtime-$JDK .
  r=$? && if [ $r != 0 ]; then exit $r; fi
done

for JDK in ${JDKS[@]} ; do
  docker push zhengcan/openjdk-runtime:builder-$JDK
  docker push zhengcan/openjdk-runtime:runtime-$JDK
done


