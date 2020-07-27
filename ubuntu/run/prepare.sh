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

sudo groupadd docker
sudo chmod 777 /var/run/docker.sock

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


exit 0


export DEBIAN_FRONTEND=noninteractive 
sudo usermod -aG docker vagrant
apt-get update \
    && apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        software-properties-common \
    && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - \
    && add-apt-repository \
        "deb https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
        $(lsb_release -cs) \
        stable" \
    && apt-get update \
    && apt-get install -y docker-ce=$(apt-cache madison docker-ce | grep 18.06 | head -1 | awk '{print $3}') --allow-downgrades
    
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

sudo mkdir -p /etc/systemd/system/docker.service.d

sudo systemctl daemon-reload
sudo systemctl restart docker

sudo systemctl enable docker    

