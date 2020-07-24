#!/bin/bash
set -e
#set -x

echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo " 01-client-tools.sh "
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
ssh -i ../../.vagrant/machines/kubemaster/virtualbox/private_key \
    vagrant@192.168.56.2 /bin/bash /vagrant/ubuntu/run/01-client-tools.sh
    
echo "appending master's .ssh/id_rsa.pub to other nodes' authorized_keys!"
for e in kubenode01 kubenode02 loadbalancer; do
    if [[ ${e} == 'kubenode01' ]]; then
        ip=192.168.56.3
        instance='kubenode01'
    elif [[ ${e} == 'kubenode02' ]]; then
        ip=192.168.56.4
        instance='kubenode02'
    fi
    ssh -o IdentitiesOnly=yes -i ../../.vagrant/machines/${instance}/virtualbox/private_key vagrant@${ip} \
        /bin/bash /vagrant/ubuntu/run/prepare.sh
done

exit 0;

rm -Rf authorized_keys

echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo " 02-Creating a single control-plane cluster.sh "
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
ssh -i ../../.vagrant/machines/kubemaster/virtualbox/private_key vagrant@192.168.56.2 \
        /bin/bash /vagrant/ubuntu/run/02-Creating a single control-plane cluster.sh


