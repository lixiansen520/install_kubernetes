#!/bin/bash

node_name=$1
node_name=$(echo ${node_name} | sed 's/\./-/g')
KUBE_APISERVER=$2
echo ">>> ${node_name}"

# 创建 token

kubeadm token create \
  --description kubelet-bootstrap-token \
  --groups system:bootstrappers:${node_name} \
  --kubeconfig ~/.kube/config &> /dev/null


export BOOTSTRAP_TOKEN=$(kubeadm token list --kubeconfig ~/.kube/config | grep ${node_name} | awk '{print $1}' | tail -1)
# 设置集群参数
kubectl config set-cluster kubernetes \
  --certificate-authority=/etc/kubernetes/ssl/ca.pem \
  --embed-certs=true \
  --server=${KUBE_APISERVER} \
  --kubeconfig=kubelet-bootstrap-${node_name}.kubeconfig

# 设置客户端认证参数
kubectl config set-credentials kubelet-bootstrap \
  --token=${BOOTSTRAP_TOKEN} \
  --kubeconfig=kubelet-bootstrap-${node_name}.kubeconfig

# 设置上下文参数
kubectl config set-context default \
  --cluster=kubernetes \
  --user=kubelet-bootstrap \
  --kubeconfig=kubelet-bootstrap-${node_name}.kubeconfig

# 设置默认上下文
kubectl config use-context default --kubeconfig=kubelet-bootstrap-${node_name}.kubeconfig