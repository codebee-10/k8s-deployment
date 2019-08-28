#!/bin/bash

set -e

echo "install kubernetes docker on linux ..."

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

curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | apt-key add -

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


echo "pull docker images ..."

docker pull registry.aliyuncs.com/google_containers/kube-proxy:v1.15.0
docker pull registry.aliyuncs.com/google_containers/coredns:1.3.1
docker pull registry.aliyuncs.com/google_containers/pause:3.1


echo "close selinux ..."
#close selinux
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
setenforce 0

echo "node install kubernetes docker finished ..."




