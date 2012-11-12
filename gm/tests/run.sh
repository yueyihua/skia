#!/bin/bash

# Self-tests for gm, based on tools/tests/run.sh

# cd into .../trunk so all the paths will work
cd $(dirname $0)/../..

# TODO(epoger): make it look in Release and/or Debug
GM_BINARY=out/Debug/gm

# Compare contents of all files within directories $1 and $2,
# EXCEPT for any dotfiles.
# If there are any differences, a description is written to stdout and
# we exit with a nonzero return value.
# Otherwise, we write nothing to stdout and return.
function compare_directories {
  if [ $# != 2 ]; then
    echo "compare_directories requires exactly 2 parameters, got $#"
    exit 1
  fi
  diff -r --exclude=.* $1 $2
  if [ $? != 0 ]; then
    echo "failed in: compare_directories $1 $2"
    exit 1
  fi
}

# Run gm...
# - with the arguments in $1
# - writing resulting images into $2/output-actual/images
# - writing stdout into $2/output-actual/stdout
# - writing return value into $2/output-actual/return_value
# Then compare all of those against $2/output-expected .
function gm_test {
  if [ $# != 2 ]; then
    echo "gm_test requires exactly 2 parameters, got $#"
    exit 1
  fi
  GM_ARGS="$1"
  ACTUAL_OUTPUT_DIR="$2/output-actual"
  EXPECTED_OUTPUT_DIR="$2/output-expected"

  rm -rf $ACTUAL_OUTPUT_DIR
  mkdir -p $ACTUAL_OUTPUT_DIR
  COMMAND="$GM_BINARY $GM_ARGS -w $ACTUAL_OUTPUT_DIR/images"
  echo "$COMMAND" >$ACTUAL_OUTPUT_DIR/command_line
  $COMMAND &>$ACTUAL_OUTPUT_DIR/stdout
  echo $? >$ACTUAL_OUTPUT_DIR/return_value

  compare_directories $EXPECTED_OUTPUT_DIR $ACTUAL_OUTPUT_DIR
}

GM_TESTDIR=gm/tests
GM_INPUTS=$GM_TESTDIR/inputs
GM_OUTPUTS=$GM_TESTDIR/outputs

gm_test "--hierarchy --match dashing --config 4444 -r $GM_INPUTS/dashing-correct-images" "$GM_OUTPUTS/dashing-compared-against-correct"

# In this case, dashing.png has different pixels, but dashing2.png differs only in PNG encoding (identical pixels)
gm_test "--hierarchy --match dashing --config 4444 -r $GM_INPUTS/dashing-incorrect-images" "$GM_OUTPUTS/dashing-compared-against-incorrect"

echo "All tests passed."
