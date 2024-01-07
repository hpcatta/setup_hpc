#!/bin/bash
echo "Now starting the Slurm GUI service"
/usr/bin/python3 /data/gui/slurm_gui/main.py >> /var/log/slurm_gui.log
