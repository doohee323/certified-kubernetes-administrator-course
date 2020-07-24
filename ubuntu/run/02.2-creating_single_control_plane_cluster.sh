#!/bin/bash
set -e
#set -x

echo "====================================================================="
echo " network join"
echo "====================================================================="

JOIN_CMD1=`tail /vagrant/kubeadm.log -n 2 | head -n 1`
JOIN_CMD1=${JOIN_CMD1:0:${#JOIN_CMD1}-1}
JOIN_CMD2=`tail /vagrant/kubeadm.log -n 1`
JOIN_CMD=`echo $JOIN_CMD1 $JOIN_CMD2`

echo $JOIN_CMD
sudo $JOIN_CMD
