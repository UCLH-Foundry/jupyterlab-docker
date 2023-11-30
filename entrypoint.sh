#!/usr/bin/sh

# Entrypoint for JupyterLab instances
start.sh jupyter lab \
  --LabApp.token=${JUPYTER_PASSWORD} \
  --NotebookApp.notebook_dir=/home/jovyan/work \
  --ContentsManager.allow_hidden=true
