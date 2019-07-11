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


echo "pull docker images ..."

docker pull registry.aliyuncs.com/google_containers/kube-proxy:v1.15.0
docker pull registry.aliyuncs.com/google_containers/coredns:1.3.1
docker pull registry.aliyuncs.com/google_containers/pause:3.1


echo "close selinux ..."
#close selinux
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
setenforce 0

echo "node install kubernetes docker finished ..."




