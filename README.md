# K8s Cluster Creation Scripts

This repo contains scripts that I use to create K8s clusters.

They are tailored to my use cases, and likely won't support yours.

Also, the scripts have been tested only on [cloudlab](https://www.cloudlab.us/)
instances of type `c220g1`, `c220g5`, `c240g5`, with Ubuntu 20.04 or 22.04. They have
no ambition of supporting other environments.

## Prerequisites

Before creating a K8s cluster, you must create the cloudlab instances that will make up
the K8s cluster nodes.

## Creating a cluster

Copy `env_template.sh` to a file called `env.sh`:

```bash
cp env_template.sh env.sh
```

Then, open `env.sh`, and modify it by setting the env variables in it to the appropriate values.
You can uncomment env vars that are currently unset if you need to set them.
Currently, env vars that must be set are uncommented. Some are set to values that I expect
to be stable, while those whose values will change between cloudlab experiments are unset
(it's up to you to set them to the correct values). Optional vars are commented out,
uncomment and set them if you need them. You MUST pick one cloudlab instance as the K8s
master node, and set var `master_public_ip` in `env.sh` to that instance public IP
address (which you can retrieve from the cloudlab UI). You must do an analogous thing for
every worker node/instance that you want in your cluster (for worker `i`, just set
variable `worker_i_public_ip`).

`env.sh` is gitignored, so you don't have to worry about committing its contents (which
might change frequently).

With a proper `env.sh` in place, create the cluster by running:

```bash
./create_k8s_cluster.sh
```

The process will take some minutes to complete.
Stdout and stderr will inform you in case of errors or successful completion.

## Custom Configuration of Worker Nodes

You can customize the configuration of each worker node's kubelet via a patch file.
To customize the configuration of worker _i_, create a folder `cfg_patches/worker_i/` and place the patch file under it. The format of the patch file is defined at [https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/control-plane-flags/#kubelet](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/control-plane-flags/#kubelet).

Of course, you can customize the configuration of multiple worker nodes (and when doing so, you can configure each worker differently from the others). Just create one folder for each worker (e.g. `cfg_patches/worker_i/`, `cfg_patches/worker_j/`) and place the desired patch files under each folder.

## Fake NUMA Node on Worker Nodes

The scripts configure each worker node with a simulated CXL-attached NUMA node. The simulated NUMA node is created by offlining all CPUs on a real NUMA node and setting the uncore frequency for that NUMA node to a low value (to mimic the higher memory access latency).

Currently there's no way to disable this configuration step. I might make it optional in the future.
