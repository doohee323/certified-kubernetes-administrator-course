#!/bin/bash
#set -e
set -x

/bin/cat /vagrant/ubuntu/authorized_keys >> /home/vagrant/.ssh/authorized_keys

cat /etc/os-release

echo "====================================================================="
echo " Install docker"
echo "====================================================================="
cd /tmp
curl -fsSL https://get.docker.com -o get-docker.sh
sh /tmp/get-docker.sh

echo "====================================================================="
echo " Enable OS network module"
echo "====================================================================="
lsmod | grep br_netfilter
sudo modprobe br_netfilter

echo "====================================================================="
echo " Letting iptables see bridged traffic"
echo "====================================================================="
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system

echo "====================================================================="
echo " Installing kubeadm, kubelet and kubectl"
echo "====================================================================="
sudo apt-get update && sudo apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

