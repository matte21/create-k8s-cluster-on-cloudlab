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
readonly cfg_patches_dir="${3:-}"

source ./env.sh

sudo apt-get update -y

# Take the NUMA node with the highest index and make it mimic a CXL-attached
# NUMA node by offlining all CPUs in it and lowering its uncore frequency
# to mimic the increased access latency. We pick the NUMA node with the
# highest index because the current kubelet implementation breaks completely
# if the CPU-less NUMA node isn't the one with the highest index.
readonly uncore_freq_register_nbr="0x620"
readonly slow_numa_uncore_freq="0x707"
readonly num_numas=$(lscpu | grep "NUMA node(s):" | tr -s ' ' | cut -d ' ' -f 3)
readonly cpus_on_fake_cxl_numa=($(lscpu --online --parse | cut -d ',' -f1,4 | grep ",$((num_numas - 1))" | cut -d ',' -f1))
sudo apt-get install -y msr-tools numactl pcm
sudo modprobe msr
# We set the value of register 0x620 only for one processor because the
# register is the same for all processors in a NUMA Node.
sudo wrmsr --processor $(echo "${cpus_on_fake_cxl_numa[0]}" | cut -d ' ' -f1) $uncore_freq_register_nbr $slow_numa_uncore_freq
for cpu in "${cpus_on_fake_cxl_numa[@]}"; do
  echo 0 | sudo tee /sys/devices/system/cpu/cpu${cpu}/online
done

./cfg_k8s_generic_node.sh

if [[ -n "$cfg_patches_dir" && -d "$cfg_patches_dir" ]]; then
  sudo kubeadm join $master_public_ip:6443 \
    --token $token \
    --discovery-token-ca-cert-hash sha256:$ca_cert_hash \
    --patches "$cfg_patches_dir"
else
  sudo kubeadm join $master_public_ip:6443 \
    --token $token \
    --discovery-token-ca-cert-hash sha256:$ca_cert_hash
fi
