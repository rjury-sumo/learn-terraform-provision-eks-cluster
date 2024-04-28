# Combined Labs: Provision An EKS Cluster with Terraform, Expiriment with kubernetes provider, setup sumo kubernetes collection, setup a sample app & trace

This is a mash up of a bunch of separate repos with some hacks.

Working through this will
- A. setup a EKS cluster in AWS with enough compute to run sumo collection on v3 with otel
- B. work through an exercise lab with provider to setup a nginx deployment and a CRD task
- C. Install 3.5 of sumologic_kubernetes_collection
- D. setup a live microservices demo app using a hacked version of the sumo demo project (mostly same just wiht repeat of installing collection removed)

## A. Cluster Setup Tutorial
https://github.com/hashicorp/learn-terraform-provision-eks-cluster

This repo is a companion repo to the [Provision an EKS Cluster tutorial](https://developer.hashicorp.com/terraform/tutorials/kubernetes/eks), containing
Terraform configuration files to provision an EKS cluster on AWS.
https://developer.hashicorp.com/terraform/tutorials/kubernetes/eks
Origional repo https://github.com/hashicorp/learn-terraform-provision-eks-cluster. 

### TL;DR If i am repeating this later to rebuild the cluster...
For re-runs. In future you can shortcut by just doing:
- go to root dir
- terraform apply
- setup kubectl either:
```
aws eks --region $(terraform output -raw region) update-kubeconfig \
    --name $(terraform output -raw cluster_name)
```
or
```
aws eks update-kubeconfig --name <yourcluster>
```

## B. Kubernetes Provider Tutorial - deploy nginx and a CRD via terraform provider
Note you can skip this if you just want to get sumo k8s instrumented or setup a demo app for tracing.
Kubernetes (K8S) is an open-source workload scheduler with focus on containerized applications. You can use the Terraform Kubernetes provider to interact with resources supported by Kubernetes.
In this tutorial, you will learn how to interact with Kubernetes using Terraform, by scheduling and exposing a NGINX deployment on a Kubernetes cluster. You will also manage custom resources using Terraform.
The final Terraform configuration files used in this tutorial can be found in the Deploy NGINX on Kubernetes via Terraform GitHub repository.

https://developer.hashicorp.com/terraform/tutorials/kubernetes/kubernetes-provider

# C. Sumo k8s collection installation
go here & review architecture graphs
https://github.com/SumoLogic/sumologic-kubernetes-collection/blob/release-v3.5/docs/README.md

then choose installation link and follow steps on this page OR....

## Tl;DR version
Becuase we are using EKS and kubectl is configured to point at the EKS cluster we don't have to say ssh only a remote host, helm/kubectl will deploy remotely. if you might have more than one cluster setup make sure to do usual check you are pointing at right k8s  ```kubectl cluster-info``` etc.

- install helm if you haven't already ``` brew install helm```
- setup env vars for ```--set sumologic.accessId=$SUMO_ACCESS_ID --set sumologic.accessKey=$SUMO_ACCESS_KEY```
- update helm
```
helm repo add sumologic https://sumologic.github.io/sumologic-kubernetes-collection
helm repo update
```

for these steps
https://github.com/SumoLogic/sumologic-kubernetes-collection/blob/release-v3.5/docs/installation.md#install-chart
- set cluster name in values.yaml as per yours "education-eks-anneimWr"
- then run helm using values yaml
```
cd sumo.k8s
helm upgrade --install -n 'sumologic-demo'  --create-namespace  -f values.yaml  release-1 sumologic/sumologic --set sumologic.accessId=$SUMO_ACCESS_ID --set sumologic.accessKey=$SUMO_ACCESS_KEY 
```

## Validation of setup phase
check the pod name for the install container with 
``` kubetctl get pods -n sumologic-demo```

If that single pod is crashloopbackoff you have serious problem (such as bad credts). make sure to get some logs before the pod finishes with kubectl logs <podname> then if there is an issue with helm/tf in the container you will see why.

## Validation of collection
After a few minutes you should see the release pod (which runs some terraform) switch to a bunch of pods. After a minute or so they shuould all be running not pending.
```
➜  learn-terraform-provision-eks-cluster git:(main) ✗ kubectl get pods -n sumologic-demo 
NAME                                                      READY   STATUS    RESTARTS   AGE
prometheus-release-1-kube-prometheus-prometheus-0         2/2     Running   0          10m
release-1-kube-prometheus-operator-6889484c96-6dt24       1/1     Running   0          2m1s
release-1-kube-state-metrics-7f77b7df84-j2bxq             1/1     Running   0          2m1s
release-1-prometheus-node-exporter-2m45v                  1/1     Running   0          3m25s
release-1-prometheus-node-exporter-5nkn4                  1/1     Running   0          3m24s
release-1-prometheus-node-exporter-bbkbt                  1/1     Running   0          11m
release-1-prometheus-node-exporter-cqzcs                  1/1     Running   0          11m
release-1-prometheus-node-exporter-m9tx5                  1/1     Running   0          3m23s
release-1-prometheus-node-exporter-mlxpf                  1/1     Running   0          3m19s
release-1-prometheus-node-exporter-mwbg7                  1/1     Running   0          3m10s
release-1-prometheus-node-exporter-qmchc                  1/1     Running   0          3m25s
release-1-prometheus-node-exporter-wbxnn                  1/1     Running   0          11m
release-1-sumologic-otelcol-events-0                      1/1     Running   0          2m1s
release-1-sumologic-otelcol-instrumentation-0             1/1     Running   0          2m
release-1-sumologic-otelcol-instrumentation-1             1/1     Running   0          2m
release-1-sumologic-otelcol-instrumentation-2             1/1     Running   0          2m
release-1-sumologic-otelcol-logs-0                        1/1     Running   0          2m2s
release-1-sumologic-otelcol-logs-1                        1/1     Running   0          57s
release-1-sumologic-otelcol-logs-2                        1/1     Running   0          11m
release-1-sumologic-otelcol-logs-collector-526mr          1/1     Running   0          3m3s
release-1-sumologic-otelcol-logs-collector-55mfc          1/1     Running   0          3m4s
release-1-sumologic-otelcol-logs-collector-5l97m          1/1     Running   0          2m59s
release-1-sumologic-otelcol-logs-collector-6pkfc          1/1     Running   0          11m
release-1-sumologic-otelcol-logs-collector-6rgt9          1/1     Running   0          2m40s
release-1-sumologic-otelcol-logs-collector-9jxv7          1/1     Running   0          11m
release-1-sumologic-otelcol-logs-collector-c8nmx          1/1     Running   0          11m
release-1-sumologic-otelcol-logs-collector-k4jrq          1/1     Running   0          2m55s
release-1-sumologic-otelcol-logs-collector-k4kmc          1/1     Running   0          3m4s
release-1-sumologic-otelcol-metrics-0                     1/1     Running   0          60s
release-1-sumologic-otelcol-metrics-1                     1/1     Running   0          2m
release-1-sumologic-otelcol-metrics-2                     1/1     Running   0          11m
release-1-sumologic-remote-write-proxy-566dc9fc5c-6bfkp   1/1     Running   0          2m
release-1-sumologic-remote-write-proxy-566dc9fc5c-v496g   1/1     Running   0          2m2s
release-1-sumologic-remote-write-proxy-566dc9fc5c-vbm57   1/1     Running   0          2m2s
release-1-sumologic-traces-gateway-c86fcdb9-cdhgg         1/1     Running   0          2m3s
release-1-sumologic-traces-sampler-779c9964f4-8dzq7       1/1     Running   0          2m2s
```


A common issue here is **insufficient resources as our collection requires a lot of instances** (6x t3.medium) to meet scheduling reuqurements
If you see our pods such as prometheus stuck in pending it's likely insufficient resources. You need to revisit the cluster sizing in eks-cluster.tf and do terrafrom apply to scale up the cluster.


if the install starts you should see sumo pods with kubectl get pods

If after 5m some are still pending you have resource issues you can check with say:
kubectl describe pod release-1-sumologic-traces-sampler-779c9964f4-8dzq7 -n sumologic-demo

```
  Type     Reason            Age                 From               Message
  ----     ------            ----                ----               -------
  Warning  FailedScheduling  53s (x5 over 5m2s)  default-scheduler  0/2 nodes are available: 2 Insufficient memory.

  Type     Reason            Age                  From               Message
----     ------            ----                 ----               -------
Warning  FailedScheduling  61s (x2 over 2m21s)  default-scheduler  0/3 nodes are available: 3 Insufficient cpu.
```

# D. Setting up a demo tracing app using opentelemetry-demo-application

We will follow along roughly with  our own blog using the k8s flavor
https://www.sumologic.com/blog/common-opentelemetry-demo-application/


First setup a RUM collection URL as per https://help.sumologic.com/docs/apm/real-user-monitoring/configure-data-collection/#step-1-create-a-rum-http-traces-source. 
```
OpenTelemetry demo, set up a RUM HTTP Traces source with a source name of your choice, an application name opentelemetry-demo and service name frontend-rum, leaving other options as defaults. Url from collectionSourceUrl will be used as SUMO_RUM_URL
```

go to sumo-opentelemetry-demo folder as per https://github.com/SumoLogic/opentelemetry-demo/tree/main/sumo_deployments/helm#deployment and follow steps
```
cd opentelemetry-demo/sumo_deployments/helm/sumo-opentelemetry-demo
```

**NOTE!! In this local version I have 
**- removed the sumologic kubernetes helm so it will just deploy the app and not our collection (because it's already there).
- hacked all the endpoints to be this (will break if you use diffrent releases / namespaces)
  
```
        env:
        - name: OTEL_EXPORTER_OTLP_ENDPOINT
          value: 'http://release-1-sumologic-otelagent.sumologic-demo:4317'
```

This is the command I used to setup the helm chart app in folder above. Make sure to use your RUM endpoint
```
helm install sumo-demo . \
--namespace sumologic-demo \
--set sumologic.rumUrl="https://rum-collectors.au.sumologic.com/receiver/v1/rum/<your url here>"
```

After a few minutes of stuff crashing you will hopefully get:
```
sumo-demo-accountingservice-7497f7758d-5bpxj              1/1     Running   3 (82s ago)   118s
sumo-demo-adservice-86879dfd6d-j94zx                      1/1     Running   0             119s
sumo-demo-cartservice-5697bb95b7-c9sv8                    1/1     Running   0             2m
sumo-demo-checkoutservice-857455cd6d-5snqt                1/1     Running   3 (74s ago)   2m
sumo-demo-currencyservice-5b4cf95467-wh2l2                1/1     Running   0             2m
sumo-demo-emailservice-5f78cb8c9b-nbmzn                   1/1     Running   0             119s
sumo-demo-featureflagservice-c459d47c6-jgpwv              1/1     Running   0             2m
sumo-demo-ffspostgres-57498d6fd8-fr4sr                    1/1     Running   0             118s
sumo-demo-frauddetectionservice-fddd94558-xtvm7           1/1     Running   0             118s
sumo-demo-frontend-rum-56f5b49f9d-zp8bf                   1/1     Running   0             118s
sumo-demo-frontendclicker-c7676765d-rvwbx                 1/1     Running   0             2m
sumo-demo-frontendproxy-58dfbb5666-82p9s                  1/1     Running   0             119s
sumo-demo-grafana-796965bb97-gvv6r                        1/1     Running   0             2m
sumo-demo-kafka-94f7d457d-hgh8q                           1/1     Running   0             2m
sumo-demo-paymentservice-6bd685b4c7-7b26f                 1/1     Running   0             119s
sumo-demo-productcatalogservice-789dcb6756-688d2          1/1     Running   0             119s
sumo-demo-prometheus-server-777f8d494-ktx22               1/1     Running   0             119s
sumo-demo-quoteservice-fbff95f9-blc2q                     1/1     Running   0             2m
sumo-demo-recommendationservice-6667bb6c84-jx7h5          1/1     Running   0             2m
sumo-demo-redis-6fd4cf9f48-dhjbt                          1/1     Running   0             2m
sumo-demo-shippingservice-69f6b8cfcd-m96nb                1/1     Running   0             118s
```

If you go to services/map /explore etc so far only RUM is instrumented.

go back to the sumo.k8s dir in terminal

let's add tracing auto instrumentation
```
cd sumo.k8s
helm upgrade --install -n 'sumologic-demo'  --create-namespace  -f values.yaml  release-1 sumologic/sumologic --set sumologic.accessId=$SUMO_ACCESS_ID --set sumologic.accessKey=$SUMO_ACCESS_KEY --set sumologic.traces.enabled=true
```

make sure to map local host so you can see your app
```
kubectl --namespace sumologic-demo port-forward service/sumo-demo-frontend 8080:8080
```

then you can browse to the app via localhost:8080

You should now see all your stuff auto instrumented in service map etc.

# Changing scrape interval for prometheus
A common config by customers is to change the scrape interval from 30s to 1m or 2m to lower DPM billed by sending less frequent metrics.
https://github.com/SumoLogic/sumologic-kubernetes-collection/blob/release-v2.19/deploy/docs/Best_Practices.md#changing-scrape-interval-for-prometheus

let's change the scape interval to 2m

update values.yaml 
```
kube-prometheus-stack:  # For values.yaml
  prometheus:
    prometheusSpec:
      scrapeInterval: '2m'
```

```
helm upgrade --install -n 'sumologic-demo'  --create-namespace  -f values.yaml  release-1 sumologic/sumologic --set sumologic.accessId=$SUMO_ACCESS_ID --set sumologic.accessKey=$SUMO_ACCESS_KEY --set sumologic.traces.enabled=true 
```