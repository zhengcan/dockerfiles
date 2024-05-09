#!/bin/bash

docker buildx build --platform linux/amd64,linux/arm64 -t zhengcan/node-shell .
docker push -a zhengcan/node-shell
