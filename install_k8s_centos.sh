#!/bin/bash

set -e

echo "install kubernetes docker on linux ..."

echo "set aliyun resource ..."
#set aliyun resource

cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=0
EOF

echo "set machine core ..."
#set machine core
# cat <<EOF > /etc/sysctl.conf
# net.bridge.bridge-nf-call-ip6tables = 1
# net.bridge.bridge-nf-call-iptables = 1
# EOF

#sysctl -p


#update
yum -y update


echo "install kubelet kubectl kubeadm and docker ..."
#install Kubelet and Docker
yum install -y docker kubelet kubeadm kubectl kubernetes-cni
systemctl enable docker
systemctl start docker
systemctl enable kubelet


echo "init kubernetes master ..."
#init the master
#kubernetes version is v1.15.0 
kubeadm init --image-repository registry.aliyuncs.com/google_containers --kubernetes-version v1.15.0 --pod-network-cidr=10.244.0.0/16


echo "set kube config ..."
#set Kube config :
cp -f /etc/kubernetes/admin.conf $HOME/
chown $(id -u):$(id -g) $HOME/admin.conf
export KUBECONFIG=$HOME/admin.conf
echo "export KUBECONFIG=$HOME/admin.conf" >>  ~/.bash_profile


echo "allow master run pod ..."
#allow master run pod
kubectl taint nodes --all node-role.kubernetes.io/master-


echo "install Flannel ..."
#Install Flannel
curl -sSL "https://github.com/coreos/flannel/blob/master/Documentation/kube-flannel.yml?raw=true" | kubectl create -f -

echo "install kubernetes dashboard ..."
#install dashboard
#pull dashboard images
docker pull mirrorgooglecontainers/kubernetes-dashboard-amd64:v1.10.1
#update image name
docker tag docker.io/mirrorgooglecontainers/kubernetes-dashboard-amd64:v1.10.1  k8s.gcr.io/kubernetes-dashboard-amd64:v1.10.1
#create dashboard pod
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/master/aio/deploy/recommended/kubernetes-dashboard.yaml


echo "close selinux ..."
#close selinux
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
setenforce 0

echo "install kubernetes docker finished ..."





