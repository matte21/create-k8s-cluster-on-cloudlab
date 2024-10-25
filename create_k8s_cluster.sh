#!/bin/bash

#! WARNING: this script and the ones it invokes are designed only for my use cases.
#! Furthermore, they are designed to run on cloudlab instances of type c220g1, c220g5,
#! c240g5, with Ubuntu 20.04 or 22.04. It has no ambition of supporting use cases
#! other than mine, or of running on HW/OS different than the aforementioned one.

# todo: copy kubectl here.
# todo: add custom kubelet configs.

set -o errexit
set -o nounset
set -o pipefail

source ./env.sh

echo "Copying scripts to master node"
scp "env.sh" "$cloudlab_user@$master_public_ip:env.sh"
scp "cfg_k8s_generic_node.sh" "$cloudlab_user@$master_public_ip:cfg_k8s_generic_node.sh"
scp "create_k8s_master_node.sh" "$cloudlab_user@$master_public_ip:create_k8s_master_node.sh"

echo "Copying scripts to worker nodes"
while read -r worker_ip; do
    scp "env.sh" "$cloudlab_user@${!worker_ip}:env.sh"
    scp "cfg_k8s_generic_node.sh" "$cloudlab_user@${!worker_ip}:cfg_k8s_generic_node.sh"
    scp "create_k8s_worker_node.sh" "$cloudlab_user@${!worker_ip}:create_k8s_worker_node.sh"
done <<< "$(compgen -A variable | grep 'worker_[0-9]\+_public_ip')"

echo The interactive part of the script is over.
echo From now on you don't need to pay attention to what it's doing.

echo Creating K8s master node.
ssh $cloudlab_user@$master_public_ip "./create_k8s_master_node.sh"

# Get the token and cert for workers to join the cluster. 
readonly token=$(ssh root@$master_public_ip "kubeadm token create")
readonly ca_cert_hash=$(ssh root@$master_public_ip "cat /etc/kubernetes/pki/ca.crt | openssl x509 -pubkey  | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //'")

echo Creating K8s worker nodes
pids=()
while read -r worker_ip; do
    ssh "$cloudlab_user@${!worker_ip}" "./create_k8s_worker_node.sh $token $ca_cert_hash" &
    pids+=($!)
done <<< "$(compgen -A variable | grep 'worker_[0-9]\+_public_ip')"

failed_workers=()
for i in "${!pids[@]}"; do
    if ! wait "${pids[i]}"; then
        failed_workers+=($((i + 1)))
    fi
done

if [ "${#failed_workers[@]}" -eq 0 ]; then
    echo "K8s cluster successfully created."
else
    echo "Creation of the workers with the following indexes failed: ${failed_workers[@]}"
    echo "All the other workers have been created successfully." 
fi
echo "ssh on the master and use kubectl to interact with it."
