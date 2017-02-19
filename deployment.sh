#!/usr/bin/env bash

source common.sh

usage="Usage: sh deployment.sh [patch|build|push|deploy|port-forward|tear-down|run-local-notebook]"

if [ $# -ne 1 ];
    then echo "${usage}"
    exit 1
fi

if [ $1 = "patch" ]
then
    patch
elif [ $1 = "build" ]
then
    build
elif [ $1 = "push" ]
then
    push
elif [ $1 = "deploy" ]
then
    deploy
elif [ $1 = "port-forward" ]
then
    port_forward
elif [ $1 = "tear-down" ]
then
    tear_down
elif [ $1 = "run-local-notebook" ]
then
    run_local_notebook
else
    echo "${usage}"
fi
