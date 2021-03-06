# Pelias Cloudwatch Configuration

This repository contains a [Terraform](http://terraform.io/) configuration that can be used for
setting up [AWS CloudWatch](https://aws.amazon.com/cloudwatch/) Logs, custom metrics, alarms, and
dashboards for monitoring a Pelias installation in EC2.

## Components

This configuration assumes several things:
* Pelias is running on EC2
* There is a [Kubernetes](http://kubernetes.io/) cluster running in AWS that is used to host most
  components of Pelias (use https://github.com/pelias/kubernetes to set it up), and it can be
  configured to send all the cluster logs (including kube-system and kube-api) to a CloudWatch Log
  stream that is created by this Terraform config
* The Elasticsearch cluster used by Pelias is _not_ in Kubernetes, and can also be configured to
  send the Elasticsearch logs to a CloudWatch log stream

## Provided alerts

This configuration does not attempt to monitor individual instances. CPU usage, disk usage, memory
usage or other metrics on individual instances are NOT important. Instead it looks at overall
cluster state and metrics that indicate the Pelias cluster is not serving its users correctly.

Examples of monitored/alerted values include:

* Elasticsearch cluster state is RED. This means Elasticsearch cannot possibly be returning valid
  data.
* Elasticsearch or Kubernetes cluster ELB latency is high. This means requests are being served to
  users too slowly
* Elasticsearch or Kubernetes cluster (including master) `in service instances` is less than `minimum
  instances`. This suggests that there are not enough cluster resources to work properly.

There is also support for "legacy" Pelias infrastructure that is still running as individual EC2
instances behind Elastic Load Balancers, instead of within Kubernetes. By setting appropriate
Terraform variables, alerts for this infrastructre can be enabled or disabled. All current Pelias
services (API, pip-service, placeholder, and interpolation are supported individually) Similarly to other
instances, the only alerts for these instances will be service related:

* ELB healthy instance count is lower than expected
* ELB latency is high
* ELB 500 error count is high

## Issues

* It is not yet possible to enable the group metric collection required on Auto Scaling Groups
  created by kops. So for now, it should be enabled manually in the EC2 dashboard. Unfortunately
  KOPS will try to overwrite it if `kops update cluster` is used. See
  https://github.com/kubernetes/kops/issues/2254
* Likewise, for now it is not possible to set custom IAM roles on the kops cluster, but there is a
  pull request that will hopefully solve this soon: https://github.com/kubernetes/kops/pull/2440
