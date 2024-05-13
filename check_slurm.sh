#!/bin/bash
# check_slurm.sh

status=$(systemctl is-active slurmd)
if [ "$status" = "active" ]; then
    echo "OK - Slurmd service is running."
    exit 0
else
    echo "CRITICAL - Slurmd service is not running."
    exit 2
fi
