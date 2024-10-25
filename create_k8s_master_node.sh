#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

./cfg_k8s_generic_node.sh

# 10.244.0.0/16 is the default Pod CIDR of flannel, and we aren't changing the default.
readonly pod_net_cidr="10.244.0.0/16"

sudo kubeadm init --pod-network-cidr=$pod_net_cidr

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubectl apply -f https://github.com/flannel-io/flannel/releases/download/v0.25.7/kube-flannel.yml
