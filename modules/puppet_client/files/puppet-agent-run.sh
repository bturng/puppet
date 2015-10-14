#!/bin/bash

# Puppet controlled file
# cygnus:modules/puppet_client/files/puppet-agent-run.sh

# This script runs the puppet agent

# Set timeout var in seconds
declare -i TMOUT=900

PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin
export PATH

puppet=`which puppet`

if [ -x "$puppet" ]; then
    # Set variable for current time in epoch and RVAL int var
    EPOCHNOW=`date +%s`
    declare -i RVAL=0

    # Check for hung puppetd process and kill it
    for PUPDPID in `pgrep -f "puppet agent"`; do
        PUPDSTART=`stat -c %Y /proc/${PUPDPID}`  # Start time in epoch
        declare -i PUPDRUNSEC=${EPOCHNOW}-${PUPDSTART}

        # has puppetd been running for more than 55 minutes?
        if [ ${PUPDRUNSEC} -gt ${TMOUT} ]; then
            echo -n "Killing hung/defunct puppet agent process (${PUPDPID})... "
            kill -9 ${PUPDPID} 2>&1 >>/dev/null
            if [ $? -ne 0 ]; then
                echo "FAIL!"
                echo "Error - failed to kill hung/defunct puppet agent process (${PUPDPID})!!"
                exit 2
            else
                echo "OK"
            fi
        else
            declare -i TMOUTMINS=${TMOUT}/60
            echo "Warning - puppet agent is currently running and has been doing so for less than ${TMOUTMINS} minutes"
            echo "          aborting the automated run to let the current puppetd complete"
            exit 1
        fi

    done

    sleep 5

    # Now... let's actually run puppetd if we've made it this far
    $puppet agent --onetime 2>&1 >>/dev/null

else
    echo "Error - puppet not installed.... this is fatal"
    exit -1

fi
