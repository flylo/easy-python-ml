#!/usr/bin/env bash

image_version="midi-ml:0.0.1"

usage="Usage: sh deployment.sh [build|run|local-notebook]"

if [ $# -ne 1 ];
    then echo "${usage}"
    exit 1
fi

if [ $1 = "build" ]
then
    docker build -t ${image_version} .

elif [ $1 = "run" ]
then
    docker run -it -p 8888:8888 ${image_version}

elif [ $1 = "local-notebook" ]
then
    echo "notebook running at `docker-machine ls | grep default | \
            awk '{print $5}' | \
            awk '{ gsub("tcp://", "http://") ; system( "echo "  $0)}' | \
            awk '{ gsub(":2376", ":8888") ; system("echo " $0)}'`"

else
    echo "${usage}"

fi
