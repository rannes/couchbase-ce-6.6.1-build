# couchbase-ce-6.6.1-build

One-shot GitHub Actions build of **Couchbase Server Community Edition 6.6.1**
from the upstream `couchbase/manifest` source tree.

Couchbase Inc. never published a CE 6.6.1 release (no image, no `.deb`, no
`.rpm` exists publicly). Source is available at the SHAs in
[`released/couchbase-server/6.6.1.xml`](https://github.com/couchbase/manifest/blob/master/released/couchbase-server/6.6.1.xml),
licensed Apache 2.0 / BSD / MIT. Built here with `BUILD_ENTERPRISE=OFF` to
exclude the closed-source EE modules.

## Run

Push to `main` or trigger `workflow_dispatch` from the Actions tab.
Artifact `couchbase-ce-6.6.1` will be attached to the workflow run.

## Local equivalent

    docker build -t cb661-build .
    mkdir -p work && cp build.sh work/
    docker run --rm -v "$PWD/work:/work" cb661-build bash /work/build.sh

## Deviations from upstream

- `couchbasedeps/aws-sdk-go` SHA `8102d31d…` is reachable via direct fetch
  but not from any branch HEAD — `build.sh` pre-clones it before `repo sync`.
- CMake is bumped to 3.19 (Bionic ships 3.10, Couchbase needs ≥ 3.12).
- `BUILD_ENTERPRISE=OFF` — produces CE binaries; excludes analytics,
  eventing-ee, backup-service, etc.
- `tlm/cmake/Modules/CBDownloadDeps.cmake` — Go download URL rewritten
  from `storage.googleapis.com/golang/` (404s on old versions) to
  `dl.google.com/go/`.
- Container locale set to `en_US.UTF-8` — CMake's tar wrapper rejects
  non-ASCII filenames inside Go tarballs without a UTF-8 locale.
- Linker: `-no-pie` + `CMAKE_POSITION_INDEPENDENT_CODE=OFF`. Bionic's
  default-PIE binaries can't link against the cbdep prebuilt
  flatbuffers/etc. static libs (compiled non-PIC for that era).
