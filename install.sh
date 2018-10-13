#!/bin/bash

printf "Starting install dependencies\n"
apt-get -y update
apt-get -y install docker gradle
