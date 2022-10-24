#!/bin/bash

docker build --target builder --tag zhengcan/openjdk-runtime:builder .
docker build --target runtime --tag zhengcan/openjdk-runtime:latest .

