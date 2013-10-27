#!/usr/bin/env bash

#@BEGIN: SYSTEM UPDATE SCRIPT
HOSTNAME=`hostname`
DATE_FILE=/vagrant/provision/shell/update-$HOSTNAME.out
NOW=`date +"%Y%m"`

# Check if the $DATE_FILE exists
# This file stores the date of the last update
if [ ! -f $DATE_FILE ]; then
  # $DATE_FILE file was not found

  # Write the current date into a temporary file
  echo $NOW > $DATE_FILE

  # Update system
  apt-get update
else
  # Get the date of the last update
  LAST_UPDATE=`head -n 1 $DATE_FILE`

  # Check if update was done in the last month
  # Used only for testing purposes
  # LAST_UPDATE=$(( $LAST_UPDATE - 1 ))

  # If update was done at least two months ago do it again
  if [ $LAST_UPDATE -lt $NOW ]; then
    # Write the current date into a temporary file
    echo $NOW > $DATE_FILE

    # Update system
    apt-get update
  fi
fi
#@END: SYSTEM UPDATE SCRIPT