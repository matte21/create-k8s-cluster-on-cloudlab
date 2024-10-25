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
