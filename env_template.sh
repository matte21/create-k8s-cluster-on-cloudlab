#!/bin/bash

set -o nounset

# Set this to your cloudlab username.
cloudlab_user=

# Set these by looking at the details of the nodes of your cloudlab
# experiment.
readonly master_public_ip=

# Adjust to the number of worker nodes that you want in your cluster
# (and that you have provisioned in your cloudlab experiment).
readonly num_workers=

# Set these by looking at the details of the nodes of your cloudlab
# experiment. If you need more or less workers, simply add/remove
# the corresponding lines.
readonly worker_1_public_ip=
# readonly worker_2_public_ip=
# readonly worker_3_public_ip=
# readonly worker_4_public_ip=

# The relative or absolute paths of the dir holding the patch to
# the kubelet configs on workers. Said path will be passed to the
# "--patches" flag of kubeadm join.
# readonly worker_1_cfg_patch_dir=
# readonly worker_2_cfg_patch_dir
# readonly worker_3_cfg_patch_dir
# readonly worker_4_cfg_patch_dir

# Versions of dependencies to install. We lock them for reproducibility, but know that
# you might have to change some of them if you use a different Ubuntu version, because
# each Ubuntu version might have a different set of versions available for a given apt
# package.
readonly apt_transport_https_version="2.0.10"
readonly ca_certificates_version="20240203~20.04.1"
readonly curl_version="7.68.0-1ubuntu2.24"
readonly gpg_version="2.2.19-3ubuntu2.2"
readonly lsb_release_version="11.1.0ubuntu2"
readonly containerd_io_version="1.7.22-1"
readonly k8s_version="1.31"
readonly kubelet_version="1.31.1-1.1"
readonly kubeadm_version="1.31.1-1.1"
readonly kubectl_version="1.31.1-1.1"
