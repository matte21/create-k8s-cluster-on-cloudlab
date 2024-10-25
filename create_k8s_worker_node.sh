#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

if [[ -z "${1:-}" || -z "${2:-}" ]]; then
  echo "Usage: $0 <k8s master ip in 10.10.1/24> <k8s master ip in 128.105.146/22>"
  echo "Please provide both K8s master IPs when invoking the script."
  exit 1
fi
readonly k8s_ssh_master_ip="$1"
readonly k8s_join_master_ip="$2"

# Offline the CPUs in the NUMA node with highest ID to mimic a CPU-less NUMA node.
# Note: the current kubelet implementation breaks completely if the CPU-less NUMA node isn't the one
# with the highest index. The index is the highest index is $num_numas - 1 because indexing starts at 0.
# readonly num_numas=$(lscpu | grep "NUMA node(s):" | tr -s ' ' | cut -d ' ' -f 3)
# for cpu_to_offline in $(lscpu --online --parse | cut -d ',' -f1,4 | grep ",$((num_numas - 1))" | cut -d ',' -f1); do
#   echo 0 | sudo tee /sys/devices/system/cpu/cpu${cpu_to_offline}/online
# done

./cfg_k8s_generic_node.sh

# Get the token and cert hash to join the cluster.
readonly token=$(sudo ssh root@$k8s_ssh_master_ip "kubeadm token create")
readonly ca_cert_hash=$(sudo ssh root@$k8s_ssh_master_ip "cat /etc/kubernetes/pki/ca.crt | openssl x509 -pubkey  | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //'")
#sudo kubeadm join $k8s_join_master_ip:6443 --token $token --discovery-token-ca-cert-hash sha256:$ca_cert_hash --patches klet-cfg-patches/
sudo kubeadm join $k8s_join_master_ip:6443 --token $token --discovery-token-ca-cert-hash sha256:$ca_cert_hash
