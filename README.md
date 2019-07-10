# k8s_deployment
kubernetes deployment sh for centos 7.x

### use install_k8s.sh to deploy k8s

```
sudo ./install_k8s.sh
```

### use uninstall_k8s.sh to remove docker and k8s

```
sudo ./uninstall_k8s.sh
```

### ERROR: "The connection to the server localhost:8080 was refused", you can run under command line :
```
cp -f /etc/kubernetes/admin.conf $HOME/
chown $(id -u):$(id -g) $HOME/admin.conf
export KUBECONFIG=$HOME/admin.conf
echo "export KUBECONFIG=$HOME/admin.conf" >>  ~/.bash_profile
```


### login kubernetes dashboard

1. update kubernetes-dashboard.yaml 
[wget https://raw.githubusercontent.com/kubernetes/dashboard/master/aio/deploy/recommended/kubernetes-dashboard.yaml]

```
kind: Service
apiVersion: v1
metadata:
  labels:
    k8s-app: kubernetes-dashboard
  name: kubernetes-dashboard
  namespace: kube-system
spec:
  type: NodePort
  ports:
    - port: 443
      targetPort: 8443
      nodePort: 30001
  selector:
    k8s-app: kubernetes-dashboard

```

1.1. create clusterrolebinding.yaml file:

```
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: tiller
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: tiller
    namespace: kube-system
```

1.2. create admin-user.yaml file : 

```
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    k8s-app: kubernetes-dashboard
  name: admin
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterdashboardRoleBinding
metadata:
  name: admin
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin
  namespace: kube-system
```

```
sudo kubectl create -f ./clusterrolebinding.yaml
sudo kubectl create -f ./admin-user.yaml
```

2. take Token:
```
sudo kubectl describe serviceaccount admin -n kube-system
sudo kubectl describe secret admin-token-**** -n kube-system
```

3. take permission:
create admin-user-admin.rbac.yaml:

```
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kube-system
---
# Create ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kube-system
```

4. use admin token login

```
sudo kubectl create -f admin-user-admin.rbac.yaml
sudo kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep admin-user | awk '{print $1}')
```


### install istio for kubernetes cluster

1. use helm install kubernetes istio mesh 

```
sudo .istio/install_istio_centos.sh

```

2. token permission
clusterrolebinding.yaml:

```
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: tiller
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: tiller
    namespace: kube-system

```

3. use tiller after create
```
kubectl create -f ./clusterrolebinding.yaml
```

### deploy nodes

```
docker pull registry.aliyuncs.com/google_containers/kube-proxy:v1.15.0
docker pull registry.aliyuncs.com/google_containers/coredns:1.3.1
docker pull registry.aliyuncs.com/google_containers/pause:3.1
```

### deploy app

1. create rc [ReplicationController], svc [Service]

service type: NodePort
service selector: awesome-app

```
kubectl create -f app/app-rc.yaml
kubectl create -f app/app-svc.yaml
```

after deploy success, you can browse http://ip:NodePort

### ssh container

```
kubectl exec -ti awesome-app -c awesome-app -n development /bin/sh
```

### show log

```
kubectl logs -f awesome-app -c awesome-app -n development
```

### Scale Pods

```
kubectl scale rc awesome-app -n development --replicas=3
```

### HPA

```
kubectl autoscale deployment awesome-app —-cpu-percent=90 —min=1 —max=10
```


### Rolling update

```
kubectl rolling-update awesome-app -n development  --image=awesome-app:2.0

```

### DNS Service

update every Node kubelet like this

```
kubelet
--cluster_dns=169.169.0.100
--cluster_domain=cluster.dadi

kubectl create -f dns/dns-rc.yaml
kubectl create -f dns/dns-svc.yaml
```

after deploy success, you can use pod_name:port == clusterIP:port 

### Ingress

```
kubectl create -f ingress/app-ingress-rc.yaml
kubectl create -f ingress/app-ingress.yaml
```

after deploy success , you can use curl --resolve appurl.com:80:machine ip  appurl.com/web

### CA Signature







