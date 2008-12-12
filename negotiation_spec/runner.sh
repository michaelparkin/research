#!/bin/bash
# File to run a set of TLC model checks on the specification
# name passed as the first argument to the script. All results
# from the run will be dumped to a file called `results` in
# the current directory.
# This script expects the config files for TLC to exist in the
# ./config directory. See the 'config_maker.rb' script for how
# to create a set of config files.
# Note the JVM settings may need to be changed for the
# environment the TLC model checker is being run.

if [ ! -n "$1" ]; then
  echo "Usage: `basename $0` [TLA spec name]"
  exit 1
fi

if [ -f results ]; then
  RUNTIME=`date '+%m%d%y-%H%M%S'`
  mv results results.$RUNTIME
fi

for FILE in `ls -tr ./config/*.cfg`; do
  LENGTH=`expr length $FILE`
  DELIM=`expr index "$FILE" x`
  MESSAGES=`expr substr $FILE 10 $(($DELIM-10))`
  DUPLICATES=`expr substr $FILE $(($DELIM+1)) $(($LENGTH-$DELIM-4))`
  START=`date +%s`
  echo "Model start time: $START" >> results
  echo "Messages: $MESSAGES Duplicates: $DUPLICATES" >> results
  java -Xms512m -Xmx640m -cp /home/mparkin/tla2 tlc.TLC -cleanup -deadlock -config $FILE $1.tla >> results
  FINISH=`date +%s`
  echo "Model end time: $FINISH" >> results
  echo >> results
  rm -rf ./states
  sleep 2
done


