# Introduction to Nomad Namespaces and Quotas
This repo is a short walkthrough from a lightning talk I presented at HashiConf EU in 2021

## Requirements
* Nomad 1.1.0 Enterprise installed (To work with Quotas)
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

### checking the status of the job in a namespace
This is done with adding `-namespace web-qa` to your normal nomad command
```bash
nomad job status -namespace=web-qa
```
There is a great guide on the Nomad website about namespaces [HashiCorp Learn Nomad](https://learn.hashicorp.com/tutorials/nomad/namespaces)



## Nomad Resource Quotas
***Enterprise Feature***

### What are Resource Quotas
*Nomad Enterprise provides support for resource quotas, which allow operators to restrict the aggregate resource usage of namespaces.*

Once a quota specification is attached to a namespace, the Nomad cluster will count all resource usage by jobs in that namespace toward the quota limits. If the resource is exhausted, allocations within the namespaces will be queued until resources become available—by other jobs finishing or the quota being expanded.

In this section we will assign a quota to the `tpi-region` region.

### Creating Quota configuration

As with all HashiCorp Products, Nomad quota configuration is written in the HCL language.
To get an example quota specification you can run
```bash
nomad quota init
```
It will produce a file like this in the directory
```terraform
name = "default-quota"
description = "Limit the shared default namespace"

# Create a limit for the global region. Additional limits may
# be specified in-order to limit other regions.
limit {
    region = "tpi-region"
    region_limit {
        cpu = 2500
        memory = 1000
    }
}
```

You can then update the specification with the settings you would like.

## Deploying Quota Configuration to the Nomad cluster
You can deploy the configuration to the cluster by running
```bash
nomad quota apply web-qa-quota.hcl
```
You can see that the Quota has been deployted by running
```bash
nomad quota list
```
It should look like this.
```bash
Name                      Description
web-qa-quota  Limit the tpi-region web-qa namespace
```

### Attach the Quota to the Namespace
You can attach the quota you have just created to the namespace we crested earlier by running.
```bash
nomad namespace apply -quota web-qa-quota web-qa
```
You can see that the quota is attached correctly by running
```bash
nomad quota status web-qa
```
Now we can increase the number of instances to 6 to use up our quota.
We just increase the `count` parameter to 6, save the spec file and then run the job again.
We use the `-detach` switch to not enter monitor mode but just return the allocation number
```bash
nomad job run -detach example-quota.nomad
```

If you now go to the Nomad UI on `http://IPADDRESS-FOR-NOMAD-SERVER:4646/` you will see
that the allocation is not fully deployed as the resource limit has been reached.