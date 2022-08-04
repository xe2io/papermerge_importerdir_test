#!/bin/sh
# May need to run with elevated privileges if using podman or rootless docker (where user ids get remapped)
echo "NOTE: does not remove hidden files/dirs (none created by default)"
rm -rf config/* data/*
