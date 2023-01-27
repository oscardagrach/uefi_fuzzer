#!/bin/bash
#
# kAFL helper script to build and launch UEFI components
#
# Copyright 2019-2020 Intel Corporation
# SPDX-License-Identifier: MIT
#

set -e

function usage() {
  cat >&2 << HERE

Fuzz EDK2/OVMF

Usage: $0 <target>

Targets:
  fuzz           - fuzz EDK/OVMF in kAFL
  noise <file>   - process <file> in trace mode to collect coverage info
  cov <dir>      - process <dir> in trace mode to collect coverage info
HERE
  exit
}

function fail {
  echo -e "\nError: $@\n" >&2
  exit 1
}

function fuzz()
{
  # Note: -ip0 depends on your UEFI build and provided machine memory!
  # To debug qemu, append -D -d to qemu extra and you'll have qemu logs
  kafl fuzz --purge \
    --bios $TARGET_BIN \
    $TARGET_RANGE \
    --work-dir /dev/shm/kafl_uefi \
    $KAFL_OPTS $*
}

function noise()
{
  pushd $KAFL_ROOT/fuzzer
  TEMPDIR=$(mktemp -d -p /dev/shm)
  WORKDIR=$1; shift
  echo
  echo "Using temp workdir >>$TEMPDIR<<.."
  echo
  sleep 1

  # Note: VM configuration and trace settings should match those used during fuzzing
  kafl debug --action noise --purge \
    --bios $TARGET_BIN \
    $TARGET_RANGE \
    --work-dir $TEMPDIR \
    --input $WORKDIR $*
  popd
}

function cov()
{
  WORKDIR=$1
  echo
  echo "Using temp workdir >>$TEMPDIR<<.."
  echo
  sleep 1

  # Note: VM configuration and trace settings should match those used during fuzzing
  kafl cov --resume \
    --bios $TARGET_BIN \
    $TARGET_RANGE \
    --work-dir $WORKDIR \
    --input $WORKDIR
  popd
}


##
## Main
##

# check basic env setup
test -z ${KAFL_ROOT-} && fail "Could not find \$KAFL_ROOT. Missing 'make env'?"
[ -d $KAFL_ROOT/fuzzer ] || fail "Please set correct KAFL_ROOT"

# edk2 overrides the kAFL WORKSPACE so we base everything in SCRIPT_ROOT
SCRIPT_ROOT="$(cd `dirname $0` && pwd)"

##
## Fuzzer / Target Configuration
##

KAFL_CONFIG_FILE="$SCRIPT_ROOT/kafl.yaml"
TARGET_BIN=$SCRIPT_ROOT/OVMF.fd

CMD=$1; shift || usage

case $CMD in
  "fuzz")
    fuzz $*
    ;;
  "noise")
    test -f "$1" || usage
    noise $*
    ;;
  "cov")
    test -d "$1" || usage
    cov $1
    ;;
  *)
    usage
    ;;
esac
