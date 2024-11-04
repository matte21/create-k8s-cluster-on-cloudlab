#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

if [[ -z "${1:-}" || -z "${2:-}" ]]; then
  echo "Usage: $0 <kubeadm join token> <kubeadm join ca cert hash> [<cfg patches dir path>]"
  echo "Please provide mandatory arguments for kubeadm join token and ca cert hash."
  exit 1
fi
readonly token="$1"
readonly ca_cert_hash="$2"
cfg_patches_flag=""
if [[ -n "${3:-}" && -d "$3" ]]; then
  cfg_patches_flag="--patches $3"
fi

source ./env.sh

# Offline the CPUs in the NUMA node with highest ID to mimic a CPU-less NUMA node.
# Note: the current kubelet implementation breaks completely if the CPU-less NUMA node isn't the one
# with the highest index. The index is the highest index is $num_numas - 1 because indexing starts at 0.
# readonly num_numas=$(lscpu | grep "NUMA node(s):" | tr -s ' ' | cut -d ' ' -f 3)
# for cpu_to_offline in $(lscpu --online --parse | cut -d ',' -f1,4 | grep ",$((num_numas - 1))" | cut -d ',' -f1); do
#   echo 0 | sudo tee /sys/devices/system/cpu/cpu${cpu_to_offline}/online
# done
# todo: set uncore frequency.

./cfg_k8s_generic_node.sh

sudo kubeadm join $master_public_ip:6443 \
  --token $token \
  --discovery-token-ca-cert-hash sha256:$ca_cert_hash \
  "$patches_flag"
