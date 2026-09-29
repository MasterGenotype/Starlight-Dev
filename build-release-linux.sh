#!/bin/bash
# Linux build for Starlight-Dev.
# The upstream build-release.sh uses `sysctl -n hw.ncpu`, which is macOS-only:
# on Linux it fails, --parallel gets an empty argument, and the build spawns an
# unbounded number of compilers until the machine runs out of memory.
# Here the job count is derived from BOTH cores and free RAM (~2 GB per C++ TU).
set -e
cd "$(dirname "$0")"

CORES=$(nproc)
MEM_GB=$(awk '/MemAvailable/ {printf "%d", $2/1024/1024}' /proc/meminfo)
BY_MEM=$(( MEM_GB / 2 )); [ "$BY_MEM" -lt 1 ] && BY_MEM=1
JOBS=$(( CORES < BY_MEM ? CORES : BY_MEM ))
[ -n "$1" ] && JOBS="$1"

echo "cores=$CORES  available=${MEM_GB}G  -> building with -j$JOBS"

mkdir -p build && cd build
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_POLICY_VERSION_MINIMUM=3.5 ..
cmake --build . --config Release --parallel "$JOBS"
cd ..

mkdir -p rootDir
cp -f build/src/Starlight rootDir/Starlight
echo "Done. Output: rootDir/Starlight"
