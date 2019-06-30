# k8s_deployment
kubernetes deployment sh on centos 7.x

### use install_k8s.sh to deploy k8s

```
sudo ./install_k8s.sh
```

### use uninstall_k8s.sh to remove docker and k8s

```
sudo ./uninstall_k8s.sh
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

2. create admin-user.yaml file : 

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

3. take Token:
```
sudo kubectl describe serviceaccount admin -n kube-system
sudo kubectl describe secret admin-token-**** -n kube-system
```

4. take permission:
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

5. use admin token login

```
sudo kubectl create -f admin-user-admin.rbac.yaml
sudo kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep admin-user | awk '{print $1}')
```















