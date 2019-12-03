#!/bin/bash

set -e

echo "install kubernetes docker on ubuntu ..."

echo "set aliyun resource ..."
#set aliyun resource

echo "" > /etc/apt/sources.list

cat <<EOF> /etc/apt/sources.list
deb http://mirrors.163.com/ubuntu/ xenial main
deb-src http://mirrors.163.com/ubuntu/ xenial main

deb http://mirrors.163.com/ubuntu/ xenial-updates main
deb-src http://mirrors.163.com/ubuntu/ xenial-updates main

deb http://mirrors.163.com/ubuntu/ xenial universe
deb-src http://mirrors.163.com/ubuntu/ xenial universe
deb http://mirrors.163.com/ubuntu/ xenial-updates universe
deb-src http://mirrors.163.com/ubuntu/ xenial-updates universe

deb http://mirrors.163.com/ubuntu/ xenial-security main
deb-src http://mirrors.163.com/ubuntu/ xenial-security main
deb http://mirrors.163.com/ubuntu/ xenial-security universe
deb-src http://mirrors.163.com/ubuntu/ xenial-security universe
EOF

apt-get install apt-transport-https ca-certificates curl software-properties-common lrzsz -y

apt-get update && apt-get install -y apt-transport-https
curl https://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg | apt-key add -

echo "deb https://mirrors.aliyun.com/kubernetes/apt/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list

apt-get update

echo "set machine core ..."
#set machine core
# cat <<EOF > /etc/sysctl.conf
# net.bridge.bridge-nf-call-ip6tables = 1
# net.bridge.bridge-nf-call-iptables = 1
# EOF

# sysctl -p


#update
apt-get -y update


echo "install kubelet kubectl kubeadm and docker ..."
#install Kubelet and Docker
apt-get install -y docker.io kubelet kubeadm kubectl kubernetes-cni

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
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v1.10.1/src/deploy/recommended/kubernetes-dashboard.yaml

# kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta1/aio/deploy/recommended.yaml


echo "close selinux ..."
#close selinux
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
setenforce 0

swapoff -a

echo "master install kubernetes docker finished ..."





