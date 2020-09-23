#!/bin/bash

service ssh start
if [ "$HOSTNAME" = node-master ]; then
    start-yarn.sh
fi
#bash
while :; do :; done & kill -STOP $! && wait $!
