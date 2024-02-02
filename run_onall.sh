#!/bin/bash
if [ $# -lt 1 ]; then
	echo " Please mention command to run "
	exit 1
else
	echo "Command that will be running in all  nodes is:  ${@} "
fi
SERVERS="hpc-master\nhpc-client-1\nhpc-client-2\nhpc-client-3"
ARGS=$@
echo -e $SERVERS | xargs -I{} -P8 -n 1 bash -c "ssh -o StrictHostKeyChecking=no root@{} ${ARGS}"
