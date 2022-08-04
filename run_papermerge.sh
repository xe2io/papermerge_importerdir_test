#!/bin/sh

# Note: uid/gid on the host may not match those in-container when user/group id mapping is used (e.g. rootless docker, podman)
uid=1000
gid=1000

# Create directories for papermerge persistence and importer/watch directory
for dir in config data watchdir; do
    [ -d "$dir" ] || ( mkdir "$dir" && chown -R "$uid:$gid" "$dir" )
done

ce=$(which podman 2>/dev/null) || ce=$(which docker 2>/dev/null) || ce='echo -e Please install a container engine to run:\n    <ce> '
gitroot=$(git rev-parse --show-toplevel 2>/dev/null || pwd)

"$ce" run \
  --name=papermerge \
  --rm \
  -e PUID="$uid" \
  -e PGID="$gid" \
  -e TZ=UTC \
  -p 8000:8000 \
  -v "$gitroot/config":/config \
  -v "$gitroot/data":/data \
  -v "$gitroot/watchdir":/consume \
  lscr.io/linuxserver/papermerge:latest
  

# The linuxserver (and official papermerge images both copy the default papermerge.conf.py (no value updates)
#  -e PAPERMERGE__IMPORTER__DIR="/consume" \
