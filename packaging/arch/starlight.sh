#!/bin/sh
# Starlight resolves every path relative to its working directory - Assets/,
# WorkingDir/, imgui.ini and crash_log.txt all live there - so it cannot simply
# be run from /usr/bin. Give each user their own writable directory, seeded once
# from the packaged template, and run from inside it.
set -eu

DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
RUNDIR="$DATA_HOME/starlight"
SHARE=/usr/share/starlight

mkdir -p "$RUNDIR"

# Assets are read-only and updated by the package: keep them as a symlink so an
# upgrade is picked up without the user having to clear anything out.
ln -sfn "$SHARE/Assets" "$RUNDIR/Assets"

# WorkingDir holds the user's projects, cache and definitions - seed it once,
# then never touch it again.
if [ ! -d "$RUNDIR/WorkingDir" ]; then
    cp -a "$SHARE/WorkingDir" "$RUNDIR/WorkingDir"
    chmod -R u+w "$RUNDIR/WorkingDir"
fi
mkdir -p "$RUNDIR/WorkingDir/Cache" "$RUNDIR/WorkingDir/Projects"

cd "$RUNDIR"
exec /usr/lib/starlight/Starlight "$@"
