#!/bin/bash

set -e

# sudo git clone https://github.com/roancsu/k8s_deployment.git
# sudo cd k8s_deployment/istio/ && unzip istio-1.2.0 -d istio && mv istio /usr/local/etc/

echo "install istio to kubernetes cluster ..."

curl -L https://git.io/getLatestIstio | ISTIO_VERSION=1.2.0 sh -

echo "mv istio to env ..."


export PATH="$PATH:$PWD/istio-1.2.0/bin"

istioctl verify-install

echo "istio install finished ..."

echo "install helm ..."
# install helm
.helm/install_helm_centos.sh

echo "install helm tiller"
# install tiller
helm init --service-account tiller --upgrade --tiller-image=registry.cn-hangzhou.aliyuncs.com/google_containers/tiller:v2.14.1

echo "helm tiller install finished ..."

# helm create kubernetes-istio：
helm install install/kubernetes/helm/istio-init --name istio --namespace istio-system \
--set tracing.enabled=true \
--set kiali.enabled=true \
--set grafana.enabled=true \
--set servicegraph.enabled=true \
--set prometheus.enabled=true \
--set tracing.jaeger.enabled=true \
--set global.configValidation=false \
--set global.nodePort=true 

# display istio pods
kubectl get pods --all-namespaces

echo "kubernetes istio mesh install finished ..."



