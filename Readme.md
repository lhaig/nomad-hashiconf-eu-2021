# Introduction to Nomad Namespaces and Quotas
This repo is a short walkthrough from a lightning talk I presented at HashiConf EU in 2021

## Requirements
* Nomad 1.1.0 Enterprise installed (Latest at the time of this talk.)
* Export your export NOMAD_ADDR=http://IPADDRESS-FOR-NOMAD-SERVER:4646/
* Directory on your computer to work in
* Comfortable with working in the CLI.

## Namespaces.

### What are namespaces

*Namespaces are a way within Nomad to separate Nomad Users, jobs and their resources from each other.*

These Namespaces can be secured using Nomad ACL policies to restrict rights.
Tokens can be granted access to

These objects that can be namespaced include:
* Jobs.
* Allocations.
* Deployments.
* Evaluations.

Some Nomad Objects are not namespaced as they are shared accross the complete cluster.
* Nodes.
* ACL Policies.
* Sentinel Policies.
* Quota Specifications.

### Creating Namespaces

Check your connectivity to the nomad cluster
```bash
nomad server members
```
This should return a list of the servers in your cluster
```bash
Name                 Address        Port  Status  Leader  Protocol  Build      Datacenter  Region
nmd-svr1.tpi-region  192.168.1.100  4648  alive   true    2         1.1.0+ent  tpi-dc1     tpi-region
nmd-svr2.tpi-region  192.168.1.101  4648  alive   false   2         1.1.0+ent  tpi-dc1     tpi-region
nmd-svr3.tpi-region  192.168.1.102  4648  alive   false   2         1.1.0+ent  tpi-dc1     tpi-region
```
Lets check the current namespace list
```bash
nomad namespace list
```
Should return the default namespace
```bash
Name     Description
default  Default shared namespace
```
Creating namespaces is very easy
```bash
nomad namespace apply -description "QA webserver namespace" web-qa
```
Lets check namespace list again
```bash
nomad namespace list
```
Should return the full list of namespaces including web-qa
```bash
Name     Description
default  Default shared namespace
web-qa   QA webserver namespace
```

### Running a Job in a Namespace.
Running a job in a specific Namespace is easy.
Just add the namespace parameter to your jobs specification.
```terraform
job "example" {
  datacenters = ["dc1"]
  ## Run in the QA environments
  namespace = "web-qa"
```
Then run the job as normal with
```bash
nomad job run example-namespace.nomad
```

### checking th3e status of the job in a namespace
This is done with adding `-namespace web-qa` to your normal nomad command
```bash
nomad job status -namespace=web-qa
```
There is a great guide on the Nomad website about namespaces [HashiCorp Learn Nomad](https://learn.hashicorp.com/tutorials/nomad/namespaces)



