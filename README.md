# Learn Terraform - Provision an EKS Cluster
This repo is a companion repo to the [Provision an EKS Cluster tutorial](https://developer.hashicorp.com/terraform/tutorials/kubernetes/eks), containing
Terraform configuration files to provision an EKS cluster on AWS.

## A. Cluster Setup Tutorial
https://developer.hashicorp.com/terraform/tutorials/kubernetes/eks

You can either follow the steps exactly and clone origional repo https://github.com/hashicorp/learn-terraform-provision-eks-cluster. This is just a fork of that with some tweaks.


## B. Kubernetes Provider Tutorial
https://developer.hashicorp.com/terraform/tutorials/kubernetes/kubernetes-provider
The dir: learn-terraform-deploy-nginx-kubernetes is a completed version of this tutorial with a the parent terrafrom state path tweaked (in the lab they assume you are one dir up.)

# C. Sumo k8s
https://github.com/SumoLogic/sumologic-kubernetes-collection/blob/release-v2.19/deploy/README.md

let's do: https://github.com/SumoLogic/sumologic-kubernetes-collection/blob/release-v2.19/deploy/docs/Installation_with_Helm.**md**

follow the default helm path for greenfield (not existing or side by side).

You will need:
- accesskey/id
- helm (brew install helm)
- set cluster name in values.yaml as per yours "education-eks-anneimWr"

helm upgrade --install r1 sumologic/sumologic \
  -f values.yaml --set sumologic.accessId=$SUMO_ACCESS_ID --set sumologic.accessKey=$SUMO_ACCESS_KEY


Note... becuase we are using EKS and kubectl is configured to point at the EKS cluster we don't have to say ssh only a remote host, helm/kubectl will deploy remotely. if you might have more than one cluster setup make sure to do usual check you are pointing at right k8s  ```kubetcl cluster info``` etc.

check the pod name for the install container with kubetcl get pods

make sure to get some logs before the pod finishes with kubectl logs <podname> then if there is an issue with helm/tf in the container you will see why.

if the install starts you should see sumo pods with kubectl get pods

If after 5m some are still pending you have resource issues you can check with say:
kubectl describe pod r1-sumologic-fluentd-metrics-0

```
  Type     Reason            Age                 From               Message
  ----     ------            ----                ----               -------
  Warning  FailedScheduling  53s (x5 over 5m2s)  default-scheduler  0/2 nodes are available: 2 Insufficient memory.

```

Let's try the old 'make the instance bigger' aws fix. 
in eks-cluster.tf upsize the node type and the max nodes and desired state by bump up 1.
```
      instance_types = ["t3.large"]

      min_size     = 1
      max_size     = 4
      desired_size = 3
```
do terraform apply

as it's applying (which takes a few minutes) try commands like:
```
kubectl get nodes
kubectl get pods
etc
```

to see what is happening to the cluster.
