#!/bin/sh

ce=$(which podman 2>/dev/null) || ce=$(which docker 2>/dev/null) || ce='echo -e Please install a container engine to run:\n    <ce> '
gitroot=$(git rev-parse --show-cdup 2>/dev/null || pwd)

"$ce" run \
  --name=papermerge \
  --rm \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=UTC \
  -p 8000:8000 \
  -v "$gitroot/config":/config \
  -v "$gitroot/data":/data \
  -v "$gitroot/watchdir":/consume \
  lscr.io/linuxserver/papermerge:latest
  

# The linuxserver (and official papermerge images both copy the default papermerge.conf.py (no value updates)
#  -e PAPERMERGE__IMPORTER__DIR="/consume" \
