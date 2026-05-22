#!/usr/bin/env bash
# Run inside the cb661-build container. Syncs Couchbase 6.6.1 source and compiles CE.
set -euo pipefail

cd /work

if [ ! -d .repo ]; then
  repo init -u https://github.com/couchbase/manifest \
    -m released/couchbase-server/6.6.1.xml
fi

# Manifest pins couchbasedeps/aws-sdk-go @ 8102d31de... — that SHA exists upstream
# but is not on any branch HEAD, so plain repo sync fails to fetch it. Pre-fetch
# the project manually (clone + git fetch <sha>) before repo sync runs.
mkdir -p godeps/src/github.com/aws
if [ ! -d godeps/src/github.com/aws/aws-sdk-go/.git ]; then
  git clone https://github.com/couchbasedeps/aws-sdk-go godeps/src/github.com/aws/aws-sdk-go
  ( cd godeps/src/github.com/aws/aws-sdk-go && \
    git fetch origin 8102d31deafaf68bed0ce981332a749932aa6ab1 && \
    git checkout 8102d31deafaf68bed0ce981332a749932aa6ab1 )
fi

repo sync -j"$(nproc)" --force-sync || echo "repo sync had errors; continuing"

# Old Go versions (1.7.6 .. 1.13) are no longer at storage.googleapis.com/golang/
# but ARE at dl.google.com/go/. Redirect tlm's downloader.
sed -i 's|http://storage.googleapis.com/golang|https://dl.google.com/go|g' \
  tlm/cmake/Modules/CBDownloadDeps.cmake

# CE build: disable enterprise modules.
make -j"$(nproc)" EXTRA_CMAKE_OPTIONS="-DBUILD_ENTERPRISE=OFF"

echo "=== Build artifacts ==="
ls -la /work/install/ 2>/dev/null || echo "no install dir"
