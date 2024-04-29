#!/bin/sh
# list_all.sh
#
# Lists all CRIU JupyterLab images and containers in existence.
#
# Usage:
#   /bin/sh scripts/list_all.sh
#

set -e  # Exit on any error

PREFIX=criu-jupyter

echo
echo "----- Docker images -----"
docker image ls -a | grep -e $PREFIX -e "IMAGE ID"

echo
echo "----- Docker containers -----"
docker container ls -a | grep -e $PREFIX -e "CONTAINER ID"
