#!/bin/bash
set -e
#set -x

echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo " 01-client-tools.sh "
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
ssh -i ../../.vagrant/machines/kubemaster/virtualbox/private_key \
    vagrant@192.168.56.2 /bin/bash /vagrant/ubuntu/run/01-client-tools.sh
    
echo "appending master's .ssh/id_rsa.pub to other nodes' authorized_keys!"
for e in kubemaster kubenode01 kubenode02 loadbalancer; do
    if [[ ${e} == 'kubemaster' ]]; then
        ip=192.168.56.2
        instance='kubemaster'
	elif [[ ${e} == 'kubenode01' ]]; then
        ip=192.168.56.3
        instance='kubenode01'
    elif [[ ${e} == 'kubenode02' ]]; then
        ip=192.168.56.4
        instance='kubenode02'
    fi
    ssh -o IdentitiesOnly=yes -i ../../.vagrant/machines/${instance}/virtualbox/private_key vagrant@${ip} \
        /bin/bash /vagrant/ubuntu/run/prepare.sh
done

rm -Rf authorized_keys

echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo " 02-creating_single_control_plane_cluster.sh "
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
ssh -i ../../.vagrant/machines/kubemaster/virtualbox/private_key vagrant@192.168.56.2 \
        /bin/bash /vagrant/ubuntu/run/02-creating_single_control_plane_cluster.sh
sleep 3
ssh -i ../../.vagrant/machines/kubenode01/virtualbox/private_key vagrant@192.168.56.3 \
        /bin/bash /vagrant/ubuntu/run/02.2-creating_single_control_plane_cluster.sh
ssh -i ../../.vagrant/machines/kubenode02/virtualbox/private_key vagrant@192.168.56.4 \
        /bin/bash /vagrant/ubuntu/run/02.2-creating_single_control_plane_cluster.sh
echo sleep 30
sleep 30
ssh -i ../../.vagrant/machines/kubemaster/virtualbox/private_key vagrant@192.168.56.2 \
        /bin/bash /vagrant/ubuntu/run/02.3-creating_single_control_plane_cluster.sh

echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo " 03-bootstrapping-etcd.sh "
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
ssh -i ../../.vagrant/machines/kubemaster/virtualbox/private_key vagrant@192.168.56.2 \
        /bin/bash /vagrant/ubuntu/run/03-bootstrapping-etcd.sh

echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo " 04-smoke-test.sh "
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
ssh -i ../../.vagrant/machines/kubemaster/virtualbox/private_key vagrant@192.168.56.2 \
        /bin/bash /vagrant/ubuntu/run/04-smoke-test.sh



