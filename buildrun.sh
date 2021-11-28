#!/bin/sh

docker build --no-cache -t cloudflareguacamole .
docker run --name cloudflareguacamole --restart always -d cloudflareguacamole
