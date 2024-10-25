#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

source ./env.sh

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
sudo modprobe overlay
sudo modprobe br_netfilter

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1
EOF
sudo sysctl --system

sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

sudo apt-get update -y
sudo apt-get install -y apt-transport-https=$apt_transport_https_version \
    ca-certificates=$ca_certificates_version \
    curl=$curl_version \
    gpg=$gpg_version \
    lsb-release=$lsb_release_version

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
curl -fsSL "https://pkgs.k8s.io/core:/stable:/v$k8s_version/deb/Release.key" | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v$k8s_version/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update -y

sudo apt-get install -y containerd.io=$containerd_io_version
sudo mkdir -p /etc/containerd
readonly containerd_cfg_dir="/etc/containerd/config.toml"
sudo containerd config default | sudo tee $containerd_cfg_dir
sudo sed -i 's/            SystemdCgroup = false/            SystemdCgroup = true/' $containerd_cfg_dir
sudo sed -i 's/    sandbox_image = "registry.k8s.io\/pause:3.8"/    sandbox_image = "registry.k8s.io\/pause:3.10"/' $containerd_cfg_dir
sudo systemctl restart containerd

sudo apt-get install -y kubelet=$kubelet_version kubeadm=$kubeadm_version kubectl=$kubectl_version
sudo apt-mark hold kubelet kubeadm kubectl
