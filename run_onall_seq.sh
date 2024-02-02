#!/bin/bash
if [ $# -lt 1 ]; then
	echo " Please mention command to run "
	exit 1
else
	echo "Command that will be running in all  nodes is:  ${@} "
fi
for sim in {hpc-master,hpc-client-1,hpc-client-2,hpc-client-3}
do
	echo -e "\n ############## $sim ################## \n"
        ssh -o StrictHostKeyChecking=no root@${sim} "${@}"
done
