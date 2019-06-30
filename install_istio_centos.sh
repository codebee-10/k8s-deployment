#!/bin/bash

set -e

sudo cd /usr/local/etc/
sudo git clone https://github.com/roancsu/k8s_deployment.git
sudo unzip istio-1.2.0 -d istio-1.2.0

echo "install istio to kubernetes cluster ..."

echo "mv istio to env ..."


sudo export PATH="$PATH:/usr/local/etc/istio-1.2.0/bin"

sudo istioctl verify-install

echo "install finished ..."