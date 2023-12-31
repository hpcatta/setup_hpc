################################################################################
# Copyright (C) 2019-2023 NI SP GmbH
# All Rights Reserved
#
# info@ni-sp.com / www.ni-sp.com
#
# We provide the information on an as is basis.
# We provide no warranties, express or implied, related to the
# accuracy, completeness, timeliness, useability, and/or merchantability
# of the data and are not liable for any loss, damage, claim, liability,
# expense, or penalty, or for any direct, indirect, special, secondary,
# incidental, consequential, or exemplary damages or lost profit
# deriving from the use or misuse of this information.
################################################################################
# Version v1.5
#
# SLURM Build and Installation script for Redhat/CentOS EL7, EL8 and EL9
#
# See also https://www.slothparadise.com/how-to-install-slurm-on-centos-7-cluster/
# https://slurm.schedmd.com/quickstart_admin.html
# https://wiki.fysik.dtu.dk/niflheim/Slurm_installation
# https://slurm.schedmd.com/faq.html
 

# For all the nodes, before you install Slurm or Munge:
 
# sudo su -
export MUNGEUSER=966
sudo groupadd -g $MUNGEUSER munge
sudo useradd  -m -c "MUNGE Uid 'N' Gid Emporium" -d /var/lib/munge -u $MUNGEUSER -g munge  -s /sbin/nologin munge
export SLURMUSER=967
sudo groupadd -g $SLURMUSER slurm
sudo useradd  -m -c "SLURM workload manager" -d /var/lib/slurm -u $SLURMUSER -g slurm  -s /bin/bash slurm
# exit
 
# For CentOS 7: need to get the latest EPEL repository.
sudo yum install epel-release -y
if [ "$OSVERSION" == "7" ] ; then
    sudo yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm -y
    # sudo dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
fi
if [ "$OSVERSION" == "8" ] ; then
    sudo yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm -y
    # sudo dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
fi
if [ "$OSVERSION" == "9" ] ; then
    sudo yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm -y
    # sudo dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
fi
 
# install munge
if [ "$OSVERSION" == "7" ] ; then
    sudo yum install munge munge-libs munge-devel -y
fi
if [ "$OSVERSION" == "8" ] ; then
    sudo yum install munge munge-libs  -y
    sudo dnf --enablerepo=powertools install munge-devel -y
fi
if [ "$OSVERSION" == "9" ] ; then
    sudo yum install munge munge-libs  -y
    sudo dnf --enablerepo=crb install mariadb-devel munge-devel -y
fi
sudo yum install rng-tools -y
sudo rngd -r /dev/urandom
 
# exit
 
##sudo /usr/sbin/create-munge-key -r -f
 
##sudo sh -c  "dd if=/dev/urandom bs=1 count=1024 > /etc/munge/munge.key"
cp -rp /omni/apps/slurm/munge /etc/
sudo chown munge: /etc/munge/munge.key
sudo chmod 400 /etc/munge/munge.key
 
sudo systemctl enable munge
sudo systemctl start munge
 
# build and install SLURM
sudo yum install python3 gcc openssl openssl-devel pam-devel numactl numactl-devel hwloc lua readline-devel ncurses-devel man2html libibmad libibumad rpm-build  perl-ExtUtils-MakeMaker.noarch -y
if [ "$OSVERSION" == "7" ] ; then
    sudo yum install rrdtool-devel lua-devel hwloc-devel -y
fi
if [ "$OSVERSION" == "8" ] ; then
    sudo yum install rpm-build make -y
    # dnf --enablerepo=PowerTools install rrdtool-devel lua-devel hwloc-devel -y
    sudo dnf --enablerepo=powertools install rrdtool-devel lua-devel hwloc-devel rpm-build -y
    # dnf group install "Development Tools"
fi
if [ "$OSVERSION" == "9" ] ; then
    sudo yum install rpm-build make -y
    # dnf --enablerepo=PowerTools install rrdtool-devel lua-devel hwloc-devel -y
    sudo dnf --enablerepo=crb install rrdtool-devel lua-devel hwloc-devel -y
    # dnf group install "Development Tools"
fi
cp -rp /omni/apps/slurm/rpmbuild /root/ 
 
# get perl-Switch
# sudo yum install cpan -y
 
cd ~/rpmbuild/RPMS/x86_64/
 
# skipping slurm-openlava and slurm-torque because of missing perl-Switch
sudo yum --nogpgcheck localinstall slurm-[0-9]*.el*.x86_64.rpm slurm-contribs-*.el*.x86_64.rpm slurm-devel-*.el*.x86_64.rpm \
slurm-example-configs-*.el*.x86_64.rpm slurm-libpmi-*.el*.x86_64.rpm  \
slurm-pam_slurm-*.el*.x86_64.rpm slurm-perlapi-*.el*.x86_64.rpm slurm-slurmctld-*.el*.x86_64.rpm \
slurm-slurmd-*.el*.x86_64.rpm slurm-slurmdbd-*.el*.x86_64.rpm -y
 
cp -rp /omni/apps/slurm/slurm /etc/

 
 
sudo mkdir /var/spool/slurm
sudo chown slurm:slurm /var/spool/slurm
sudo chmod 755 /var/spool/slurm
sudo mkdir /var/spool/slurm/cluster_state
sudo chown slurm:slurm /var/spool/slurm/cluster_state
sudo touch /var/log/slurm_jobacct.log /var/log/slurm_jobcomp.log
sudo chown slurm: /var/log/slurm_jobacct.log /var/log/slurm_jobcomp.log
 
# firewall will block connections between nodes so in case of cluster
# with multiple nodes adapt the firewall on the compute nodes
#
# sudo systemctl stop firewalld
# sudo systemctl disable firewalld
 
# on the master node
#sudo firewall-cmd --permanent --zone=public --add-port=6817/udp
#sudo firewall-cmd --permanent --zone=public --add-port=6817/tcp
#sudo firewall-cmd --permanent --zone=public --add-port=6818/tcp
#sudo firewall-cmd --permanent --zone=public --add-port=6818/tcp
#sudo firewall-cmd --permanent --zone=public --add-port=7321/tcp
#sudo firewall-cmd --permanent --zone=public --add-port=7321/tcp
#sudo firewall-cmd --reload
 
# sync clock on master and every compute node
#sudo yum install ntp -y
#sudo chkconfig ntpd on
#sudo ntpdate pool.ntp.org
#sudo systemctl start ntpd
 

 
# on compute nodes
sudo systemctl enable slurmd.service
sudo systemctl start slurmd.service
 
echo Sleep for a few seconds for slurmd to come up ...
sleep 3
 
# on master
sudo chmod 777 /var/spool   # hack for now as otherwise slurmctld is complaining

 
echo Sleep for a few seconds for slurmctld to come up ...
sleep 3
 
# checking
# sudo systemctl status slurmd.service
# sudo journalctl -xe
 
# if you experience an error with starting up slurmd.service
# like "fatal: Incorrect permissions on state save loc: /var/spool"
# then you might want to adapt with chmod 777 /var/spool
 
# more checking
# sudo slurmd -Dvvv -N YOUR_HOSTNAME
# sudo slurmctld -D vvvvvvvv
# or tracing with sudo strace slurmctld -D vvvvvvvv
 
# echo Compute node bugs: tail /var/log/slurmd.log
# echo Server node bugs: tail /var/log/slurmctld.log
 
# show cluster
echo
echo Output from: \"sinfo\"
sinfo
 
# sinfo -Nle
echo
echo Output from: \"scontrol show partition\"
scontrol show partition
 
# show host info as slurm sees it
echo
echo Output from: \"slurmd -C\"
slurmd -C
 
# in case host is in drain status
# scontrol update nodename=$HOST state=idle
 
echo
echo Output from: \"scontrol show nodes\"
scontrol show nodes
 
# If jobs are running on the node:
# scontrol update nodename=$HOST state=resume
 
# lets run our first job
echo
echo Output from: \"srun hostname\"
srun hostname
 
# if there are issues in scheduling
# turn on debugging
#    sudo scontrol setdebug 6   # or up to 9
# check the journal
#    journalctl -xe
# turn off debugging
#    sudo scontrol setdebug 3
 
# scontrol
# scontrol: show node $HOST
 
# scontrol show jobs
# scontrol update NodeName=ip-172-31-23-216 State=RESUME
# scancel JOB_ID
# srun -N5 /bin/hostname
# after changing the configuration:
#   scontrol reconfigure
#
# more resources
# https://slurm.schedmd.com/quickstart.html
# https://slurm.schedmd.com/quickstart_admin.html
#