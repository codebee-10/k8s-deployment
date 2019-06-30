#!/bin/bash

set -e

echo "remove docker ..."
#remove docker
sudo yum remove -y docker \
				  docker-ce \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-selinux \
                  docker-engine-selinux \
                  docker-engine

rm -rf /etc/systemd/system/docker.service.d
rm -rf /var/lib/docker
rm -rf /var/run/docker


echo "remove kubelet kubeadm kubectl ..."
#remove kubelet kubeadm kubectl
kubeadm reset -f
yum remove -y  kubectl kubeadm kubelet
modprobe -r ipip
lsmod
rm -rf ~/.kube/
rm -rf /etc/kubernetes/
rm -rf /etc/systemd/system/kubelet.service.d
rm -rf /etc/systemd/system/kubelet.service
rm -rf /usr/bin/kube*
rm -rf /etc/cni
rm -rf /opt/cni
rm -rf /var/lib/etcd
rm -rf /var/etcd

rm -rf /etc/kubernetes/manifests/etcd.yaml
rm -rf /etc/kubernetes/manifests/kube-scheduler.yaml
rm -rf /etc/kubernetes/manifests/kube-controller-manager.yaml
rm -rf /etc/kubernetes/manifests/kube-apiserver.yaml


echo "finished ..."